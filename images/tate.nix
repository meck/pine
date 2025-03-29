{
  pkgs,
  ...
}:
{
  imports = [ ./standard.nix ];

  pine = {
    defaultUser = false;
    machine.bbb.gpio.enable = true;
    gpiod.enable = true;
    usbip.usbPaths = [
      "1-1.5.2"
      "1-1.5.3"
      "1-1.5.4"
    ];
  };

  # main tate user
  users.users.tate = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$w19Ktxjl4DKHSuLZ9/Qhp1$ni/fd4DfRAjT9IeZbD5XScvy5MQdJwF7iWx5IHA1faA"; # `pass`
    extraGroups = [
      "wheel"
      "dialout"
      "gpio"
    ];
  };

  # Allow passwordless sudo from wheel group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # MulticastDNS
  networking.firewall.allowedUDPPorts = [ 5353 ];
  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
  services.resolved.extraConfig = ''
    MulticastDNS=yes
    LLMNR=no
  '';

  # Set hostname to tate-<last4mac>
  networking.hostName = "";
  systemd.services.tate-hostname = {
    description = "Tate MAC based hostname";
    after = [ "sys-subsystem-net-devices-eth0.device" ];
    wants = [ "sys-subsystem-net-devices-eth0.device" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tate-hostname" ''
        set -e
        IF=eth0

        MAC=0000
        if [ ! -e "/sys/class/net/$IF" ]; then
          echo "Error: $IF interface not found" >&2
        else
          MAC=$(cut -c 13- </sys/class/net/$IF/address | sed 's/://g')
        fi

        hostnamectl hostname --transient "tate-''${MAC}"
      '';
    };
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    tio
    tatectl
  ];

  programs = {
    # Quality of life
    starship.enable = true;
    tmux.enable = true;
  };
}
