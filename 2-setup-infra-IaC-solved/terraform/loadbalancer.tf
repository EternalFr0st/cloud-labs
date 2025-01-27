resource "openstack_networking_secgroup_v2" "lb_sg" {
  name        = "lb_sg"
  description = "Load Balancer Security Group"
}

resource "openstack_networking_secgroup_rule_v2" "lb_sg_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id = openstack_networking_secgroup_v2.bastion_sg.id
  security_group_id = openstack_networking_secgroup_v2.lb_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "lb_sg_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.lb_sg.id
}

resource "openstack_compute_instance_v2" "lb_vm" {
  name            = "jonas-lb"
  flavor_name       = "m1.tiny"
  key_pair        = "iths-lab-demo"
  security_groups = [openstack_networking_secgroup_v2.lb_sg.name]

  block_device {
    uuid                  = local.debian_12_id
    source_type           = "image"
    volume_size           = 5
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.net-1.id
  }
}

resource "openstack_networking_floatingip_v2" "lb_fip" {
  pool = "external-net"
}

data "openstack_networking_port_v2" "lb_port" {
  fixed_ip = openstack_compute_instance_v2.lb_vm.network[0].fixed_ip_v4
}


resource "openstack_networking_floatingip_associate_v2" "lb_ip_associate" {
  floating_ip = openstack_networking_floatingip_v2.lb_fip.address
    port_id     = data.openstack_networking_port_v2.lb_port.id
}
