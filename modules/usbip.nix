{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.pine.usbip;
  package = config.boot.kernelPackages.usbip;
  kernelStr = lib.strings.concatStringsSep "|" cfg.usbPaths;
in
{
  options.pine.usbip = {
    usbPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of USB device paths to bind for USB/IP";
    };
  };

  config = mkIf (cfg.usbPaths != [ ]) {

    boot.kernelModules = [ "usbip-host" ];

    environment.systemPackages = [ package ];

    # Rebind all of these usb paths to the
    # usbip-host driver when attaching
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", KERNEL=="${kernelStr}", ACTION=="add", ENV{DEVTYPE}=="usb_device", RUN+="${package}/bin/usbip bind -b %k"
    '';

    systemd.services.usbipd = {
      description = "USB-IP Host Daemon";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${package}/bin/usbipd";
      };
    };

    networking.firewall.allowedTCPPorts = [ 3240 ];

  };
}
