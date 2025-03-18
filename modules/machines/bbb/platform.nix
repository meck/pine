{
  # Adapted from `armv7l-hf-multiplatform` in nixpkgs/lib/systems/platforms.nix
  config = "armv7l-unknown-linux-gnueabihf";
  linux-kernel = {
    name = "beaglebone";
    Major = "2.6";
    baseConfig = "bb.org_defconfig";
    DTB = true;
    autoModules = false;
    preferBuiltin = true;
    target = "zImage";
    extraConfig = '''';
  };
  gcc = {
    arch = "armv7-a";
    fpu = "neon";
  };
  isEfi = false;
}
