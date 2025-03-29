{
  image-standard = import ./standard.nix; # System image
  image-installer = import ./installer.nix; # SD-card installer
  image-tate = import ./tate.nix;
}
