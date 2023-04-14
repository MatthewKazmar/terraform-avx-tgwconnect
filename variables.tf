variable "prefix" {
  description = "Prefix the resources created."
  type        = string
}

variable "vpc_attachment_id" {
  description = "ID of VPC attachment for Aviatrix Transit"
  type        = string
}

variable "tgw_route_table_id" {
  description = "ID of TGW route table."
  type        = string
}
variable "transit_gw_name" {
  description = "Name of Transit Gateway"
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

variable "tunnel_cidr" {
  description = "CIDR for inside tunnel"
  type        = string

  validation {
    condition     = split("/", var.tunnel_cidr)[1] == "27"
    error_message = "This module needs a /27."
  }
}

variable "security_domain" {
  description = "Aviatrix security domain"
  type        = string
}

locals {
  tunnel_cidrs = cidrsubnets(var.tunnel_cidr, 2, 2, 2, 2)
}