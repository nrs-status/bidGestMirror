{ pkgs, pkgsLib, ... }:
{ swayConfigAttrs }:
let
  swayConfig = import ./mkSwayConfig.nix { inherit pkgsLib pkgs; } swayConfigAttrs;
  sway-wrapped = pkgs.writeShellScriptBin "sway" ''
    exec ${pkgs.sway}/bin/sway -c ${swayConfig} "$@"
  '';
in
pkgs.symlinkJoin {
  name = "sway";
  paths = [ sway-wrapped ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    # Template: add wrapper args here as needed, e.g.
    #   --prefix PATH : ''${pkgs.lib.makeBinPath [ pkgs.someRuntimeDep ]}
    wrapProgram $out/bin/sway
  '';
}
