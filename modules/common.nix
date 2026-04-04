# Shared packages available on all platforms (darwin + linux).
# Returns a list of derivations given `pkgs`.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixd
    alejandra
    ruff
    uv
    ty
    bat
    fzf
    zoxide
    nmap
    tree-sitter
    carapace
    gh
    eza
  ];
}
