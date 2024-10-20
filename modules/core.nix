{ config, pkgs, inputs, ... }:

{
  imports = [
    ./packages.nix
    ./users.nix
    ./zsh.nix
    ./docker.nix
    ./sops.nix
    ./tailscale.nix
    ./caddy.nix
    ./actual.nix
    ./dns-server.nix
  ];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 443 80 ];
  };

}

