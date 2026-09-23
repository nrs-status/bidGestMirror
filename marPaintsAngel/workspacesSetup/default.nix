{
  pkgs,
  wrappedPkgs,
  pkgsLib,
  config,
  ...
}:
{
  imports = [ ../terminal ];
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
