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
    ./machines/bbb
    self.inputs.disko.nixosModules.disko
  ];

  options.pine.enable = mkEnableOption "Enable pine base config";

  config = mkIf cfg.enable {

    nixpkgs = {
      overlays = [
        self.outputs.overlays.additions
        self.outputs.overlays.modifications
      ];
      config.allowUnfree = true;
    };

    nix.settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";

      # Add wheel group for remote nixos-rebuild
      trusted-users = [ "@wheel" ];
    };

    # Generate .bmap files
    disko.imageBuilder.extraPostVM = ''
      for image in "$out"/*raw; do
        ${pkgs.buildPackages.bmaptool}/bin/bmaptool create "$image" > "$image.bmap"
      done
    '';

  };
}
