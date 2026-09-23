{
  config,
  pkgs,
  pkgsLib,
  ...
}:
{

  config = {
    buildInputs = [ pkgs.wlsunset ];
    swayConfigAttrs.keybindings."${config.swayConfigAttrs.modifier}+semicolon" =
      "exec sh -c 'pkill -x ${pkgsLib.getExe pkgs.wlsunset} || { ${pkgsLib.getExe pkgs.wlsunset} -T 1 -t 0 & }'";
  };
}
