# terraform-avx-tgwconnect

This module connects Aviatrix Transit to an AWS Transit Gateway using TGW Connect/GRE Tunnel. The TGW Connect process can be used multiple times to create connections in different Aviatrix Network Domains and TGW Route Tables.

The module assumes that the TGW exists and the VPC attachment part is done. See the following modules for examples.
- https://github.com/MatthewKazmar/terraform-avx-attach-transit-vpc-to-aws-tgw
- https://github.com/MatthewKazmar/terraform-aws-tgw

Example:
```
module "aws_tgw_prod_east" {
  providers = {
    aws = aws.east
  }

  source = "github.com/MatthewKazmar/terraform-avx-tgwconnect"

  transit_vpc_attachment_id  = module.aws_tgw_vpc_attachment_east.attachment.id
  transit_vpc_name           = module.avx_backbone.transit["aws_east"]["vpc"].name
  transit_vpc_id             = module.avx_backbone.transit["aws_east"]["vpc"].vpc_id
  transit_vpc_cidr           = module.avx_backbone.transit["aws_east"]["vpc"].cidr
  transit_vpc_subnets        = module.avx_backbone.transit["aws_east"]["vpc"].subnets[*].name
  transit_gw_name            = module.avx_backbone.transit["aws_east"]["transit_gateway"].gw_name
  transit_pri_ip             = module.avx_backbone.transit["aws_east"]["transit_gateway"].private_ip
  transit_ha_ip              = module.avx_backbone.transit["aws_east"]["transit_gateway"].ha_private_ip
  avx_asn                    = 65001
  tgw_asn                    = module.aws_tgw_east.tgw.amazon_side_asn
  tgw_id                     = module.aws_tgw_east.tgw.id
  tgw_pri_gre_ip             = cidrhost(local.aws_regional_cidrs["east"]["tgw"], 1)
  tgw_ha_gre_ip              = cidrhost(local.aws_regional_cidrs["east"]["tgw"], 2)
  tunnel_cidr                = cidrsubnet("169.254.101.0/24", 3, 0)
  association_route_table_id = module.aws_tgw_east.tgw_route_tables[aviatrix_segmentation_network_domain.prod.domain_name].id
  network_domain_name        = aviatrix_segmentation_network_domain.prod.domain_name
}
```
