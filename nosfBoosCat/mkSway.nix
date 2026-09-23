{
  pkgs,
  pkgsLib,
  ...
}:
{ modules, specialArgs }:
let
  baseModule = {
    options = {
      # The attrset consumed by nosfBoosCat/mkSway.nix.
      swayConfigAttrs = pkgsLib.mkOption {
        default = { };
        description = "Attribute set of sway configuration rendered by mkSway.";
        type = pkgsLib.types.submodule {
          # Any sway option is allowed; `anything` deep-merges nested attrsets
          # so the modules can each extend e.g. `focus` or `window`.
          freeformType = pkgsLib.types.anything;
          options = {
            modifier = pkgsLib.mkOption {
              type = pkgsLib.types.str;
            };
            # Merged across modules, so an attrset is required (not `anything`,
            # which refuses to merge two list/leaf definitions).
            keybindings = pkgsLib.mkOption {
              type = pkgsLib.types.attrsOf pkgsLib.types.str;
              default = { };
            };
            startup = pkgsLib.mkOption {
              type = pkgsLib.types.listOf pkgsLib.types.anything;
              default = [ ];
            };
            # `lines` concatenates the contributions of several modules.
            extraConfig = pkgsLib.mkOption {
              type = pkgsLib.types.lines;
              default = "";
            };
          };
        };
      };

      buildInputs = pkgsLib.mkOption {
        type = pkgsLib.types.listOf pkgsLib.types.package;
        default = [ ];
      };

      time.timezone = pkgsLib.mkOption {
        type = pkgsLib.types.str;
        default = "UTC";
      };
    };
  };
  evaluatedModules = pkgsLib.evalModules {
    modules = [ baseModule ] ++ modules;
    inherit specialArgs;
  };
  # mkSwayConfig replaces the whole `focus`/`floating`/`window` sub-attrsets
  # when a caller supplies one, dropping the built-in defaults for the fields
  # the modules do not set. Fill those in without touching the modules.
  swayConfigAttrs = pkgsLib.recursiveUpdate {
    focus = {
      wrapping = "no";
      followMouse = "yes";
      newWindow = "smart";
      mouseWarping = true;
    };
    floating = {
      modifier = "Mod1";
      criteria = [ ];
      titlebar = true;
      border = 2;
    };
    window = {
      titlebar = true;
      border = 2;
      commands = [ ];
      hideEdgeBorders = "none";
    };
  } evaluatedModules.config.swayConfigAttrs;
  swayConfig = import ./mkSwayConfig.nix { inherit pkgsLib pkgs; } swayConfigAttrs;
  # Modules' `buildInputs` are runtime deps for their sway config commands
  # (and for scripts spawned by sway, which inherit this PATH).
  # nixpkgs' `sway` package ships `sway`, `swaymsg`, and `swaynag` in one
  # `bin/`, so it must not go into `buildInputs` (that would put the
  # unwrapped `sway` binary on PATH, bypassing `-c ${swayConfig}`);
  # `swaymsg-only` exists for callers that need `swaymsg` on PATH.
  swayBinPath = pkgs.lib.makeBinPath
    (evaluatedModules.config.buildInputs ++ [ swaymsg-only ]);
  swaymsg-only =
    pkgs.runCommand "swaymsg-only"
      {
        meta.mainProgram = "swaymsg";
        passthru = { inherit (pkgs.sway) version; }; # keep versioning info
      }
      ''
        mkdir -p $out/bin
        ln -s ${pkgs.sway}/bin/swaymsg $out/bin/swaymsg
      '';
  sway-wrapped = pkgs.writeShellScriptBin "sway" ''
    exec ${pkgs.sway}/bin/sway -c ${swayConfig} "$@"
  '';
in
pkgs.symlinkJoin {
  name = "sway";
  paths = [ sway-wrapped ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/sway \
      --suffix PATH : ${swayBinPath}
  '';
}
