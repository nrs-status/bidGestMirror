# Extracted from home-manager: modules/programs/waybar.nix (config generation only)
#
# The original module declares `programs.waybar.settings` as a submodule whose
# freeform type is `pkgs.formats.json {}`, then renders with:
#
#   configSource = jsonFormat.generate "waybar-config.json" finalConfiguration;
#
# This file reproduces that pipeline standalone, without the module system.
#
# Usage:
#   mkWaybar = import ./waybar-pkgsLib.nix {
#     inherit (pkgs) pkgsLib pkgs.writeText;
#     (pkgs.formats.json {}) = pkgs.formats.json { };
#   };
#   mkWaybar {
#     settings = {
#       mainBar = {
#         layer = "top";
#         position = "top";
#         height = 30;
#         modules-left = [ "sway/workspaces" "sway/mode" ];
#         "sway/workspaces" = { disable-scroll = true; all-outputs = true; };
#         "clock" = { format-alt = "{:%a, %d. %b %H:%M}"; };
#       };
#     };
#     style = ''
#       * { border: none; }
#     '';
#   }
# => { config = <store path waybar-config.json>; style = <store path or null>; }
{
  pkgsLib,
  pkgs,
  ...
}:
let
  inherit (pkgsLib)
    filterAttrs
    optionalAttrs
    ;

  # Removes nulls because Waybar ignores them.
  # This is not recursive.
  # (verbatim from modules/programs/waybar.nix)
  removeTopLevelNulls = filterAttrs (_: v: v != null);

  # Makes the actual valid configuration Waybar accepts
  # (strips our custom settings before converting to JSON).
  # (verbatim from modules/programs/waybar.nix)
  makeConfiguration =
    configuration:
    let
      # The "modules" option is not valid in the JSON
      # as its descendants have to live at the top-level
      settingsWithoutModules = removeAttrs configuration [ "modules" ];
      settingsModules = optionalAttrs (configuration.modules or null != null) configuration.modules;
    in
    removeTopLevelNulls (settingsWithoutModules // settingsModules);
in
{
  settings,
  style ? null,
}:
let
  # Allow using attrs for settings instead of a list in order to
  # more easily override. (verbatim from modules/programs/waybar.nix)
  settingsList = if builtins.isAttrs settings then pkgsLib.attrValues settings else settings;

  # The clean list of configurations. (verbatim)
  finalConfiguration = map makeConfiguration settingsList;

  configSource = (pkgs.formats.json { }).generate "waybar-config.json" finalConfiguration;

  styleSource =
    if style == null then
      null
    # If the value is set to a path literal / store path, use it as-is.
    # (mirrors the xdg.configFile."waybar/style.css" logic)
    else if builtins.isPath style || pkgsLib.isStorePath style then
      style
    else
      pkgs.writeText "waybar/style.css" style;
in
{
  config = configSource;
  style = styleSource;
}
