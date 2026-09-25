{
  config,
  pkgsLib,
  ...
}:
let
  modifier = config.swayConfigAttrs.modifier;
  # The reference (home-manager's sway module) defines the workspace
  # switch/move bindings as option defaults; this custom module system never
  # ported them, so Mod4+<number> had no binding at all and did nothing.
  # Restore the same set (0 selects workspace 10, as upstream does).
  workspaceKeybindings = pkgsLib.listToAttrs (
    pkgsLib.concatMap (
      n:
      let
        key = if n == 10 then "0" else toString n;
      in
      [
        {
          name = "${modifier}+${key}";
          value = "workspace number ${toString n}";
        }
        {
          name = "${modifier}+Shift+${key}";
          value = "move container to workspace number ${toString n}";
        }
      ]
    ) (pkgsLib.range 1 10)
  );
in
{
  config.swayConfigAttrs.keybindings = workspaceKeybindings;
}
