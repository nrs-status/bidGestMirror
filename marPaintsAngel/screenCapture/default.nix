{
  config,
  pkgsLib,
  pkgs,
  ...
}:
{
  options = {
    screenCaptureDir = pkgsLib.mkOption { };
  };
  config = {
    buildInputs = [
      pkgs.grim
    ];
    swayConfigAttrs = {
      keybindings = {
        "${config.swayConfigAttrs.modifier}+p" =
          "exec --no-startup-id ${pkgs.grim}/bin/grim ${config.screenCaptureDir}/$(date +%F-%T).png";
        "Print" =
          "exec --no-startup-id ${pkgs.grim}/bin/grim ${config.screenCaptureDir}/$(date +%F-%T).png && wl-copy < ${config.screenCaptureDir}/$(date +%F-%T).png";
      };
    };
  };
}
