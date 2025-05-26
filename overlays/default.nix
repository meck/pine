{ }:
{
  # Bring in any extra packages
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # Global overlays
  modifications = final: prev: {

    # Enable build with systemd
    libgpiod = prev.libgpiod.overrideAttrs (oldAttrs: {

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
