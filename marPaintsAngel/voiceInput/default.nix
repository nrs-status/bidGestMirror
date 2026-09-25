{ config, pkgs, pkgsLib, ... }:
let
  # The voice-input script tracks recording state via the pid file declared in
  # it; extract that path so the toggle below stays in sync with the script.
  # Toggle dispatches on it: recording in progress -> finish, else start.
  voiceInputToggle = pkgs.writeShellScriptBin "voice-input-toggle" ''
    pidFile="$(sed -n 's/^pidFile=//p' "${pkgsLib.getExe config.voiceInputPkg}" | head -1)"
    if [ -n "$pidFile" ] && [ -f "$pidFile" ]; then
      exec "${pkgsLib.getExe config.voiceInputPkg}" finish "$@"
    else
      exec "${pkgsLib.getExe config.voiceInputPkg}" start
    fi
  '';
in
{
  options = {
    voiceInputPkg = pkgsLib.mkOption { };
  };
  config = {
    buildInputs = [ config.voiceInputPkg voiceInputToggle ];
    swayConfigAttrs = {
      extraConfig = ''
        bindcode --no-repeat 191 exec --no-startup-id ${pkgsLib.getExe voiceInputToggle}

      '';
    };
  };
}
