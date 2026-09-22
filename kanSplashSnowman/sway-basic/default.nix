{
  pkgs,
  localLib,
  pkgsLib,
  wrappedPkgs,
  ...
}:
pkgsLib.makeOverridable localLib.mkSway rec {
  shellStartCmd = "bash";
  swayConfigAttrs = {
    focus.followMouse = false;
    modifier = "Mod4";
    terminal = "${wrappedPkgs.kitty}/bin/kitty";
    input = {
      "*" = {
        xkb_numlock = "disabled";
        xkb_layout = "us,ca(fr),es";
        xkb_options = "grp:alt_space_toggle";
      };
    };
    startup = [
      { command = "${pkgsLib.getExe pkgs.mako}"; }
      {
        command = "${pkgsLib.getExe (
          import ./setupWorkspaces.nix {
            inherit
              pkgs
              pkgsLib
              wrappedPkgs
              shellStartCmd
              ;
          }
        )}";
      }
    ];

  };
}
