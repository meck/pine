{
  description = "PINE: Pine Is Nix Embedded";

  inputs = {
    # Nixpkgs branches
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixos-stable";

    # Declerative disk partitioning
    disko = {
      # NOTE: use master for https://github.com/nix-community/disko/pull/990
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        disko.follows = "disko";
      };
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "armv7l-linux"
      ];
      mkBBBsystem =
        sysConfig:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit self; };
          modules = [
            outputs.nixosModules.cross
            {
              pine = {
                enable = true;
                crossBuildSystem = "x86_64-linux";
                defaultUser = true;
                machine.bbb = {
                  enable = true;
                  imageTarget = sysConfig.imageTarget;
                };
              };
            }
          ] ++ sysConfig.modules;
        };

    in
    {
      # nixos-anywhere binary reexport
      packages = forAllSystems (system: {
        nixos-anywhere = inputs.nixos-anywhere.packages."${system}".nixos-anywhere;
      });

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { };

      #Nixos modules
      nixosModules = (import ./modules) // (import ./images);

      # NixOS configuration
      nixosConfigurations = {

        # Simple installer image for installing
        # to internal emmc using nixos-anywhere
        pine-bbb-installer = mkBBBsystem {
          modules = [ outputs.nixosModules.image-installer ];
          imageTarget = "sdcard";
        };

        # Full install to sd-card
        pine-bbb-standard-sd = mkBBBsystem {
          modules = [ outputs.nixosModules.image-standard ];
          imageTarget = "sdcard";
        };

        # For install on internal emmc (using pine-bbb-installer and nixos-anywhere)
        pine-bbb-standard-emmc = mkBBBsystem {
          modules = [ outputs.nixosModules.image-standard ];
          imageTarget = "emmc";
        };
      };

      # https://github.com/nix-community/disko/blob/master/docs/disko-images.md
      images = {
        bbb-standard =
          outputs.nixosConfigurations.pine-bbb-standard-sd.config.system.build.diskoImagesScript;
        bbb-installer =
          outputs.nixosConfigurations.pine-bbb-installer.config.system.build.diskoImagesScript;
      };
    };
}
