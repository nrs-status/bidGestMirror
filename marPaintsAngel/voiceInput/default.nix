{ pkgsLib, config, ... }:
{
  options = {
    voiceInputPkg = pkgsLib.mkOption { };
  };
  config = {
    buildInputs = [ config.voiceInputPkg ];
    swayConfigAttrs = {
      extraConfig = ''
        bindcode --no-repeat 191 exec --no-startup-id ${pkgsLib.getExe config.voiceInputPkg} start
        bindcode --no-repeat --release 191 exec --no-startup-id ${pkgsLib.getExe config.voiceInputPkg} finish

      '';
    };
  };
}
