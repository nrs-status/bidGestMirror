# Extracted from home-manager:
#   modules/services/window-managers/i3-sway/pkgsLib/functions.nix
#   modules/services/window-managers/i3-sway/sway.nix (configFile)
#
# Adapted to be standalone: no `cfg` module argument, no pkgsLib.hm.* helpers.
# Usage:
#   swayConf = import ./sway-pkgsLib.nix { inherit (pkgs) pkgsLib writeTextFile sway; } {
#     keybindings = { "Mod4+Return" = "exec foot"; "Mod4+q" = "kill"; };
#     input."type:keyboard".xkb_layout = "de";
#     startup = [ { command = "mako"; always = false; } ];
#     extraConfig = "include /etc/sway/config.d/*";
#   };
{
  pkgsLib,
  pkgs,
  checkConfig ? true,
}:
let
  inherit (pkgsLib) concatStringsSep mapAttrsToList optionalString;

  yesNo = b: if b then "yes" else "no";

  criteriaStr =
    criteria:
    let
      toCriteria =
        k: v:
        if builtins.isBool v then
          (if v then "${k}" else "")
        else
          ''${k}="${v}"'';
    in
    "[${concatStringsSep " " (mapAttrsToList toCriteria criteria)}]";

  keybindingsStr =
    {
      keybindings,
      bindsymArgs ? "",
      indent ? "",
    }:
    concatStringsSep "\n" (
      mapAttrsToList (
        keycomb: action:
        optionalString (action != null)
          "${indent}bindsym ${pkgsLib.optionalString (bindsymArgs != "") "${bindsymArgs} "}${keycomb} ${action}"
      ) keybindings
    );

  keycodebindingsStr =
    keycodebindings:
    concatStringsSep "\n" (
      mapAttrsToList (
        keycomb: action: optionalString (action != null) "bindcode ${keycomb} ${action}"
      ) keycodebindings
    );

  colorSetStr =
    c:
    concatStringsSep " " [
      c.border
      c.background
      c.text
      c.indicator
      c.childBorder
    ];
  barColorSetStr =
    c:
    concatStringsSep " " [
      c.border
      c.background
      c.text
    ];

  modeStr =
    bindkeysToCode: name: keybindings:
    ''
      mode "${name}" {
      ${keybindingsStr {
        inherit keybindings;
        bindsymArgs = pkgsLib.optionalString bindkeysToCode "--to-code";
        indent = "  ";
      }}
      }
    '';

  assignStr =
    workspace: criteria:
    concatStringsSep "\n" (map (c: "assign ${criteriaStr c} ${workspace}") criteria);

  fontConfigStr =
    let
      toFontStr =
        {
          names,
          style ? "",
          size ? "",
        }:
        optionalString (names != [ ])
          concatStringsSep " " (
            pkgsLib.remove "" [
              "font"
              "pango:${concatStringsSep ", " names}"
              style
              size
            ]
          );
    in
    fontCfg:
    if pkgsLib.isList fontCfg then
      toFontStr { names = fontCfg; }
    else
      toFontStr {
        inherit (fontCfg) names;
        style = fontCfg.style or "";
        size = toString (fontCfg.size or "");
      };

  barStr =
    {
      id,
      fonts,
      mode,
      hiddenState,
      position,
      workspaceButtons,
      workspaceNumbers,
      command,
      statusCommand,
      colors,
      trayOutput,
      trayPadding,
      extraConfig,
      ...
    }:
    let
      colorsNotNull = pkgsLib.filterAttrs (_n: v: v != null) colors != { };
    in
    pkgsLib.concatMapStrings (x: x + "\n") (
      indent
        (pkgsLib.lists.subtractLists [ "" null ] (
          pkgsLib.flatten [
            "bar {"
            (optionalString (id != null) "id ${id}")
            (fontConfigStr fonts)
            (optionalString (mode != null) "mode ${mode}")
            (optionalString (hiddenState != null) "hidden_state ${hiddenState}")
            (optionalString (position != null) "position ${position}")
            (optionalString (statusCommand != null) "status_command ${statusCommand}")
            "swaybar_command ${command}"
            (optionalString (workspaceButtons != null) "workspace_buttons ${yesNo workspaceButtons}")
            (optionalString (workspaceNumbers != null)
              "strip_workspace_numbers ${yesNo (!workspaceNumbers)}"
            )
            (optionalString (trayOutput != null) "tray_output ${trayOutput}")
            (optionalString (trayPadding != null) "tray_padding ${toString trayPadding}")
            (pkgsLib.optionals colorsNotNull (
              indent
                (pkgsLib.lists.subtractLists [ "" null ] [
                  "colors {"
                  (optionalString (colors.background != null) "background ${colors.background}")
                  (optionalString (colors.statusline != null) "statusline ${colors.statusline}")
                  (optionalString (colors.separator != null) "separator ${colors.separator}")
                  (optionalString (colors.focusedBackground != null)
                    "focused_background ${colors.focusedBackground}"
                  )
                  (optionalString (colors.focusedStatusline != null)
                    "focused_statusline ${colors.focusedStatusline}"
                  )
                  (optionalString (colors.focusedSeparator != null)
                    "focused_separator ${colors.focusedSeparator}"
                  )
                  (optionalString (colors.focusedWorkspace != null)
                    "focused_workspace ${barColorSetStr colors.focusedWorkspace}"
                  )
                  (optionalString (colors.activeWorkspace != null)
                    "active_workspace ${barColorSetStr colors.activeWorkspace}"
                  )
                  (optionalString (colors.inactiveWorkspace != null)
                    "inactive_workspace ${barColorSetStr colors.inactiveWorkspace}"
                  )
                  (optionalString (colors.urgentWorkspace != null)
                    "urgent_workspace ${barColorSetStr colors.urgentWorkspace}"
                  )
                  (optionalString (colors.bindingMode != null)
                    "binding_mode ${barColorSetStr colors.bindingMode}"
                  )
                  "}"
                ])
                { }
            ))
            extraConfig
            "}"
          ]
        ))
        { }
    );

  gapsStr =
    gaps:
    concatStringsSep "\n" (pkgsLib.lists.subtractLists [ "" null ] [
      (optionalString (gaps.inner or null != null) "gaps inner ${toString gaps.inner}")
      (optionalString (gaps.outer or null != null) "gaps outer ${toString gaps.outer}")
      (optionalString (gaps.horizontal or null != null)
        "gaps horizontal ${toString gaps.horizontal}"
      )
      (optionalString (gaps.vertical or null != null) "gaps vertical ${toString gaps.vertical}")
      (optionalString (gaps.top or null != null) "gaps top ${toString gaps.top}")
      (optionalString (gaps.bottom or null != null) "gaps bottom ${toString gaps.bottom}")
      (optionalString (gaps.left or null != null) "gaps left ${toString gaps.left}")
      (optionalString (gaps.right or null != null) "gaps right ${toString gaps.right}")
      (optionalString ((gaps.smartGaps or "off") != "off") "smart_gaps ${gaps.smartGaps or "off"}")
      (optionalString ((gaps.smartBorders or "off") != "off")
        "smart_borders ${gaps.smartBorders or "off"}"
      )
    ]);

  windowBorderString =
    window: floating:
    let
      titlebarString =
        { titlebar, border, ... }: "${if titlebar then "normal" else "pixel"} ${toString border}";
    in
    concatStringsSep "\n" [
      "default_border ${titlebarString window}"
      "default_floating_border ${titlebarString floating}"
    ];

  floatingCriteriaStr = criteria: "for_window ${criteriaStr criteria} floating enable";
  windowCommandsStr = { command, criteria, ... }: "for_window ${criteriaStr criteria} ${command}";
  workspaceOutputStr =
    item:
    let
      outputs = pkgsLib.concatMapStringsSep " " pkgsLib.strings.escapeNixString item.output;
    in
    ''workspace "${item.workspace}" output ${outputs}'';

  indent =
    list:
    {
      includesWrapper ? true,
      level ? 1,
    }:
    let
      prefix = concatStringsSep "" (pkgsLib.genList (_x: " ") (level * 2));
    in
    (pkgsLib.imap1 (
      i: v: "${if includesWrapper && (i == 1 || i == (pkgsLib.length list)) then v else "${prefix}${v}"}"
    ) list);

  startupEntryStr =
    {
      command,
      always,
      ...
    }:
    ''
      ${if always then "exec_always" else "exec"} ${command}
    '';

  bindswitchesStr =
    bindswitches:
    concatStringsSep "\n" (
      mapAttrsToList (
        event:
        {
          locked,
          reload,
          action,
        }:
        let
          args = (pkgsLib.optionalString locked "--locked ") + (pkgsLib.optionalString reload "--reload ");
        in
        "bindswitch ${args} ${event} ${action}"
      ) bindswitches
    );

  moduleStr =
    moduleType: name: attrs:
    ''
      ${moduleType} "${name}" {
      ${concatStringsSep "\n" (pkgsLib.mapAttrsToList (name: value: "  ${name} ${value}") attrs)}
      }
    '';
  inputStr = moduleStr "input";
  outputStr = moduleStr "output";
  seatStr = moduleStr "seat";

  /* Takes an attribute-set description of the config and returns the rendered
     text. Mirrors the structure of wayland.windowManager.sway.config in
     home-manager (minus options that only make sense for the HM module, like
     systemd activation / xwayland). See the module's `config` option type for
     the full reference of what each field means:

     https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config
  */
  renderConfig =
    {
      fonts ? { names = [ "monospace" ]; size = 8.0; },
      floating ? {
        modifier = "Mod1";
        criteria = [ ];
        titlebar = true;
        border = 2;
      },
      window ? {
        titlebar = true;
        border = 2;
        commands = [ ];
        hideEdgeBorders = "none";
      },
      focus ? {
        wrapping = "no";
        followMouse = "yes";
        newWindow = "smart";
        mouseWarping = true;
      },
      workspaceLayout ? "default",
      workspaceAutoBackAndForth ? false,
      colors ? {
        focused = null;
        focusedInactive = null;
        unfocused = null;
        urgent = null;
        placeholder = null;
        background = null;
      },
      keybindings ? { },
      defaultWorkspace ? null,
      bindkeysToCode ? false,
      keycodebindings ? { },
      bindswitches ? { },
      modes ? { },
      assigns ? { },
      input ? { },
      output ? { },
      seat ? { },
      bars ? [ ],
      gaps ? null,
      startup ? [ ],
      workspaceOutputAssign ? [ ],
      ...
    }:
    let
      keybindingDefaultWorkspace = pkgsLib.filterAttrs (
        _n: v: defaultWorkspace != null && v == defaultWorkspace
      ) keybindings;
      keybindingsRest = pkgsLib.filterAttrs (
        _n: v: defaultWorkspace == null || v != defaultWorkspace
      ) keybindings;
    in
    concatStringsSep "\n" [
      (fontConfigStr fonts)
      "floating_modifier ${floating.modifier}"
      (windowBorderString window floating)
      "hide_edge_borders ${window.hideEdgeBorders}"
      "focus_wrapping ${focus.wrapping}"
      "focus_follows_mouse ${focus.followMouse}"
      "focus_on_window_activation ${focus.newWindow}"
      "mouse_warping ${
        if builtins.isString focus.mouseWarping then
          focus.mouseWarping
        else if focus.mouseWarping then
          "output"
        else
          "none"
      }"
      "workspace_layout ${workspaceLayout}"
      "workspace_auto_back_and_forth ${yesNo workspaceAutoBackAndForth}"
      (optionalString (colors.focused or null != null) "client.focused ${colorSetStr colors.focused}")
      (optionalString (colors.focusedInactive or null != null)
        "client.focused_inactive ${colorSetStr colors.focusedInactive}"
      )
      (optionalString (colors.unfocused or null != null)
        "client.unfocused ${colorSetStr colors.unfocused}"
      )
      (optionalString (colors.urgent or null != null) "client.urgent ${colorSetStr colors.urgent}")
      (optionalString (colors.placeholder or null != null)
        "client.placeholder ${colorSetStr colors.placeholder}"
      )
      (optionalString (colors.background or null != null) "client.background ${colors.background}")
      (keybindingsStr {
        keybindings = keybindingDefaultWorkspace;
        bindsymArgs = pkgsLib.optionalString bindkeysToCode "--to-code";
      })
      (keybindingsStr {
        keybindings = keybindingsRest;
        bindsymArgs = pkgsLib.optionalString bindkeysToCode "--to-code";
      })
      (keycodebindingsStr keycodebindings)
      (optionalString (builtins.attrNames bindswitches != [ ]) (bindswitchesStr bindswitches))
      (concatStringsSep "\n" (mapAttrsToList inputStr (pkgsLib.filterAttrs (n: _v: n == "*") input)))
      (concatStringsSep "\n"
        (mapAttrsToList inputStr (pkgsLib.filterAttrs (n: _v: pkgsLib.hasPrefix "type:" n) input))
      )
      (concatStringsSep "\n"
        (mapAttrsToList inputStr
          (pkgsLib.filterAttrs (n: _v: n != "*" && !(pkgsLib.hasPrefix "type:" n)) input)
        )
      )
      (concatStringsSep "\n" (mapAttrsToList outputStr output))
      (concatStringsSep "\n" (mapAttrsToList seatStr seat))
      (concatStringsSep "\n" (mapAttrsToList (modeStr bindkeysToCode) modes))
      (concatStringsSep "\n" (mapAttrsToList assignStr assigns))
      (concatStringsSep "\n" (map barStr bars))
      (optionalString (gaps != null) (gapsStr gaps))
      (concatStringsSep "\n" (map floatingCriteriaStr floating.criteria))
      (concatStringsSep "\n" (map windowCommandsStr window.commands))
      (concatStringsSep "\n" (map startupEntryStr startup))
      (concatStringsSep "\n" (map workspaceOutputStr workspaceOutputAssign))
    ];

in
# Final: render the attrset config and write it out, optionally validating
# with `sway --validate` (as home-manager does when checkConfig is enabled).
# The import result IS the config function: pass it the config attrset and it
# returns a store path containing the rendered sway config.
cfg@{ extraConfig ? "", extraConfigEarly ? "", ... }:
    pkgs.writeTextFile {
      name = "sway.conf";
      checkPhase =
        if checkConfig then
          ''
            export DBUS_SESSION_BUS_ADDRESS=/dev/null
            export XDG_RUNTIME_DIR=$(mktemp -d)
            #xvfb-run is virtual framebuffer. it is a build-time only dependency, because annoyingly sway requires initializing a full sway session in order to validate a config
            ${pkgs.xvfb-run}/bin/xvfb-run ${pkgs.sway}/bin/sway --config "$target" --validate --unsupported-gpu || {
              echo "Checking the sway config file failed."
              exit 1
            }
          ''
        else
          "";
      text = pkgsLib.concatStringsSep "\n" (
        (pkgsLib.optional (extraConfigEarly != "") extraConfigEarly)
        ++ [ (renderConfig cfg) ]
        ++ [ extraConfig ]
      );
}
