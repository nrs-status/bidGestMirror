{
  pkgs,
  pkgsLib,
  ...
}:
{
  config = {
    buildInputs = [ pkgs.pulseaudio ];
    swayConfigAttrs = {
      keybindings = {
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgsLib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgsLib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 -5%";
        "XF86AudioMute" = "exec --no-startup-id ${pkgsLib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute 0 toggle";
      };
    };
  };
}
