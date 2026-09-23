{

  inputs = {
    mcEatBurg.url = "github:nrs-status/mcEatBurg";
    peachRampSkateboard.url = "github:nrs-status/newPeachRampSkateboard";
    frontArmToPlane.url = "github:nrs-status/newFrontArmToPlane";
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
      wrappedPkgs = inputs.frontArmToPlane.packages.x86_64-linux;
      localModules = import ./marPaintsAngel { inherit pkgs localLib baseLib pkgsLib wrappedPkgs; };
      localPkgsArgs = { inherit pkgs localLib baseLib pkgsLib wrappedPkgs localModules; };
    in
    {
      packages.x86_64-linux = import ./kanSplashSnowman localPkgsArgs;
    };
}
