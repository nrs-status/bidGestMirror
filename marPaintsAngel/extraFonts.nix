# Adds mandarin/CJK font support so characters such as 丨 (U+4E28, "gǔn")
# render correctly in sway's UI, its bar, and in the terminal clients it
# spawns.
#
# The Noto CJK fonts are added to the modules' `buildInputs`. mkSway picks
# them up in two ways:
#   * the packages become runtime dependencies of the wrapped `sway`, and
#   * mkSway generates a fontconfig configuration that exposes their font
#     directories (in addition to the system fonts) to sway and to every
#     process it spawns, so fontconfig can fall back to them for glyphs
#     the user's primary font (e.g. Iosevka Proportional) does not cover.
{
  config,
  pkgs,
  ...
}:
{
  config = {
    buildInputs = with pkgs; [
      noto-fonts-cjk-sans # sans CJK fonts: covers 丨 and most hanzi
      noto-fonts-cjk-serif # serif CJK fallback
    ];
  };
}
