{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    zsh
    fzf
    bat
    ripgrep
    htop
    sops
    sqlite
    fd
    inputs.actual-nix.packages."${pkgs.system}".actual-server
    tailscale
    docker
    technitium-dns-server
    openssl
    jq
    caddy
    lazygit
  ];
}
