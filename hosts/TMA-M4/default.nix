{ pkgs, lib, ... }:
let
  ghosttyConfig = pkgs.writeText "ghostty-config" (builtins.readFile ../../ghostty/config);
in
{
  imports = [ ../../modules/darwin/base.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "linking ghostty config..." >&2
    mkdir -p /Users/thomasmargraf/.config/ghostty
    ln -sfn "${ghosttyConfig}" /Users/thomasmargraf/.config/ghostty/config
  '';
}
