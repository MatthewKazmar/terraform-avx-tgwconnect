resource "aws_ec2_transit_gateway_connect" "this" {
  transport_attachment_id                         = var.vpc_attachment_id
  transit_gateway_id                              = var.tgw_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = local.attachment_tags
}

resource "aws_ec2_transit_gateway_route_table_association" "avx_connect" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.this.id
  transit_gateway_route_table_id = var.association_route_table_id

  tags = local.attachment_tags
}

resource "aws_ec2_transit_gateway_route_table_propagation" "avx_connect" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.this.id
  transit_gateway_route_table_id = coalesce(var.propagation_route_table_id, var.association_route_table_id)

  tags = local.attachment_tags
}

# Create TGW Connect Peers and Aviatrix GRE tunnel.
resource "aws_ec2_transit_gateway_connect_peer" "primary" {
  peer_address = var.transit_pri_ip
  bgp_asn      = var.avx_asn
  transit_gateway_address       = var.tgw_pri_gre_ip
  inside_cidr_blocks            = [local.tunnel_cidrs[0]]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.this.id
}

resource "aws_ec2_transit_gateway_connect_peer" "ha" {
  peer_address = var.transit_ha_ip
  bgp_asn      = var.avx_asn
  transit_gateway_address       = var.tgw_ha_gre_ip
  inside_cidr_blocks            = [local.tunnel_cidrs[1]]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.this.id
  depends_on = [
    aws_ec2_transit_gateway_connect_peer.primary
  ]
}

resource "aviatrix_transit_external_device_conn" "avx_to_tgw" {
  vpc_id            = var.transit_vpc_id
  connection_name   = "${var.prefix}-avx-to-tgw"
  gw_name           = var.transit_gw_name
  connection_type   = "bgp"
  tunnel_protocol   = "GRE"
  bgp_local_as_num  = var.avx_asn
  bgp_remote_as_num = var.tgw_asn

  remote_gateway_ip  = aws_ec2_transit_gateway_connect_peer.primary.transit_gateway_address
  local_tunnel_cidr  = "${cidrhost(local.tunnel_cidrs[0], 1)}/29, ${cidrhost(local.tunnel_cidrs[2], 1)}/29"
  remote_tunnel_cidr = "${cidrhost(local.tunnel_cidrs[0], 2)}/29, ${cidrhost(local.tunnel_cidrs[2], 2)}/29"

  ha_enabled                = true
  backup_remote_gateway_ip  = aws_ec2_transit_gateway_connect_peer.ha.transit_gateway_address
  backup_local_tunnel_cidr  = "${cidrhost(local.tunnel_cidrs[3], 1)}/29, ${cidrhost(local.tunnel_cidrs[1], 1)}/29"
  backup_remote_tunnel_cidr = "${cidrhost(local.tunnel_cidrs[3], 2)}/29, ${cidrhost(local.tunnel_cidrs[1], 2)}/29"
  backup_bgp_remote_as_num  = var.tgw_asn

  manual_bgp_advertised_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "aviatrix_segmentation_network_domain_association" "this" {
  count = var.network_domain_name == null ? 0 : 1

  network_domain_name = var.network_domain_name
  attachment_name     = aviatrix_transit_external_device_conn.avx_to_tgw.connection_name
}