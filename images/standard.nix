{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  nix = {
    gc.automatic = true;

    # Deduplicate and optimize nix store
    settings.auto-optimise-store = true;
  };

  boot = {
    # Systemd in initrd
    initrd.systemd.enable = true;

    # Clean /tmp on each boot
    tmp.cleanOnBoot = true;
  };

  # Use systemd networking
  systemd.network.enable = true;
  networking.useNetworkd = true;

  services.openssh.enable = true;

  networking.hostName = lib.mkDefault "pine";

  environment.systemPackages = with pkgs; [
    file
    gitMinimal
    (htop.override {
      # pulls in lots of stuff
      sensorsSupport = false;
    })
    iperf3
    lsof
    nano
    nmap
    p7zip
    picocom
    psmisc
    rsync
    tio
    tree
    unrar
    unzip
    usbutils
    wget
    which
    whois
    zip
  ];

  # Time zone.
  time.timeZone = lib.mkDefault "Europe/Stockholm";

  programs = {
    # Quality of life
    starship.enable = true;
    tmux.enable = true;

    # Editors
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

  # Specific settings for nixos-rebuild
  # nixos-rebuild build-vm --flake .#<config>
  # result/bin/run-<config>-vm
  # ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no root@localhost -p 2221
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;

      # use native qemu
      host.pkgs = pkgs.buildPackages;
      qemu.package = pkgs.buildPackages.qemu;

      # Map ssh port
      forwardPorts = [
        {
          host.port = 2221;
          guest.port = 22;
        }
      ];
    };
    users.users.root.password = "pass";
    services.openssh.settings = {
      PasswordAuthentication = lib.mkForce true;
      KbdInteractiveAuthentication = lib.mkForce true;
      PermitRootLogin = "yes";
    };
  };

}
