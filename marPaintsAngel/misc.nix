{
  config,
  ...
}:
{
  config.swayConfigAttrs = {
    focus.followMouse = false;
    modifier = "Mod4";
    input = {
      "*" = {
        xkb_numlock = "disabled";
        xkb_layout = "us,ca(fr),es";
        xkb_options = "grp:alt_space_toggle";
      };
    };
    keybindings = {

      "${config.swayConfigAttrs.modifier}+Shift+a" = "focus child";
      # close the focused window
      "${config.swayConfigAttrs.modifier}+Shift+q" = "kill";
      # toggle fullscreen on the focused window
      "${config.swayConfigAttrs.modifier}+f" = "fullscreen toggle";
    };
  };
}
