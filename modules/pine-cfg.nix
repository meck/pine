{
  config,
  pkgs,
  lib,
  self,
  ...
}:
with lib;
let
  cfg = config.pine;
in
{
  imports = [
    ./pine-user.nix
    ./usbip.nix
    ./gpiod.nix
    ./machines/bbb
    self.inputs.disko.nixosModules.disko
  ];

  options.pine = {
    enable = mkEnableOption "Enable pine base config";

    disableRegistry = mkOption {
      type = types.bool;
      default = true;
      description = "Clear /etc/nix/registry.json to save some space (removes nixpkgs from the store)";
    };
  };

  config = mkIf cfg.enable {

    nixpkgs = {
      overlays = [
        self.outputs.overlays.additions
        self.outputs.overlays.modifications
      ];
      config.allowUnfree = true;
    };

    nix = {

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";

        # Add wheel group for remote nixos-rebuild
        trusted-users = [ "@wheel" ];
      };
      registry = mkIf cfg.disableRegistry (mkForce { });
    };

    # Generate .bmap files
    disko.imageBuilder.extraPostVM = ''
      for image in "$out"/*raw; do
        ${pkgs.buildPackages.bmaptool}/bin/bmaptool create "$image" > "$image.bmap"
      done
    '';

  };
}
