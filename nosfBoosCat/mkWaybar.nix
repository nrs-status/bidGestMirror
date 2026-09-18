{ pkgs, pkgsLib, ... }:
{ waybarSettingsAttrs, waybarStyleAttrs }:
let
  waybarFiles =
    import ./mkWaybarFiles.nix
      {
        inherit pkgsLib pkgs;
      }
      {
        settings = waybarSettingsAttrs;
        style = waybarStyleAttrs;
      };
in
pkgs.stdenv.mkDerivation {
  pname = "waybar";
  version = pkgs.waybar.version;

  src = pkgs.waybar;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/waybar $out/bin
    ln -s ${waybarFiles.config} $out/share/waybar/config.json
    ln -s ${waybarFiles.style}  $out/share/waybar/style.css

    makeWrapper ${pkgs.waybar}/bin/waybar $out/bin/waybar \
      --add-flags "-c $out/share/waybar/config.json -s $out/share/waybar/style.css"

    runHook postInstall
  '';

  passthru = { inherit (waybarFiles) config style; };
}
