{ pkgs, ... }:
{
  imports = [ ../../modules/darwin/base.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";
}
