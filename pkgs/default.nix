{ pkgs }:
{
  linux_bbb = pkgs.callPackage ./bbb-kernel.nix { };
}
