{pkgs, ...}: let
  pname = "qidi-slicer";
  version = "1.1.5";

  src = pkgs.fetchurl {
    url = "https://github.com/QIDITECH/QIDISlicer/releases/download/V${version}/QIDISlicer_${version}_Linux.AppImage";
    sha256 = "sha256-JF3p8H29gtXUeC+VZjfoHe1h1+iU3mrmVp7BHrHLRDY=";
  };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs:
      with pkgs; [
        webkitgtk
      ];

    extraInstallCommands = let
      appimageContents = pkgs.appimageTools.extractType2 {inherit pname version src;};
    in ''
      # Install .desktop files
      install -Dm444 ${appimageContents}/QIDISlicer.desktop -t $out/share/applications
      install -Dm444 ${appimageContents}/QIDISlicer.png -t $out/share/pixmaps
    '';
  }
