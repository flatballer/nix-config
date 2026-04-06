{ pkgs, self, ... }:
{
  imports = [ ../../modules/darwin/base.nix ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.activationScripts.ghosttyConfig.text = ''
    mkdir -p /Users/thomasmargraf/.config/ghostty
    ln -sfn "${self}/ghostty/config" /Users/thomasmargraf/.config/ghostty/config
  '';
}
