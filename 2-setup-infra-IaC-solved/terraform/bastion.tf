resource "openstack_networking_secgroup_v2" "iths-jonas-bastion-sg" {
  name        = "iths-jonas-bastion-sg"
  description = "Jonas bastion SG"
}

resource "openstack_networking_secgroup_rule_v2" "bastion-allow-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.iths-jonas-bastion-sg.id
}

data "openstack_images_image_v2" "debian12" {
  name        = "Debian 12 Bookworm x86_64"
  most_recent = true
}

resource "openstack_compute_instance_v2" "bastion" {
  name            = "iths-jonas-bastion"
  flavor_name       = "b.1c1gb"
  key_pair        = openstack_compute_keypair_v2.iths-jonas.name
  security_groups = [openstack_networking_secgroup_v2.iths-jonas-bastion-sg.name]

  block_device {
    uuid                  = data.openstack_images_image_v2.debian12.id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.iths-jonas-network.name
  }
  user_data = <<EOT
#cloud-config
final_message: "The system is finally up, after $UPTIME seconds"
EOT
}

resource "openstack_networking_floatingip_v2" "bastion_floatip" {
  pool = "ext-net"
}

resource "openstack_compute_floatingip_associate_v2" "bastion_floatip_associate" {
  floating_ip = openstack_networking_floatingip_v2.bastion_floatip.address
  instance_id = openstack_compute_instance_v2.bastion.id
}
