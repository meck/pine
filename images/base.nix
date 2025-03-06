{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    outputs.nixosModules.pine
    ./pine-user.nix
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  # Main cfg options
  pine.enable = true;

  system.stateVersion = "24.11";
}
