resource "oci_core_volume" "grid_exist" {
count               = "${var.grid["node_count"] * var.grid["disk_count"]}"
availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 3],"name")}"
compartment_id      = "${var.compartment_ocid}"
display_name        = "grid${(count.index % var.grid["node_count"])+1}-volume${(floor(count.index / var.grid["node_count"]))+1}"
size_in_gbs         = "${var.grid["disk_size"]}"
}

resource "oci_core_volume_attachment" "grid_exist" {
count           = "${var.grid["node_count"] * var.grid["disk_count"]}"
attachment_type = "iscsi"
#  compartment_id  = "${var.compartment_ocid}"
#instance_id     = "${oci_core_instance.grid.*.id[count.index % var.grid["node_count"]]}"
instance_id     = (var.grid_nodes_ocids != "" ? var.grid_nodes_ocids[count.index % var.grid["node_count"]] : oci_core_instance.grid.*.id[count.index % var.grid["node_count"]])
volume_id       = "${oci_core_volume.grid_exist.*.id[count.index]}"
}



#output "Grid_Private_IPs" {
#value = "${join(",", oci_core_instance.grid.*.private_ip)}"
#}

