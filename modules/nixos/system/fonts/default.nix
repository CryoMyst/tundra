{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.system.fonts;
in {
  options.tundra.system.fonts = {
    enable = lib.mkEnableOption "Enable fonts module";
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    fonts.packages = with pkgs; [
      ubuntu_font_family
      source-code-pro
      proggyfonts
      powerline-fonts
      noto-fonts-emoji
      noto-fonts-cjk
      noto-fonts
      nerdfonts
      mplus-outline-fonts.githubRelease
      liberation_ttf
      kanji-stroke-order-font
      jetbrains-mono
      ipafont
      font-awesome
      # emojione
      dina-font
      corefonts
    ];
  };
}
