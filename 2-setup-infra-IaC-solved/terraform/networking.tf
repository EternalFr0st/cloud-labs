resource "openstack_networking_network_v2" "iths-jonas-network" {
  name           = "iths-jonas-net"
}

resource "openstack_networking_subnet_v2" "iths-jonas-subnet" {
  network_id = openstack_networking_network_v2.iths-jonas-network.id
  name = "iths-jonas-subnet"
  cidr       = "10.0.2.0/24"
  enable_dhcp = "true"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}
data "openstack_networking_network_v2" "external_network" {
  name = "ext-net"
}
resource "openstack_networking_router_v2" "iths-jonas-router" {
  name                = "iths-jonas-router"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}
resource "openstack_networking_router_interface_v2" "iths-jonas-router-interface" {
  router_id = openstack_networking_router_v2.iths-jonas-router.id
  subnet_id = openstack_networking_subnet_v2.iths-jonas-subnet.id
}
