data "openstack_dns_zone_v2" "iths-lab" {
  name = "iths.lab.dsnw.dev."
}

resource "openstack_dns_recordset_v2" "iths-jonas" {
  zone_id     = data.openstack_dns_zone_v2.iths-lab.id
  name        = "iths-jonas.iths.lab.dsnw.dev."
  ttl         = 10
  type        = "A"
  records     = [openstack_networking_floatingip_v2.lb_fip.address]
}
