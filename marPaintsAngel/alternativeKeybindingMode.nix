{ ... }:
{
  config = {
    swayConfigAttrs = {
      extraConfig = ''
        ### keyboard-binding modes ################################################
        # The keybindings above (the `keybindings` set, plus the raw-keycode
        # bindcode bindings above) constitute mode 1: sway's implicit "default"
        # mode. Mod4+t toggles between the default mode and the second
        # binding mode ("kbdsAlt"), declared below: the bindings inside its block
        # are the second set of key bindings, and any binding redeclared there
        # overrides the default-mode fallback for that key.

        # enter the second binding mode
        bindsym Mod4+t mode "kbdsAlt"

        mode "kbdsAlt" {
            # scaffolding for the second set of key bindings; currently empty
            # apart from the toggle-back binding and a test binding

            # toggle back to the first (default) mode: without this redeclaration
            # the default-mode fallback would re-enter "kbdsAlt" instead
            bindsym Mod4+t mode default

            # test binding: proves the second mode's binding set is active
            bindsym Mod4+Shift+t exec sh -c 'date +%F-%T > /tmp/sway-kbdsAlt-test'
        }
      '';
    };
  };
}
