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
  imports = [
    ./disk-layout.nix
    ./gpio.nix
  ];

  options.pine.machine.bbb.enable = mkEnableOption "Enable pine beaglebone black";

  config = mkIf cfg.bbb.enable {
    pine.crossHostSystem = import ./platform.nix;

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

      # See /pkgs for complete kernel definition
      kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor pkgs.linux_bbb);

      # Manually define availableKernelModules to avoid:
      # https://github.com/NixOS/nixpkgs/issues/154163
      # alternative is an overlay:
      # makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      initrd = {
        includeDefaultModules = false;
        availableKernelModules = [
          "ext2"
          "ext4"
          "autofs"
          "sd_mod"
          "sr_mod"
          "mmc_block"
          "ehci_hcd"
          "xhci_hcd"
          "usbhid"
          "hid_generic"
          "hid_lenovo"
          "hid_apple"
          "hid_roccat"
          "hid_logitech_hidpp"
          "hid_logitech_dj"
          "hid_microsoft"
          "hid_cherry"
          "hid_corsair"
        ];
        kernelModules = [ ];
      };

      kernelParams = [
        "earlycon"
        "console=ttyS0,115200n8"
      ];
    };

    # Cleanup
    systemd = {
      package = pkgs.systemd.override {
        withTpm2Tss = false;
      };
      suppressedSystemUnits = [
        "systemd-bootctl@.service"
        "systemd-bootctl.socket"
        "systemd-hibernate-clear.service"
      ];
    };

  };
}
