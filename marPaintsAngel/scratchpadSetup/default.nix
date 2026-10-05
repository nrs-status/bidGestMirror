{
  pkgs,
  pkgsLib,
  config,
  ...
}:
{
  options = {
    scratchPadWidth = pkgsLib.mkOption {
      type = pkgsLib.types.int;
      default = 1366;
    };
    scratchPadHeight = pkgsLib.mkOption {
      type = pkgsLib.types.int;
      default = 765;
    };
  };

  config.swayConfigAttrs = {
    startup = [
      {
        command = pkgsLib.getExe (
          import ./setupScratchpad.nix {
            inherit
              pkgs
              pkgsLib
              config
              ;
            inherit (config) scratchPadWidth scratchPadHeight;
          }
        );
      }
    ];
    keybindings = {
      # Meta+Shift+= (the physical combo on a US layout) must trigger the
      # scratchpad. sway cannot match a `Mod4+plus` bindsym against that
      # keypress: bindsym keysyms are translated to keycodes using the
      # *unshifted* level of the active keymap (us,ca(fr),es), and no key in
      # these layouts produces `plus` without Shift, so the binding never
      # matches the Mod4+Shift+<equal> event (verified empirically with a
      # virtual keyboard on sway 1.12). Bind the combo as the event actually
      # arrives.
      "${config.swayConfigAttrs.modifier}+Shift+equal" = "scratchpad show";
    };
  };
}
