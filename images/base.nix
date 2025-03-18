{
  self,
  ...
}:
{
  imports = [
    self.outputs.nixosModules.pine
    "${self.inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
  ];

  system.stateVersion = "24.11";
}
