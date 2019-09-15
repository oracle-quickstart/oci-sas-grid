/*
All network resources for this template
*/


data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = "${var.compartment_ocid}"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}


resource "oci_core_virtual_network" "sas" {
  cidr_block     = var.vpc-cidr
  compartment_id = var.compartment_ocid
  display_name   = "sas"
  dns_label      = "sas"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "internet_gateway"
  vcn_id         = oci_core_virtual_network.sas.id
}

resource "oci_core_route_table" "pubic_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.sas.id
  display_name   = "pubic_route_table"
  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.sas.id
  display_name   = "nat_gateway"
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.sas.id
  display_name   = "private_route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "public_security_list"
  vcn_id         = oci_core_virtual_network.sas.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  /*
# For PING and ICMP traffic
    egress_security_rules = [{
        destination = "${var.vpc-cidr}"
        protocol = "1"
    }]
*/
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 3389
      min = 3389
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "private_security_list"
  vcn_id         = oci_core_virtual_network.sas.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  egress_security_rules {
    protocol    = "all"
    destination = var.vpc-cidr
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vpc-cidr
  }

  ingress_security_rules {
    protocol = "All"
    source   = var.vpc-cidr
  }
}

## Publicly Accessable Subnet Setup

resource "oci_core_subnet" "public" {
  count               = "1"
  cidr_block          = cidrsubnet(var.vpc-cidr, 8, count.index)
  display_name        = "public_${count.index}"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.sas.id
  route_table_id      = oci_core_route_table.pubic_route_table.id
  security_list_ids   = [oci_core_security_list.public_security_list.id]
  dhcp_options_id     = oci_core_virtual_network.sas.default_dhcp_options_id
  dns_label           = "public${count.index}"
}

## Private Subnet Setup 

resource "oci_core_subnet" "private" {
  count                      = "1"
  cidr_block                 = cidrsubnet(var.vpc-cidr, 8, count.index + 3)
  display_name               = "private_${count.index}"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.sas.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  dhcp_options_id            = oci_core_virtual_network.sas.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "private${count.index}"
}

resource "oci_core_subnet" "privateb" {
  count                      = "1"
  cidr_block                 = cidrsubnet(var.vpc-cidr, 8, count.index + 6)
  display_name               = "privateb_${count.index}"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.sas.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  dhcp_options_id            = oci_core_virtual_network.sas.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "privateb${count.index}"
}

