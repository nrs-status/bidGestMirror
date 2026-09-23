{
  config,
  pkgs,
  pkgsLib,
  ...
}:
{

  config = {
    buildInputs = [ pkgs.grim ];
    swayConfigAttrs.keybindings."${config.swayConfigAttrs.modifier}+r" =
      ''exec ${pkgsLib.getExe pkgs.grim} -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n 1 | cut -d ' ' -f 4 | wl-copy'';
  };
}
