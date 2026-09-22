{ config, pkgs, pkgsLib, shellStartCmd, scratchPadWidth, scratchPadHeight }:
pkgs.writeShellApplication {
  name = "setupWorkspaces";
  meta.mainProgram = "setupWorkspaces";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail


    WIDTH=${scratchPadWidth}
    HEIGHT=${scratchPadHeight}

    swaymsg exec ${pkgsLib.getExe config.terminalEmulatorPkg} ${shellStartCmd}
    sleep 0.5 # Wait for the new window to appear and gain focus
    swaymsg resize set width "$WIDTH" height "$HEIGHT"
    sleep 0.2 # Small delay to let the resize apply before moving off-screen
    swaymsg move scratchpad

  '';
}
