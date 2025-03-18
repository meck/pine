{
  lib,
  fetchgit,
  buildLinux,
  ...
}@args:

buildLinux (
  args
  // rec {
    version = "6.12.13";
    modDirVersion = version;

    src = fetchgit {
      url = "https://openbeagle.org/beagleboard/linux.git";
      rev = "cfae991db6ae58b956ec044fd2965ed624327eb0";
      hash = "sha256-i8H35A3L+nO+vE9ynFSbxGNYdgtz27qvTACpippg+bM=";
    };

    structuredExtraConfig = with lib.kernel; {
      BT = no;
      WLAN = no;
      EFI = no;
      CONFIG_WLAN = no;

      CONFIG_MTD = no;
      CONFIG_ROMFS_BACKED_BY_BLOCK = yes;
    };

    defconfig = "bb.org_defconfig";
  }
  // (args.argsOverride or { })
)
