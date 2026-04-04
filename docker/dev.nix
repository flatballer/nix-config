# Docker dev image: nvim + all CLI tools.
# Build:  nix build .#packages.x86_64-linux.dockerDev
# Load:   docker load < result
# Run:    docker run --rm -it dev-env
{ pkgs, nvim }:
pkgs.dockerTools.streamLayeredImage {
  name = "dev-env";
  tag = "latest";
  contents = with pkgs; [
    nvim
    nixd
    alejandra
    ruff
    uv
    ty
    bat
    fzf
    zoxide
    gh
    eza
    carapace
    nmap
    tree-sitter
    # Shell
    bashInteractive
    coreutils
    findutils
    gnugrep
    gnused
    curl
    git
    # Node needed by copilot.lua inside nvim
    nodejs
  ];
  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
    Env = [
      "TERM=xterm-256color"
      "COLORTERM=truecolor"
    ];
  };
}
