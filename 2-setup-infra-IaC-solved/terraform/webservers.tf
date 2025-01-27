resource "openstack_networking_secgroup_v2" "web_sg" {
  name        = "web_sg"
  description = "Web Server Security Group"
}

resource "openstack_networking_secgroup_rule_v2" "web_sg_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id = openstack_networking_secgroup_v2.bastion_sg.id
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
}
resource "openstack_networking_secgroup_rule_v2" "web_sg_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_group_id = openstack_networking_secgroup_v2.lb_sg.id
  security_group_id = openstack_networking_secgroup_v2.web_sg.id
}

resource "openstack_compute_instance_v2" "web_vm" {
  count = 2
  name            = "jonas-web"
  flavor_name       = "m1.tiny"
  key_pair        = "iths-lab-demo"
  security_groups = [openstack_networking_secgroup_v2.web_sg.name]

  user_data = <<EOF
#cloud-config
package_update: true
package_upgrade: true
packages:
- python3-minimal
- apache2
- jq
runcmd:
- curl -s http://169.254.169.254/latest/meta-data/hostname >/var/www/html/index.html
- echo >>/var/www/html/index.html 
- curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone >>/var/www/html/index.html
- echo >>/var/www/html/index.html 
- echo >>/var/www/html/index.html
- echo "OK" >/var/www/html/health.html
final_message: "The system is finally up, after $UPTIME seconds"
EOF

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
