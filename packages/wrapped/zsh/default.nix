{
  pkgs,
  config,
  ...
}: {
  wrappers.zsh = {
    basePackage = pkgs.zsh;
    env.ZDOTDIR.value = ./.;
    pathAdd = [
    ];
  };
}
