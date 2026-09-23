{
  pkgs,
  pkgsLib,
  config,
  ...
}:
{
  imports = [ ../terminal ];

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
      "${config.swayConfigAttrs.modifier}+plus" = "scratchpad show";
    };
  };
}
