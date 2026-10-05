{ config, pkgs, pkgsLib, scratchPadWidth, scratchPadHeight }:
pkgs.writeShellApplication {
  name = "setupScratchpad";
  meta.mainProgram = "setupScratchpad";
  runtimeInputs = with pkgs; [ coreutils gnugrep ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail


    WIDTH=${toString scratchPadWidth}
    HEIGHT=${toString scratchPadHeight}

    # Unique app_id so the steps below can address the spawned window via
    # sway criteria instead of relying on it having keyboard focus. The old
    # implementation slept a fixed 0.5s and then resized *whatever had
    # focus*: on a cold start the terminal could take longer than that to
    # map, so `swaymsg resize set` failed with "Cannot resize nothing" and
    # (under `set -e`) the script aborted before `move scratchpad`, leaving
    # the scratchpad empty forever -- which made the Mod4+Shift+equal
    # binding a no-op ("Scratchpad is empty").
    CLASS=kittyScratchpadInit

    # Passed as ONE quoted sway command: swaymsg would otherwise try to parse
    # the terminal's own flags (e.g. --class) as swaymsg CLI options.
    swaymsg "exec ${pkgsLib.getExe config.terminal.terminalEmulatorPkg} --class $CLASS ${config.terminal.shellStartCmd}"

    # Wait (up to ~20s) for the window to actually map before touching it.
    found=""
    for _ in {1..100}; do
      if swaymsg -t get_tree | grep -q "\"app_id\": \"$CLASS\""; then
        found=1
        break
      fi
      sleep 0.2
    done
    if [[ -z "$found" ]]; then
      echo "setupScratchpad: terminal window never appeared" >&2
      exit 1
    fi

    # Criteria-based: these act on the matched window whether or not it
    # currently has focus.
    swaymsg "[app_id=\"$CLASS\"] resize set width $WIDTH height $HEIGHT"
    sleep 0.2 # Small delay to let the resize apply before moving off-screen
    swaymsg "[app_id=\"$CLASS\"] move scratchpad"
  '';
}
