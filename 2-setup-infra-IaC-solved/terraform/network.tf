resource "openstack_networking_network_v2" "net-1" {
  name = "net-1"
}

resource "openstack_networking_subnet_v2" "sub-1" {
  name            = "sub-1"
  network_id      = openstack_networking_network_v2.net-1.id
  cidr            = "192.168.11.0/24"
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
  ip_version      = 4
}

# Here we look up the external network ID based on the name if you didn't want to copy paste it from the UI

data "openstack_networking_network_v2" "ext-net" {
  name = "external-net"
  # You can also use locals.float_ip_pool for this too
}

resource "openstack_networking_router_v2" "rtr-1" {
  name                = "rtr-1"
  external_network_id = data.openstack_networking_network_v2.ext-net.id
}

resource "openstack_networking_router_interface_v2" "rtr-int" {
  router_id = openstack_networking_router_v2.rtr-1.id
  subnet_id = openstack_networking_subnet_v2.sub-1.id
}
