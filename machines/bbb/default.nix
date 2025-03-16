{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-layout.nix
  ];

  pine.crossHostSystem = "armv7l-linux";

  # Uses U-Boot
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        # save space
        configurationLimit = 3;
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
}
