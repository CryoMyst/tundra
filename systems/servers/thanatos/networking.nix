{lib, ...}: let
  interface = "enp6s0";
  fallback_interface = "enp7s0";
  bridge_interface = "br0";
in {
  networking.networkmanager.enable = lib.mkForce false;
  networking = {
    useNetworkd = false;
    useDHCP = false;
    # firewall.enable = true;
  };
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
      "10-${fallback_interface}" = {
        name = "${fallback_interface}";
        DHCP = "yes";
        linkConfig.RequiredForOnline = "no";
      };
      "10-${bridge_interface}" = {
        name = "${bridge_interface}";
        address = ["10.1.30.10/24"];
        gateway = ["10.1.30.1"];
        dns = ["10.1.30.1"];
        DHCP = "no";
        bridgeConfig = {};
        linkConfig = {
          MACAddress = "85:f2:01:2a:1e:24";
          RequiredForOnline = "routable";
        };
      };
    };
  };
}
