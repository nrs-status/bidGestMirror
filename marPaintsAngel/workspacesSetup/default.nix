{
  pkgs,
  wrappedPkgs,
  pkgsLib,
  config,
  ...
}:
{
  config = {
    swayConfigAttrs = {
      startup = [
        {
          command = pkgsLib.getExe (
            import ./setupWorkspaces.nix {
              inherit
                pkgs
                pkgsLib
                wrappedPkgs
                config
                ;
            }
          );
        }
      ];
    };
  };
}
