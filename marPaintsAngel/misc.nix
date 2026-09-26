{
  config,
  pkgs,
  ...
}:
{
  config = {
    buildInputs = with pkgs; [
      libnotify # has notify-send
      wl-clipboard # has wl-copy
    ];
    swayConfigAttrs = {
      focus.followMouse = false;
      modifier = "Mod4";
      input = {
        "*" = {
          xkb_numlock = "disabled";
          xkb_layout = "us,ca(fr),es";
          xkb_options = "grp:alt_space_toggle";
        };
      };
      keybindings =
        let
          mod = config.swayConfigAttrs.modifier;
        in
        {
          "${mod}+Shift+a" = "focus child";
          "${mod}+Shift+q" = "kill";
          "${mod}+f" = "fullscreen toggle";
        };
    };
  };
}
