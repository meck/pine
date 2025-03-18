{
  config,
  pkgs,
  lib,
  outputs,
  inputs,
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
    inputs.disko.nixosModules.disko
  ];

  options.pine.enable = mkEnableOption "Enable pine base config";

  config = mkIf cfg.enable {

    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
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
