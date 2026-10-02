{
  config,
  pkgsLib,
  pkgs,
  ...
}:
let
  # Overlay screenshot tool: `slurp` draws a full-screen overlay over the
  # window manager in which the user drags a rectangle to select an area;
  # `grim` then captures exactly that region and `wl-copy` puts it on the
  # clipboard. Cancelling the selection (Escape) aborts cleanly.
  areaScreenshot = pkgs.writeShellScript "area-screenshot" ''
    dir=${config.screenCaptureDir}
    mkdir -p "$dir"
    geometry=$(${pkgs.slurp}/bin/slurp) || exit 0
    file="$dir/$(date +%F-%T).png"
    ${pkgs.grim}/bin/grim -g "$geometry" "$file" \
      && ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  '';
in
{
  options = {
    screenCaptureDir = pkgsLib.mkOption { };
  };
  config = {
    buildInputs = [
      pkgs.grim
      pkgs.slurp
    ];
    swayConfigAttrs = {
      keybindings = {
        "${config.swayConfigAttrs.modifier}+p" =
          "exec --no-startup-id ${pkgs.grim}/bin/grim ${config.screenCaptureDir}/$(date +%F-%T).png";
        "Print" =
          "exec --no-startup-id ${pkgs.grim}/bin/grim ${config.screenCaptureDir}/$(date +%F-%T).png && wl-copy < ${config.screenCaptureDir}/$(date +%F-%T).png";
        # Meta+sysrq: `sysrq` is the name keyd reports for the Print Screen
        # key (evdev KEY_SYSRQ). Sway bindsyms are XKB keysyms, and the keysym
        # produced by that key (both directly and through keyd's default
        # passthrough) is `Print`.
        "${config.swayConfigAttrs.modifier}+Print" =
          "exec --no-startup-id ${areaScreenshot}";
      };
    };
  };
}
