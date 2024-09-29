{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  users.users.nginx = {
    isSystemUser = true;
    extraGroups = [ "ssl-cert" ];
  };
}

