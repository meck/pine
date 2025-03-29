
# Pine: Pine Is Nix Embedded

This is an experiment in using [Nix](https://nixos.org/) to build reproducible images for
embedded systems using cross-compilation.

It uses [disko](https://github.com/nix-community/disko) and
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) for initial
deployment and target systems can later be updated via a remote `nixos-rebuild`
Currently the only defined target is Beaglebone Black

# Images

The following images are available:

- `bbb-standard` A generic image using `pine-bbb-standard-sd`
- `bbb-sd-installer` A minimal image for installing to the internal emmc 

# NixOS configurations

The flake can build the following NixOs configurations

- `pine-bbb-installer` A minimal installer config, not to be used directly
   but for building SD card image.

- `pine-bbb-standard-sd` A config for running of the sd-card, can be basis
   for a custom config.

- `pine-bbb-standard-emmc` A config for running of BeagleBone internal emmc
  meant to be written using `nixos-anywhere` when running `sd-installer` of
  the SD card

> [!IMPORTANT]  
> Most of the building is done cross compiled but some steps (disko) uses QEMU
> this requires running `armv7l-linux` code using `binfmt`, in NixOS set
> `binfmt.emulatedSystems = [ "armv7l-linux" ];` otherwise building won't work,
> for other distros check documentation

## Building and installing standard image to an SD Card

1. Build and run the image generator 
```
nix build .#images.bbb-standard
./result
```

2. Write to sd-card use dd or bmaptool
```
sudo bmaptool copy ./pine-sdcard.raw /dev/<SD-card>
```

## Building and installing standard image to emmc

1. Build and run the installer image generator
```
nix build .#images.bbb-installer
./result
```

2. write to sd-card use dd or bmaptool
```
sudo bmaptool copy ./pine-installer-sdcard.raw /dev/<SD-card>
```

3. Boot from the SD Card

4. Install to emmc using nixos-anywhere
   - Figure out the IP of the board (`ip a`)
   - Login is 'pine'/'pass' and ssh is enabled

```
nix run .#nixos-anywhere -- --flake .#pine-bbb-standard-emmc --target-host pine@<target-ip> --build-on local
```

## Updating an existing install using nixos-rebuild

```
nixos-rebuild <switch or boot> --flake .#<nixosConfiguration> --target-host pine@<target-ip> --use-remote-sudo
```

> [!NOTE]  
> Replace `nixosConfiguration` with `pine-bbb-standard-emmc` or
> `pine-bbb-standard-sd` if running from sd-card


## TODO

- [ ] Expand partition on first boot when built for SD card
- [ ] Look into `disk-by/partition-label` issue
