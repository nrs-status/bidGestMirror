{

  inputs = {
    mcEatBurg.url = "github:nrs-status/mcEatBurg";
    peachRampSkateboard.url = "github:nrs-status/newPeachRampSkateboard";
    frontArmToPlane.url = "github:nrs-status/newFrontArmToPlane";
    # voice-input lives in the nasExitGiScorp flake, which frontArmToPlane
    # already pins; reuse that exact locked node instead of adding a new copy.
    nasExitGiScorp.follows = "frontArmToPlane/nasExitGiScorp";
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
      newPkgs = inputs.nasExitGiScorp.packages.x86_64-linux;
      localModules = import ./marPaintsAngel { inherit baseLib; };
      localPkgsArgs = {
        inherit
          pkgs
          localLib
          baseLib
          pkgsLib
          wrappedPkgs
          newPkgs
          localModules
          ;
      };
    in
    {
      packages.x86_64-linux = import ./kanSplashSnowman localPkgsArgs;
    };
}
