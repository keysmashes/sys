{ config, ... }:

{
  programs.less.enable = true;
  programs.lesspipe.enable = true;
  home.sessionVariables = {
    LESS = "-iMR --use-color --no-edit-warn";
    LESSHISTFILE = "${config.xdg.cacheHome}/lesshst";
    LESSQUIET = 1;
  };
}
