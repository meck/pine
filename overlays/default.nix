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
      postInstall =
        ''
          find "$out/${oldAttrs.passthru.gemPath}" -name exts.mk -delete
        ''
        + oldAttrs.postInstall;
    });

    # Use newer with gpio-manger
    libgpiod = prev.libgpiod.overrideAttrs (oldAttrs: rec {
      version = "2.2.1";

      src = final.fetchgit {
        url = "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git";
        tag = "v${version}";
        hash = "sha256-BVVHyRmgLLUgc3qLHOXiLYaTjsPMntvIP1os9eL8v74=";
      };

      buildInputs =
        oldAttrs.buildInputs or [ ]
        ++ (with final; [
          glib
          libgudev
        ]);

      nativeBuildInputs =
        oldAttrs.nativeBuildInputs or [ ]
        ++ (with final.buildPackages; [
          glib # gdbus-codegen
        ]);

      postPatch =
        oldAttrs.postPatch or ""
        + ''
          sed -i -e "s#/usr/bin/gpio-manager#$out/bin/gpio-manager#g" dbus/data/gpio-manager.service 
        '';

      configureFlags = oldAttrs.configureFlags or [ ] ++ [
        "--enable-dbus"
        "--enable-systemd"
      ];

      systemdsystemunitdir = "${placeholder "out"}/lib/systemd/system";
    });

  };
}
