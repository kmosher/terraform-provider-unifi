variable "vlan_id" {
  default = 10
}

data "unifi_ap_group" "default" {
}

data "unifi_user_group" "default" {
}

resource "unifi_network" "vlan" {
  name    = "wifi-vlan"
  purpose = "corporate"

  subnet       = "10.0.0.1/24"
  vlan_id      = var.vlan_id
  dhcp_start   = "10.0.0.6"
  dhcp_stop    = "10.0.0.254"
  dhcp_enabled = true
}

resource "unifi_wlan" "wifi" {
  name       = "myssid"
  passphrase = "12345678"
  security   = "wpapsk"

  # enable WPA2/WPA3 support
  wpa3_support    = true
  wpa3_transition = true
  pmf_mode        = "optional"

  network_id    = unifi_network.vlan.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id
}

# Multi-PSK: an SSID whose clients are placed on a network (VLAN) chosen
# by which passphrase they authenticate with.
resource "unifi_network" "iot" {
  name    = "iot-vlan"
  purpose = "corporate"
  subnet  = "10.0.20.1/24"
  vlan_id = 20
}

resource "unifi_wlan" "multi_psk" {
  name       = "multi-psk-ssid"
  passphrase = "primary-passphrase"
  security   = "wpapsk"

  network_id    = unifi_network.vlan.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id

  # Clients using this passphrase land on the iot VLAN instead of the
  # WLAN's default network.
  private_preshared_key {
    password   = "iot-device-passphrase"
    network_id = unifi_network.iot.id
  }
}
