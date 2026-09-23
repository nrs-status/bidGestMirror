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
          terminalEmulatorPkg = wrappedPkgs.kitty;
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
