resource "openstack_networking_network_v2" "net-1" {
  name           = "net-1"
}

resource "openstack_networking_subnet_v2" "subnet-1" {
  name       = "subnet-1"
  network_id = openstack_networking_network_v2.net-1.id
  cidr       = "10.2.3.0/24"
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  enable_dhcp = "true"
}

resource "openstack_networking_router_v2" "rtr-1" {
  name                = "rtr-1"
  external_network_id = "f3fa073e-8038-44c4-ae42-64e2045ae538"
}

resource "openstack_networking_router_interface_v2" "rtr-subnet-1" {
  router_id = openstack_networking_router_v2.rtr-1.id
  subnet_id = openstack_networking_subnet_v2.subnet-1.id
}
