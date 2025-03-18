{ }:
{
  # Bring in any extra packages
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Global overlays
  modifications = final: prev: {

    # https://github.com/NixOS/nixpkgs/issues/359616
    pixman = prev.pixman.overrideAttrs (oldAttrs: rec {
      pname = "pixman";
      version = "0.44.2";
      src = prev.pkgs.fetchurl {
        urls = [
          "mirror://xorg/individual/lib/${pname}-${version}.tar.gz"
          "https://cairographics.org/releases/${pname}-${version}.tar.gz"
        ];
        hash = "sha256-Y0kGHOGjOKtpUrkhlNGwN3RyJEII1H/yW++G/HGXNGY=";
      };
      mesonFlags = [ ];
    });

    # https://github.com/NixOS/nixpkgs/pull/348566
    ruby = prev.ruby.overrideAttrs (oldAttrs: {
      postInstall = ''
        find "$out/${oldAttrs.passthru.gemPath}" -name exts.mk -delete
      '' + oldAttrs.postInstall;
    });

  };
}
