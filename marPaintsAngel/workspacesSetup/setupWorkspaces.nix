{ config, pkgs, pkgsLib, wrappedPkgs }:
pkgs.writeShellApplication {
  name = "setupWorkspaces";
  meta.mainProgram = "setupWorkspaces";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    swaymsg "workspace 1; exec ${pkgsLib.getExe wrappedPkgs.firefox}"
    swaymsg "workspace 2; exec ${pkgsLib.getExe config.terminal.terminalEmulatorPkg} ${config.terminal.shellStartCmd}"
  '';
}
