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
    systemd.packages = [ pkgs.libgpiod ];
    services.dbus.packages = [ pkgs.libgpiod ];
    services.udev.packages = [ pkgs.libgpiod ];
    services.udev.extraRules = ''
      SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", TAG+="systemd", ENV{SYSTEMD_WANTS}="gpio-manager.service"
    '';

    users.groups.gpio = { };
    users.users.gpio-manager = {
      group = "gpio";
      isSystemUser = true;
    };
  };
}
