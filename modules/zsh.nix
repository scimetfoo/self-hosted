{ config, pkgs, ... }:

{
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
}

