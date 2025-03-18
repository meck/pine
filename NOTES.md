
# Misc notes

## Configure kernel using menuconfig

Run the following:

```
nix develop .#nixosConfigurations.pine-bbb-standard-emmc.pkgs.linux_bbb.configEnv
unpackPhase
cd linux-*
patchPhase
make ARCH=arm "bb.org_defconfig"
make ARCH=arm menuconfig
# Do changes
diff --unchanged-line-format= --old-line-format= --new-line-format="%L" .config.old .config
````

Add the diff values to `structuredExtraConfig`
