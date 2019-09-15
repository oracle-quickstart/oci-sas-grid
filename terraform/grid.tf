
#  "sasUserPassword=${random_string.sas_user_password.result}",
#  "nfsMountDeviceName=${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1}",
#  "nfsMountDirectory=/mnt${var.export_path_fs1_mt1}",
#  "gridDiskCount=",


# grid-0
resource "oci_core_instance" "grid" {
  # To ensure FSS NFS setup is complete for grid to use
depends_on = [ "oci_file_storage_export.my_export_fs1_mt1" ]
display_name        = "grid-${count.index}"
compartment_id      = "${var.compartment_ocid}"
availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 3],"name")}"
shape               = "${var.grid["shape"]}"
fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"

source_details {
source_id   = "${var.images[var.region]}"
source_type = "image"
}

create_vnic_details {
subnet_id        = "${oci_core_subnet.privateb.*.id[0]}"
hostname_label   = "grid-${count.index+1}"
assign_public_ip = "false"
}

metadata = {
ssh_authorized_keys = "${var.ssh_public_key}"
user_data = "${base64encode(join("\n", list(
"#!/usr/bin/env bash",
"set -x",
"sasUserPassword=${random_string.sas_user_password.result}",
"nfsMountDeviceName=${local.mount_target_1_ip_address}:${local.export_path_fs1_mt1}",
"nfsMountDirectory=/mnt${local.export_path_fs1_mt1}",
"gridNodeCount=${var.grid["node_count"]}",
"gridNodeHostnamePrefix=${var.grid["hostname_prefix"]}",
"gridDiskCount=${var.grid["disk_count"]}",
"midTierNodeCount=${var.mid_tier["node_count"]}",
"midTierDiskCount=${var.mid_tier["disk_count"]}",
"midTierNodeHostnamePrefix=${var.mid_tier["hostname_prefix"]}",
"metadataNodeCount=${var.metadata["node_count"]}",
"metadataDiskCount=${var.metadata["disk_count"]}",
"metadataNodeHostnamePrefix=${var.metadata["hostname_prefix"]}",
"clusterName=${var.grid["cluster_name"]}",
"sasDepotRoot=${var.sas_depot["root"]}",
"sasDepotDownloadUrl=${var.sas_depot["download_url"]}",
"lsfTop=${var.platform_suite["lsf_top"]}",
"jsTop=${var.platform_suite["js_top"]}",
file("../scripts/firewall.sh"),
file("../scripts/install.sh"),
file("../scripts/grid_disks.sh"),
file("../scripts/x11_setup.sh"),
file("../scripts/nfs.sh"),
"touch /tmp/sas_depot_nfs_download.complete",
file("../scripts/grid.sh"),
"touch /tmp/cloud_init.complete"
)))}"
}

count = "${var.grid["node_count"]}"
}


resource "oci_core_volume" "grid" {
count               = "${var.grid["node_count"] * var.grid["disk_count"]}"
availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 3],"name")}"
compartment_id      = "${var.compartment_ocid}"
display_name        = "grid${(count.index % var.grid["node_count"])+1}-volume${(floor(count.index / var.grid["node_count"]))+1}"
size_in_gbs         = "${var.grid["disk_size"]}"
}

resource "oci_core_volume_attachment" "grid" {
count           = "${var.grid["node_count"] * var.grid["disk_count"]}"
attachment_type = "iscsi"
#  compartment_id  = "${var.compartment_ocid}"
instance_id     = "${oci_core_instance.grid.*.id[count.index % var.grid["node_count"]]}"
volume_id       = "${oci_core_volume.grid.*.id[count.index]}"
}



output "Grid_Private_IPs" {
value = "${join(",", oci_core_instance.grid.*.private_ip)}"
}
