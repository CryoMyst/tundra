{lib, ...}:
with lib; rec {
  ## Create a inline Nix module option
  ##
  ## ```nix
  ## mkOpt types.str "Default value" "Description"
  ## ```
  ##
  #@ Type -> String -> String -> Option
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create an inline required Nix module option
  ##
  ## ```nix
  ## mkReqOpt types.str "Description"
  ## ```
  ##
  #@ Type -> String -> Option
  mkReqOpt = type: description:
    mkOption {inherit type description;};

  ## Create a inline Nix module option with no default value
  ##
  ## ```nix
  ## mkNullOpt types.str "Description"
  ## ```
  ##
  #@ Type -> String -> Option
  mkNullOpt = type: description:
    mkOpt (types.nullOr type) null description;

  ## Makes a default disabled option
  ##
  ## ```nix
  ## mkDisabled "Description"
  ## ```
  ##
  #@ String -> Option
  mkDisabledOption = description:
    mkOption {
      type = types.bool;
      default = false;
      inherit description;
    };
}
