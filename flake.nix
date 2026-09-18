{

  inputs = {
    mcEatBurg.url = "github:nrs-status/mcEatBurg";
    peachRampSkateboard.url = "github:nrs-status/newPeachRampSkateboard";
  };

  outputs =
    inputs:
    let
      pkgs = inputs.mcEatBurg.pkgs;
      pkgsLib = inputs.peachRampSkateboard.pkgsLib; # pkgsLib is distinguished from pkgs because logically they are independent: pkgsLib is used to provide glue code to make the repository work, pkgs provides actual build components
      baseLib = inputs.peachRampSkateboard.baseLib;
      localLib = import ./nosfBoosCat {
        inherit baseLib pkgsLib pkgs;
      };
      localPkgsArgs = { inherit pkgs localLib baseLib pkgsLib; };
    in
    {
      packages = import ./kanSplashSnowman localPkgsArgs;
    };
}
