{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    zsh
    fzf
    bat
    ripgrep
    sops
    inputs.actual-nix.packages."${pkgs.system}".actual-server
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

