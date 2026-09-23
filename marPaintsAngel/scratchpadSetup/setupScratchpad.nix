{ config, pkgs, pkgsLib, scratchPadWidth, scratchPadHeight }:
pkgs.writeShellApplication {
  name = "setupScratchpad";
  meta.mainProgram = "setupScratchpad";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail


    WIDTH=${toString scratchPadWidth}
    HEIGHT=${toString scratchPadHeight}

    swaymsg exec ${pkgsLib.getExe config.terminal.terminalEmulatorPkg} ${config.terminal.shellStartCmd}
    sleep 0.5 # Wait for the new window to appear and gain focus
    swaymsg resize set width "$WIDTH" height "$HEIGHT"
    sleep 0.2 # Small delay to let the resize apply before moving off-screen
    swaymsg move scratchpad

  '';
}
