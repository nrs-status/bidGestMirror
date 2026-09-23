{ config, pkgsLib, pkgs, ... }:
{
  options = {
    screenCaptureDir = pkgsLib.mkOption {};
  };
  config = {
    swayConfigAttrs = {};
  };
}
