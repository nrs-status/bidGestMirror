{
  pkgs,
  pkgsLib,
  ...
}:
{
  config = {
    swayConfigAttrs = {
      buildInputs = [ pkgs.pulseaudio ];
      keybindings = {
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgsLib.getExe pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgsLib.getExe pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%";
        "XF86AudioMute" = "exec --no-startup-id ${pkgsLib.getExe pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
      };
    };
  };
}
