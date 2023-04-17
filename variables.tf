variable "transit_vpc_name" {
  description = "VPC Name of Transit Gateway"
  type        = string
}

variable "transit_vpc_name" {
  description = "VPC Name of Transit Gateway"
  type        = string
}

variable "transit_vpc_id" {
  description = "VPC ID of Transit Gateway"
  type        = string
}

variable "transit_vpc_cidr" {
  description = "VPC cidr of Transit Gateway"
  type        = string
}

variable "transit_vpc_subnets" {
  description = "Subnet names from aviatrix_vpc resource."
  type        = list(string)
}

variable "transit_gw_name" {
  description = "Name of Transit Gateway"
  type        = string
}

variable "network_domain_name" {
  description = "Name of Network Domain."
  type        = string
  default     = null
}

variable "transit_vpc_attachment_id" {
  description = "ID of VPC attachment for Aviatrix Transit"
  type        = string
}

variable "association_route_table_id" {
  description = "Associate this Connect to this route table id."
  type        = string
  default     = null
}

variable "propagation_route_table_id" {
  description = "Propagate this Connect CIDR to this route table id, if different than the association."
  type        = string
  default     = null
}

variable "transit_pri_ip" {
  description = "IP of Transit Primary IP"
  type        = string
}

variable "transit_ha_ip" {
  description = "IP of Transit ha IP"
  type        = string
}

variable "avx_asn" {
  description = "ASN of Aviatrix Gateway"
  type        = number
}

variable "tgw_id" {
  description = "ID of the TGW"
  type        = string
}

variable "tgw_cidr" {
  description = "ID of the TGW"
  type        = string
}

variable "tgw_asn" {
  description = "ASN of TGW"
  type        = number
}

variable "tgw_pri_gre_ip" {
  description = "ASN of TGW"
  type        = number
}

variable "tgw_ha_gre_ip" {
  description = "ASN of TGW"
  type        = number
}

variable "tunnel_cidr" {
  description = "CIDR for inside tunnel"
  type        = string

  validation {
    condition     = split("/", var.tunnel_cidr)[1] == "27"
    error_message = "This module needs a /27."
  }
}

locals {
  attachment_tags = { Name = var.network_domain_name == null ? "${var.transit_gw_name}-avx-gw-attachment" : "${var.transit_gw_name}-${var.network_domain_name}-avx-gw-attachment" }

  tunnel_cidrs = cidrsubnets(var.tunnel_cidr, 2, 2, 2, 2)
}