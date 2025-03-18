{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.pine.machine;
  imageTarget = cfg.bbb.imageTarget;
in
{

  options.pine.machine.bbb.imageTarget = mkOption {
    type = lib.types.enum [
      "emmc"
      "sdcard"
    ];
    description = "target internal 'emmc' or 'sdcard'";
  };

  config =
    let
      targetDevNr = if imageTarget == "emmc" then "1" else "0";
      targetDevice = "/dev/mmcblk${targetDevNr}";

      bootloader = pkgs.buildUBoot {
        defconfig = "am335x_evm_defconfig";
        extraMeta.platforms = [ "armv7l-linux" ];
        filesToInstall = [
          "MLO"
          "u-boot.img"
        ];
        # load uboot.env from boot device/first bootable partition
        extraConfig = ''
          CONFIG_ENV_FAT_DEVICE_AND_PART="${targetDevNr}:auto"
          CONFIG_SYS_MMC_ENV_DEV=${targetDevNr}
        '';
      };

      # NOTE: Cannot use pkgs.coreutils/bin/dd as this disko run
      # this using build architecture
      update-bootloader = pkgs.writeShellScriptBin "update-bootloader" ''
        set -eu -o pipefail

        echo "Installing MLO to ${targetDevice}"
        dd conv=notrunc if=${bootloader}/MLO \
            of=${targetDevice} bs=512 \
            seek=${config.disko.devices.disk."${imageTarget}".content.partitions.mlo.start}

        echo "Installing U-boot to ${targetDevice}"
        dd conv=notrunc if=${bootloader}/u-boot.img \
            of=${targetDevice} bs=512 \
            seek=${config.disko.devices.disk."${imageTarget}".content.partitions.u-boot.start}
      '';
    in
    mkIf cfg.bbb.enable {

      # https://github.com/nix-community/disko/issues/988
      environment.systemPackages = lib.mkIf (pkgs.stdenv.hostPlatform.system == "armv7l-linux") [
        update-bootloader
      ];

      disko.devices = {
        disk = {
          "${imageTarget}" = {
            imageName = "${config.networking.hostName}-${imageTarget}";
            imageSize = "4G";
            device = targetDevice;
            type = "disk";
            content = {
              type = "gpt";

              partitions = {
                mlo = {
                  type = "b000";
                  label = "mlo";
                  priority = 1;
                  start = "256";
                  end = "767";
                  alignment = 1;
                };

                u-boot = {
                  type = "b000";
                  label = "uboot";
                  priority = 2;
                  start = "768";
                  end = "8925";
                  alignment = 1;
                };

                boot = {
                  name = "boot";
                  size = "256M";
                  type = "EF00";
                  priority = 3;
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };

                root = {
                  name = "root";
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };

            # FIXME: nixos-anywhere fails sometimes on target because
            # partition-by-label isent populated
            preMountHook = lib.mkIf (imageTarget == "emmc") ''
              sleep 2
            '';

            postCreateHook = ''
              # boot part needs a bootable flag to pick up extlinux cfg
              sgdisk -A 4:set:3 "$device"

              # Install Uboot
              ${update-bootloader}/bin/update-bootloader
            '';
          };
        };
      };
    };
}
