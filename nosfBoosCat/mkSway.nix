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
  # Fonts shipped by the modules' `buildInputs` (e.g. the Noto CJK fonts of
  # marPaintsAngel/extraFonts.nix) are not discovered by fontconfig just
  # because the packages are runtime deps of the wrapped sway. Two mechanisms
  # make them available to sway and every client it spawns:
  #
  #   * FONTCONFIG_FILE: a generated fontconfig configuration that includes
  #     the system fonts (/etc/fonts/fonts.conf) and adds the modules' font
  #     directories, so glyphs the primary font does not cover (e.g. mandarin
  #     characters such as 丨) fall back to the module-provided fonts.
  #
  #   * XDG_DATA_DIRS: fontconfig's stock config lists <dir prefix="xdg">
  #     fonts</dir>, so any client that (re)generates its own fontconfig from
  #     the system one — e.g. the kitty wrapper, which overrides
  #     FONTCONFIG_FILE with its own conf — still finds the module fonts
  #     through the XDG data directories.
  moduleFontsConf =
    pkgs.writeText "sway-module-fonts.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
        ${pkgs.lib.concatMapStringsSep "\n" (p: "<dir>${p}/share/fonts</dir>") evaluatedModules.config.buildInputs}
      </fontconfig>
    '';
  moduleShareDirs = pkgs.lib.makeSearchPath "share" evaluatedModules.config.buildInputs;
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
      --suffix PATH : ${swayBinPath} \
      --set FONTCONFIG_FILE ${moduleFontsConf} \
      --suffix XDG_DATA_DIRS : ${moduleShareDirs}
  '';
}
