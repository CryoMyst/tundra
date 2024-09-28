{lib, ...}:
with lib; rec {
  list = {
    ## If a list has any elements
    ##
    ## ```nix
    ## hasAny [1 2 3]
    ## ```
    ##
    #@ List -> Boolean
    hasAny = list: length list > 0;

    ## Maps a list to an attribute set
    ##
    ## ```nix
    ## mapToAttrs (name: { x = name; }) ["a" "b" "c"]
    ## ```
    ##
    #@ (String -> a) -> List -> AttrSet
    mapToAttrs = fn: list:
      builtins.listToAttrs (map (name: {
          inherit name;
          value = fn name;
        })
        list);
  };
}
