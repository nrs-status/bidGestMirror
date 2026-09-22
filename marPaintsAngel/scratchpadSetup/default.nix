{
  pkgs,
  wrappedPkgs,
  pkgsLib,
  config,
  ...
}:
{
  imports = [ ../terminal ];

  options = {
    shellStartCmd = pkgsLib.mkOption {
      type = pkgsLib.types.str;
      description = "command used by terminal emulator to start a shell";
    };
    scratchPadWidth = pkgsLib.mkOption { };
    scratchPadHeight = pkgsLib.mkOption { };
  };

  startup = [
    {
      command = pkgsLib.getExe (
        import ./setupScratchpad.nix {
          inherit
            pkgs
            pkgsLib
            wrappedPkgs
            ;
          shellStartCmd = config.shellStartCmd;
          scratchPadWidth = config.scratchPadWidth;
          scratchPadHeight = config.scratchPadHeight;

        }
      );
    }
  ];
}
