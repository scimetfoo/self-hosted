{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    clientMaxBodySize = "0";
    resolver = {
      addresses = [ "8.8.8.8" "8.8.4.4" ];
      valid = "300s";
    };

    virtualHosts."nixos.tailcf19f1.ts.net" = {
      forceSSL = true;
      sslCertificate = "/etc/ssl/tailscale/cert.pem";
      sslCertificateKey = "/etc/ssl/tailscale/key.pem";
      serverName = "nixos.tailcf19f1.ts.net";

      locations = {
        "/" = {
          return = "302 /actual/1/";
        };

        "/actual/1/" = {
          proxyPass = "http://127.0.0.1:5006";
          proxyWebsockets = true;
        };

        "/actual/2/" = {
          proxyPass = "http://127.0.0.1:5007";
          proxyWebsockets = true;
        };

        "/static/" = {
          proxyPass = "http://127.0.0.1:5006";
        };

        "= /apple-touch-icon.png" = {
          proxyPass = "http://127.0.0.1:5006";
        };

        "= /favicon-32x32.png" = {
          proxyPass = "http://127.0.0.1:5006";
        };

        "= /registerSW.js" = {
          proxyPass = "http://127.0.0.1:5006";
        };
      };

      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        add_header 'Cross-Origin-Embedder-Policy' 'require-corp' always;
        add_header 'Cross-Origin-Opener-Policy' 'same-origin' always;
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'HEAD, GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization' always;
      '';
    };
  };

  services.nginx.logError = "stderr debug";
}
