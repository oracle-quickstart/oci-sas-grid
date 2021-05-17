/*
OCI FSS is a managed NFS service.
*/

# Gets the list of file systems in the compartment
data "oci_file_storage_file_systems" "sas_nfs" {
  count = local.use_fss ? 1 : 0
  #Required
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "sas_nfs"
  #id = "ocid1.filesystem.oc1.phx.aaaaaaaaaaaaawynobuhqllqojxwiotqnb4c2ylefuyqaaaa"
  #state = "DELETED"
}

# Gets the list of mount targets in the compartment
data "oci_file_storage_mount_targets" "mount_targets" {
  count = local.use_fss ? 1 : 0
  #Required
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "${var.mount_target_display_name}"
  #export_set_id = "${var.mount_target_export_set_id}"
  #id = "${var.mount_target_id}"
  #state = "${var.mount_target_state}"
}

# Gets the list of exports in the compartment
data "oci_file_storage_exports" "exports" {
  count = local.use_fss ? 1 : 0
  #Required
  compartment_id = var.compartment_ocid

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #export_set_id = "${oci_file_storage_mount_target.my_mount_target_1.export_set_id}"
  #file_system_id = "${oci_file_storage_file_system.my_fs.id}"
  #id = "${var.export_id}"
  #state = "${var.export_state}"
}

# Gets a list of snapshots for a particular file system
data "oci_file_storage_snapshots" "snapshots" {
  count = local.use_fss ? 1 : 0
  #Required
  file_system_id = element(concat(oci_file_storage_file_system.sas_nfs.*.id, [""]), 0)
  # "${oci_file_storage_file_system.sas_nfs.id}"
  
  #Optional fields. Used by the service to filter the results when returning data to the client.
  #id = "${var.snapshot_id}"
  #state = "${var.snapshot_state}"
}

# Gets a list of export sets in a compartment and availability domain
data "oci_file_storage_export_sets" "export_sets" {
  count = local.use_fss ? 1 : 0
  #Required
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "${var.export_set_display_name}"
  #id = "${var.export_set_id}"
  #state = "${var.export_set_state}"
}

data "oci_core_private_ips" ip_mount_target1 {
  count = local.use_fss ? 1 : 0
  subnet_id = "${oci_file_storage_mount_target.my_mount_target_1[0].subnet_id}"

  filter {
    name   = "id"
    #values = ["${oci_file_storage_mount_target.my_mount_target_1[0].private_ip_ids.0}"]
    values = [element(concat(oci_file_storage_mount_target.my_mount_target_1.*.private_ip_ids.0, [""]), 0)]
      
  }
}


resource "oci_file_storage_export" "my_export_fs1_mt1" {
  count = local.use_fss ? 1 : 0
  #Required
  export_set_id  = "${oci_file_storage_export_set.my_export_set_1[0].id}"
  file_system_id = "${oci_file_storage_file_system.sas_nfs[0].id}"
  path           = "${var.export_path_fs1_mt1}"

  export_options {
    source                         = "${var.vpc-cidr}"
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = true
  }
}




resource "oci_file_storage_export_set" "my_export_set_1" {
  count = local.use_fss ? 1 : 0
  # Required
  mount_target_id = "${oci_file_storage_mount_target.my_mount_target_1[0].id}"

  # Optional
  display_name      = "${var.export_set_name_1}"
  max_fs_stat_bytes = "${var.max_byte}"
  #max_fs_stat_files = "${var.max_files}"
}


resource "oci_file_storage_file_system" "sas_nfs" {
  count = local.use_fss ? 1 : 0
  #Required
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid

  #Optional
  display_name = "${var.file_system_1_display_name}"
}


resource "oci_file_storage_mount_target" "my_mount_target_1" {
  count = local.use_fss ? 1 : 0
  #Required
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id   = var.compartment_ocid
  #subnet_id        = local.privateb_subnet_id
  ##subnet_id        = "${oci_core_subnet.privateb.*.id[0]}"
  subnet_id        = local.sas_private_subnet_id


  #Optional
  hostname_label      = "${var.nfs["hostname_prefix"]}"
  display_name = "${var.mount_target_1_display_name}"
}



# Use export_set.tf config to update the size for a mount target


resource "oci_file_storage_snapshot" "my_snapshot" {
  count = local.use_fss ? 1 : 0
  #Required
  file_system_id = "${oci_file_storage_file_system.sas_nfs[0].id}"
  name           = "${var.snapshot_name}"
}


variable "file_system_1_display_name" {
  default = "sas_nfs"
}

variable "mount_target_1_display_name" {
  default = "sas_nfs_mount_target"
}

# This is for FSS export path, not for mounted directory path
variable "export_path_fs1_mt1" {
  default = "/sas_nfs"
}


variable "snapshot_name" {
  default = "20180320_daily"
}

variable "export_set_name_1" {
  default = "export set for mount target 1"
}

# 214748364800 bytes = 200 GiB
variable "max_byte" {
  default = 214748364800
}


locals {
  mount_target_1_ip_address = local.use_fss ? lookup(data.oci_core_private_ips.ip_mount_target1[0].private_ips[0], "ip_address") : ""
  # "${lookup(element(concat(data.oci_core_private_ips.ip_mount_target1.*.private_ips[0], [""]), 0), "ip_address")}"
  export_path_fs1_mt1 = "${var.export_path_fs1_mt1}"
}
