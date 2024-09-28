{
  inputs,
  lib,
  config,
  ...
}: {
  debug = true;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  imports = [
    ./../libs
    ./../modules
    ./../packages
    ./../shells
    ./../systems
  ];
}
