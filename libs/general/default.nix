{lib, ...}:
with lib; rec {
  ## Coalesce 2 parameters
  ##
  ## ```nix
  ## coalesce null "Hello"
  ## ```
  ##
  #@ a -> b -> a | b
  coalesce = a: b:
    if a == null
    then b
    else a;

  ## Coalesce a list of parameters
  ##
  ## ```nix
  ## coalesceAll [null null "Hello" null]
  ## ```
  ##
  #@ list -> a
  coalesceAll = list: let
    coalesce2 = a: b: coalesce a b;
  in
    foldl' coalesce2 null list;
}
