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
      type = types.str;
      description = "The target architecture";
    };

    crossBuildSystem = mkOption {
      type = types.str;
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
        diskoPkgs = self.inputs.nixpkgs.legacyPackages."${cfg.crossBuildSystem}";
      in
      {
        enableBinfmt = true;
        pkgs = diskoPkgs;
        kernelPackages = diskoPkgs.linuxPackages_latest;
      };

  };
}
