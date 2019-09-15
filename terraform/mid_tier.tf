# mid-tier-0
resource "oci_core_instance" "mid-tier" {
display_name        = "mid-tier-${count.index}"
compartment_id      = "${var.compartment_ocid}"
availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
shape               = "${var.mid_tier["shape"]}"
fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"

source_details {
source_id   = "${var.images[var.region]}"
source_type = "image"
}

create_vnic_details {
#subnet_id        = "${oci_core_subnet.privateb.*.id[0]}"
subnet_id        = (var.private_subnet_ocid_for_sas_install != "" ? var.private_subnet_ocid_for_sas_install : oci_core_subnet.privateb.*.id[0])
hostname_label   = "mid-tier-${count.index+1}"
assign_public_ip = "false"
}

metadata = {
ssh_authorized_keys = "${var.ssh_public_key}"
user_data = "${base64encode(join("\n", list(
"#!/usr/bin/env bash",
"sasUserPassword=${random_string.sas_user_password.result}",
"midTierNodeCount=${var.mid_tier["node_count"]}",
"midTierDiskCount=${var.mid_tier["disk_count"]}",
"midTierNodeHostnamePrefix=${var.mid_tier["hostname_prefix"]}",
"metadataNodeCount=${var.metadata["node_count"]}",
"metadataDiskCount=${var.metadata["disk_count"]}",
"metadataNodeHostnamePrefix=${var.metadata["hostname_prefix"]}",
"gridNodeCount=${var.grid["node_count"]}",
"gridNodeHostnamePrefix=${var.grid["hostname_prefix"]}",
"gridDiskCount=${var.grid["disk_count"]}",
file("../scripts/firewall.sh"),
file("../scripts/install.sh"),
file("../scripts/mid_tier_disks.sh"),
file("../scripts/x11_setup.sh"),
#file("../scripts/mid_tier.sh")
"touch /tmp/cloud_init.complete"
)))}"
}

count = "${var.mid_tier["node_count"]}"
}

/*
resource "oci_core_volume" "mid-tier" {
count               = "${var.mid_tier["node_count"] * var.mid_tier["disk_count"]}"
availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
compartment_id      = "${var.compartment_ocid}"
display_name        = "mid-tier${count.index % var.mid_tier["node_count"]}-volume${floor(count.index / var.mid_tier["node_count"])}"
size_in_gbs         = "${var.mid_tier["disk_size"]}"
}

resource "oci_core_volume_attachment" "mid-tier" {
count           = "${var.mid_tier["node_count"] * var.mid_tier["disk_count"]}"
attachment_type = "iscsi"
compartment_id  = "${var.compartment_ocid}"
instance_id     = "${oci_core_instance.mid-tier.*.id[count.index % var.mid_tier["node_count"]]}"
volume_id       = "${oci_core_volume.mid-tier.*.id[count.index]}"
}
*/


output "Mid_Tier_Private_IPs" {
value = "${join(",", oci_core_instance.mid-tier.*.private_ip)}"
}

