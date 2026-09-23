{ ... }:
{
  swayConfigAttrs =
    let
      gruvbox = import ./gruvboxColors.nix;
    in
    {
      colors = {
        background = gruvbox.dark.bg;
        focused = {
          background = gruvbox.dark.bg;
          border = gruvbox.dark.bg;
          childBorder = gruvbox.dark.bg2;
          indicator = gruvbox.dark.bg4;
          text = gruvbox.dark.fg;
        };
        focusedInactive = {
          background = gruvbox.dark.bg;
          border = gruvbox.dark.bg;
          childBorder = gruvbox.dark.bg0_h;
          indicator = gruvbox.dark.bg0_h;
          text = gruvbox.dark.gray;
        };
        "placeholder" = {
          background = gruvbox.dark.bg0_s;
          border = gruvbox.dark.bg0_s;
          childBorder = gruvbox.dark.bg0_s;
          indicator = gruvbox.dark.bg0_s;
          text = gruvbox.dark.fg;
        };
        unfocused = {
          background = gruvbox.dark.bg2;
          border = gruvbox.dark.bg;
          childBorder = gruvbox.dark.bg0_h;
          indicator = gruvbox.dark.bg0_h;
          text = gruvbox.dark.gray;
        };
        urgent = {
          background = gruvbox.light.red.normal;
          border = gruvbox.light.red.normal;
          childBorder = gruvbox.light.red.normal;
          indicator = gruvbox.light.red.normal;
          text = gruvbox.dark.fg;
        };
      };

      gaps.smartBorders = "no_gaps";

      floating = {
        border = 4;
        titlebar = true;
      };
      fonts = {
        names = [ "Iosevka Proportional" ];
        size = 11.0;
      };

      window = {
        border = 1;
        titlebar = false;
        commands = [
          {
            criteria = {
              app_id = "kitty";
            };
            command = "opacity 0.90";
          }

        ];
      };

    };
}
