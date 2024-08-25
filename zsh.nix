{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    zsh
    fzf
    bat
    sops
  ];

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "fzf" ];
    };
    shellInit = ''
      [ -f ${pkgs.fzf}/etc/profile.d/fzf.sh ] && source ${pkgs.fzf}/etc/profile.d/fzf.sh
      export PROMPT="%n@%m %1~ %# "
    '';
  };

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}

