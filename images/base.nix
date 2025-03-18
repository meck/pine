{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    outputs.nixosModules.pine
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  # Main cfg options
  pine.enable = true;

  system.stateVersion = "24.11";
}
