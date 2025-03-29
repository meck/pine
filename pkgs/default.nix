{ pkgs }:
{
  linux_bbb = pkgs.callPackage ./bbb-kernel.nix { };
  tatectl = pkgs.callPackage ./tatectl.nix { };
}
