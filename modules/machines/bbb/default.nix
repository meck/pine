{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.pine.machine;
in
{
  imports = [ ./disk-layout.nix ];

  options.pine.machine.bbb.enable = mkEnableOption "Enable pine beaglebone black";

  config = mkIf cfg.bbb.enable {
    pine.crossHostSystem = "armv7l-linux";

    # Uses U-Boot
    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible = {
          enable = true;
          # save space
          configurationLimit = lib.mkDefault 3;
        };
      };

      consoleLogLevel = lib.mkDefault 7;

      # See /pkgs
      kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor pkgs.linux_bbb);

      kernelParams = [
        "earlycon"
        "console=ttyS0,115200n8"
      ];
    };
  };
}
