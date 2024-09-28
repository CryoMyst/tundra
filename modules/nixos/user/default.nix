{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.user;
in {
  options.tundra.user = with types; {
    name = mkReqOpt str "The user's username";
    fullName = mkOpt str "" "The user's full name";
    email = mkOpt str "" "The user's email address";
    isAdmin = mkEnableOption "Whether the user is an admin";
    uid = mkOpt int 1000 "The user's UID";
    extraGroups = mkOpt (listOf str) [] "Extra groups to add the user to";
    extraOptions = mkOpt attrs {} "Extra options to pass to the user";
    packages = mkOpt (listOf package) [] "Packages to install for the user";
    # Should only be used internally
    homeManager = mkOpt lib.tundra.extendedTypes.merge {} "Home manager configuration";
  };

  config = {
    users.users = {
      "${cfg.name}" =
        {
          isNormalUser = true;

          inherit (cfg) name uid;

          packages = cfg.packages;

          extraGroups =
            cfg.extraGroups
            ++ (optional cfg.isAdmin "wheel");
        }
        // cfg.extraOptions;
    };

    tundra.user.homeManager = {
      home = {
        stateVersion = config.system.stateVersion;
      };
    };
    home-manager = {
      backupFileExtension = "hm-backup";
      useUserPackages = true;
      useGlobalPkgs = true;
    };
    home-manager.users = {
      "${cfg.name}" = cfg.homeManager;
    };
  };
}
