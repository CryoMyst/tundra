{pkgs, ...}: {
  wrappers.wayvnc = {
    basePackage = pkgs.wayvnc;
    flags = [
      "--config=${./config}"
    ];
  };
}
