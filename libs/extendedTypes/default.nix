{lib, ...}:
with lib; rec {
  extendedTypes = {
    # A type for merging all options into a single attribute set
    # This differs from `types.anything` by merging lists instead of throwing an error
    merge = lib.mkOptionType {
      name = "merge";
      description = "Merges all options into a single attribute set";
      check = builtins.isAttrs;
      merge = loc: defs: (lib.mkMerge (builtins.map (def: def.value) defs));
    };
  };
}
