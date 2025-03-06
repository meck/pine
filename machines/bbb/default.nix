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
      generic-extlinux-compatible.enable = true;
    };

    consoleLogLevel = lib.mkDefault 7;

    kernelPackages =
      let
        customKernel = pkgs.linuxKernel.kernels.linux_6_13.override {
          defconfig = "omap2plus_defconfig";
        };
      in
      pkgs.linuxPackagesFor customKernel;

    kernelParams = [
      "earlycon"
      "console=ttyS0,115200n8"
    ];
  };
}
