inputs@{
  localLib,
  wrappedPkgs,
  newPkgs,
  localModules,
  ...
}:
let
  modules =
    with localModules;
    [
      misc
      alternativeKeybindingMode
      hexColorPicker
      audioKeybindings
      notifications
      scratchpadSetup
      screenCapture
      style
      terminal
      toggleWlsunset
      voiceInput
      waybar
      workspacesSetup
    ]
    ++ [
      {
        time.timezone = "America/Toronto";

        terminal = {
          # wrappedPkgs.kitty appends its `--config <conf>` flag after the
          # caller's arguments (so kitty's `+command` mode stays the first CLI
          # argument), but that makes any `kitty <shell>` invocation pass the
          # flag to the child, which exits immediately. The upstream kitty
          # package is overridable, so flip it to prepend the options instead.
          terminalEmulatorPkg = wrappedPkgs.kitty.override { optsAfterArgs = false; };
          shellStartCmd = "bash";
        };

        scratchPadWidth = 1366;
        scratchPadHeight = 765;
        screenCaptureDir = "/tmp/screenshots";
        voiceInputPkg = newPkgs.voice-input;
      }
    ];
in
localLib.mkSway {
  inherit modules;
  specialArgs = inputs;
}
