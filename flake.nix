{

  inputs = {
    mcEatBurg.url = "github:nrs-status/mcEatBurg";
    peachRampSkateboard.url = "github:nrs-status/newPeachRampSkateboard";
  };

  outputs =
    inputs:
    let
      pkgs = inputs.mcEatBurg.pkgs;
      pkgsLib = inputs.peachRampSkateboard.pkgsLib;
      baseLib = inputs.peachRampSkateboard.baseLib;
      localLib = import ./nosfBoosCat {
        inherit baseLib pkgsLib pkgs;
      };
      localPkgsArgs = { inherit pkgs localLib baseLib pkgsLib; };
    in
    {
      packages.x86_64-linux = import ./kanSplashSnowman localPkgsArgs;
    };
}
