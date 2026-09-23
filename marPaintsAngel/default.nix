{ baseLib }:
baseLib.importPairsOfDirPath {
  dirPath = ./.;
  pred = x:
    (dirOf x == ./.) && baseNameOf x != "default.nix";
  excludeDirectories = false;
}
