{lib, ...}: let
  interface = "enp39s0";
  bridge_interface = "br0";
in {
  systemd.network = {
    enable = true;
    netdevs."${bridge_interface}" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "${bridge_interface}";
      };
    };
    networks = {
      "10-${interface}" = {
        name = "${interface}";
        bridge = ["${bridge_interface}"];
        linkConfig.RequiredForOnline = "enslaved";
      };
      "10-${bridge_interface}" = {
        name = "${bridge_interface}";
        DHCP = "yes";
      };
    };
  };
}
