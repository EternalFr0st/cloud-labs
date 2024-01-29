resource "openstack_networking_secgroup_v2" "iths-jonas-web-sg" {
  name        = "iths-jonas-web-sg"
  description = "Jonas web SG"
}

resource "openstack_networking_secgroup_rule_v2" "web-allow-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id  = openstack_networking_secgroup_v2.iths-jonas-bastion-sg.id
  security_group_id = openstack_networking_secgroup_v2.iths-jonas-web-sg.id
}

resource "openstack_networking_secgroup_rule_v2" "web-allow-http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.iths-jonas-web-sg.id
}

resource "openstack_compute_instance_v2" "web" {
  count = 2
  name            = "iths-jonas-web-${count.index}"
  flavor_name       = "b.1c1gb"
  key_pair        = openstack_compute_keypair_v2.iths-jonas.name
  security_groups = [openstack_networking_secgroup_v2.iths-jonas-web-sg.name]

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
EOT
}

resource "openstack_networking_floatingip_v2" "web_lb_floatip" {
  pool = "ext-net"
}

resource "openstack_lb_loadbalancer_v2" "web_lb" {
  vip_subnet_id = openstack_networking_subnet_v2.iths-jonas-subnet.id
}

resource "openstack_lb_listener_v2" "web_lb_listener" {
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.web_lb.id

  insert_headers = {
    X-Forwarded-For = "true"
  }
}

resource "openstack_lb_pool_v2" "web_lb_pool" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.web_lb_listener.id
}

resource "openstack_lb_member_v2" "web_lb_members" {
  count = 2
  pool_id       = openstack_lb_pool_v2.web_lb_pool.id
  address       = openstack_compute_instance_v2.web[count.index].access_ip_v4
  protocol_port = 80
}

resource "openstack_lb_monitor_v2" "web_lb_monitor" {
  pool_id     = openstack_lb_pool_v2.web_lb_pool.id
  type        = "HTTP"
  delay       = 10
  timeout     = 5
  max_retries = 1
  max_retries_down = 3
  url_path = "/health.html"
  expected_codes = "200"
}

resource "openstack_networking_floatingip_associate_v2" "web_lb_float_associate" {
  floating_ip = openstack_networking_floatingip_v2.web_lb_floatip.address
  port_id     = openstack_lb_loadbalancer_v2.web_lb.vip_port_id
}
