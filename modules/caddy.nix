{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts = {
      "actual-1.murtazaa.com" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:5006 {
            header_up Host {host}
            header_up X-Real-IP {remote}
          }
        '';
      };
      "actual-2.murtazaa.com" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:5007 {
            header_up Host {host}
            header_up X-Real-IP {remote}
          }
        '';
      };
    };
  };
 }
