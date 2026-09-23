{ pkgs, pkgsLib, config, ... }:
{
  config = {
    buildInputs = [ pkgs.mako pkgs.jq ];
    swayConfigAttrs = {
      keybindings = {
        # notification dump/clear: serialize every notification currently
        # displayed by mako (`makoctl list -j`) to a timestamped file in /tmp
        # (jq renders it as readable text: [urgency] app: summary, then body),
        # and only once the dump succeeded (`&&`) clear them from the
        # interface (`makoctl dismiss --all`; they remain recoverable from
        # mako's history via `makoctl restore`). sway `exec` runs the whole
        # command through `sh -c`, so the pipe, redirect and `$(date ...)`
        # are evaluated at binding-press time, not at config-generation time.
        "${config.swayConfigAttrs.modifier}+n" =
          ''exec --no-startup-id ${pkgs.mako}/bin/makoctl list -j | ${pkgsLib.getExe pkgs.jq} -r ".[] | \"[\(.urgency)] \(.app_name): \(.summary)\n\(.body)\n\"" > /tmp/mako-notifs_$(date +%F-%T).txt && ${pkgs.mako}/bin/makoctl dismiss --all'';
      };
    };
  };
}
