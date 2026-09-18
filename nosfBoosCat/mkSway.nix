{ pkgs, pkgsLib, ... }:
{ swayConfigAttrset }:
let
  swayConfig = import ./mkSwayConfig.nix { inherit pkgsLib pkgs; } swayConfigAttrset;
  sway-wrapped = pkgs.writeShellScriptBin "sway" ''
    exec ${pkgs.sway}/bin/sway -c ${swayConfig} "$@"                                                                                                                                                              
  '';
in
pkgs.symlinkJoin {
  name = "sway";
  paths = [ sway-wrapped ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/sway \                                                                                                                                                                                   
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.foot
          pkgs.j4-dmenu-desktop
        ]
      }                                                                                                                                 
  '';
}
