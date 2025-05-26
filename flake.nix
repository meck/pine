{
  description = "PINE: Pine Is Nix Embedded";

  inputs = {
    # Nixpkgs branches
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
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

      lib = nixpkgs.lib;

      forHostSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # nixos-anywhere binary reexport
      nixos-anywherePackges = forHostSystems (system: {
        nixos-anywhere = inputs.nixos-anywhere.packages."${system}".nixos-anywhere;
      });

      mkDiskoImage = nixosConfig: nixosConfig.config.system.build.diskoImagesScript;

      mkBBBsystem =
        sysConfig:
        lib.nixosSystem {
          specialArgs = { inherit self; };
          modules = [
            outputs.nixosModules.cross
            {
              pine = {
                enable = true;
                crossBuildSystem = "x86_64-linux";
                defaultUser = lib.mkDefault true;
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
      packages = nixos-anywherePackges;

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

        # Tate system
        tate-emmc = mkBBBsystem {
          modules = [ outputs.nixosModules.image-tate ];
          imageTarget = "emmc";
        };
      };

      # https://github.com/nix-community/disko/blob/master/docs/disko-images.md
      images = {
        bbb-standard = mkDiskoImage outputs.nixosConfigurations.pine-bbb-standard-sd;
        bbb-installer = mkDiskoImage outputs.nixosConfigurations.pine-bbb-installer;
      };
    };
}
