resource "openstack_compute_instance_v2" "tf-vm-1" {
  name            = "terraform-vm-1"
  flavor_name     = "m1.small"
  key_pair        = "iths-2026-demo"
  security_groups = ["default"]

  block_device {
    uuid                  = local.debian_13_id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.net-1.id
  }
}

# Lets allocate a Floating IP
resource "openstack_networking_floatingip_v2" "tf-vm-1-fip" {
  pool = local.float_ip_pool
}

# And associate it to the VM!
data "openstack_networking_port_v2" "tf-vm-1-port" {
  device_id = openstack_compute_instance_v2.tf-vm-1.id
}
resource "openstack_networking_floatingip_associate_v2" "tf-vm-1-fip-assoc" {
  floating_ip = openstack_networking_floatingip_v2.tf-vm-1-fip.address
  port_id     = data.openstack_networking_port_v2.tf-vm-1-port.id
}
