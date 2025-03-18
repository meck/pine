{ lib, config, ... }:

with lib;
let
  cfg = config.pine;
in
{

  options.pine.defaultUser = mkEnableOption "Enable pine user";

  config = mkIf cfg.defaultUser {
    # main user
    users.users.pine = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$w19Ktxjl4DKHSuLZ9/Qhp1$ni/fd4DfRAjT9IeZbD5XScvy5MQdJwF7iWx5IHA1faA"; # `pass`
      extraGroups = [
        "wheel"
        "dialout"
      ];
    };

    # Allow passwordless sudo from wheel group
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
