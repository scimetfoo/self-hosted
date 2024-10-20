{ config, pkgs, ... }:

{
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;  
  };
}
