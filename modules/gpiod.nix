{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.pine.gpiod;
in
{
  options.pine.gpiod.enable = lib.mkEnableOption "Enable GPIOd and dbus service";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.libgpiod ];

    services.dbus.packages = [ pkgs.libgpiod ];
    services.udev.packages = [ pkgs.libgpiod ];

    systemd.packages = [ pkgs.libgpiod ];
    systemd.services.gpio-manager = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ReadOnlyDirectories = "";
    };

    users.groups.gpio = { };
    users.users.gpio-manager = {
      group = "gpio";
      isSystemUser = true;
    };
  };
}
