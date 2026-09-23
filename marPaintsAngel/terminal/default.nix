{
  config,
  pkgsLib,
  ...
}:
{
  options = {
    terminal = {
      terminalEmulatorPkg = pkgsLib.mkOption { };

      shellStartCmd = pkgsLib.mkOption {
        type = pkgsLib.types.str;
        description = "command used by terminal emulator to start the default shell. used by workspacesSetup and scratchpadSetup modules";
      };
    };
  };
  config = {
    buildInputs = [
      config.terminal.terminalEmulatorPkg

    ];
    swayConfigAttrs = {
      terminal = (pkgsLib.getExe config.terminal.terminalEmulatorPkg);
      keybindings = {
        "${config.swayConfigAttrs.modifier}+Return" =
          "exec ${pkgsLib.getExe config.terminal.terminalEmulatorPkg} ${config.terminal.shellStartCmd}";
        "${config.swayConfigAttrs.modifier}+Shift+backslash" = "splith";
        "${config.swayConfigAttrs.modifier}+minus" = "splitv";
      };
    };

  };
}
