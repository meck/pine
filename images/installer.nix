{ ... }:
{
  imports = [ ./base.nix ];

  # Much copied from nixpkgs/nixos/modules/profiles/installation-device.nix"

  # So nixos-anywhere dosen't want to kexec
  system.nixos.variant_id = "installer";

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "pine";

  networking.hostName = "pine-installer";

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
    };
  };

  # Make the installer more likely to succeed in low memory
  # environments.  The kernel's overcommit heustistics bite us
  # fairly often, preventing processes such as nix-worker or
  # download-using-manifests.pl from forking even if there is
  # plenty of free memory.
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

}
