{
  lib,
  config,
  self,
  ...
}:

with lib;
let
  cfg = config.pine;
in

{

  options.pine = {
    crossHostSystem = mkOption {
      type = types.either types.str types.attrs;
      example = {
        system = "armv7l-linux";
      };
    };

    crossBuildSystem = mkOption {
      type = types.either types.str types.attrs;
      example = {
        system = "aarch64-linux";
      };
      description = "The build architecture";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs = {
      config.allowUnsupportedSystem = true;
      hostPlatform = cfg.crossHostSystem;
      buildPlatform = cfg.crossBuildSystem;
    };

    disko.imageBuilder =
      let
        diskoPkgs = self.inputs.nixpkgs.legacyPackages."${config.nixpkgs.buildPlatform.system}";
      in
      {
        enableBinfmt = true;
        pkgs = diskoPkgs;
        kernelPackages = diskoPkgs.linuxPackages_latest;
      };

  };
}
