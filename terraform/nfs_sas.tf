// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


# Gets the list of file systems in the compartment
data "oci_file_storage_file_systems" "sas_nfs" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "sas_nfs"
  #id = "ocid1.filesystem.oc1.phx.aaaaaaaaaaaaawynobuhqllqojxwiotqnb4c2ylefuyqaaaa"
  #state = "DELETED"

  #filter {
  #  name = "defined_tags.example-tag-namespace-all.example-tag"
  #  values = ["value"]
  #}
}

# Gets the list of mount targets in the compartment
data "oci_file_storage_mount_targets" "mount_targets" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "${var.mount_target_display_name}"
  #export_set_id = "${var.mount_target_export_set_id}"
  #id = "${var.mount_target_id}"
  #state = "${var.mount_target_state}"

  #filter {
  #  name = "freeform_tags.Department"
  #  values = ["Accounting"]
  #}
}

# Gets the list of exports in the compartment
data "oci_file_storage_exports" "exports" {
  #Required
  compartment_id = "${var.compartment_ocid}"

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #export_set_id = "${oci_file_storage_mount_target.my_mount_target_1.export_set_id}"
  #file_system_id = "${oci_file_storage_file_system.my_fs.id}"
  #id = "${var.export_id}"
  #state = "${var.export_state}"
}

# Gets a list of snapshots for a particular file system
data "oci_file_storage_snapshots" "snapshots" {
  #Required
  file_system_id = "${oci_file_storage_file_system.sas_nfs.id}"

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #id = "${var.snapshot_id}"
  #state = "${var.snapshot_state}"

  #filter {
  #  name = "freeform_tags.Department"
  #  values = ["Accounting"]
  #}
}

# Gets a list of export sets in a compartment and availability domain
data "oci_file_storage_export_sets" "export_sets" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"

  #Optional fields. Used by the service to filter the results when returning data to the client.
  #display_name = "${var.export_set_display_name}"
  #id = "${var.export_set_id}"
  #state = "${var.export_set_state}"
}

data "oci_core_private_ips" ip_mount_target1 {
  subnet_id = "${oci_file_storage_mount_target.my_mount_target_1.subnet_id}"

  filter {
    name   = "id"
    values = ["${oci_file_storage_mount_target.my_mount_target_1.private_ip_ids.0}"]
  }
}
// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_file_storage_export" "my_export_fs1_mt1" {
  #Required
  export_set_id  = "${oci_file_storage_export_set.my_export_set_1.id}"
  file_system_id = "${oci_file_storage_file_system.sas_nfs.id}"
  path           = "${var.export_path_fs1_mt1}"

  export_options {
    source                         = "${var.export_read_write_access_source}"
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = true
  }

  export_options {
    source                         = "${var.export_read_only_access_source}"
    access                         = "READ_ONLY"
    identity_squash                = "ALL"
    require_privileged_source_port = true
  }
}
/*
resource "oci_file_storage_export" "my_export_fs1_mt2" {
  #Required
  export_set_id  = "${oci_file_storage_export_set.my_export_set_2.id}"
  file_system_id = "${oci_file_storage_file_system.sas_nfs.id}"
  path           = "${var.export_path_fs1_mt2}"
}
*/
/*
resource "oci_file_storage_export" "my_export_fs2_mt1" {
  #Required
  export_set_id  = "${oci_file_storage_export_set.my_export_set_1.id}"
  file_system_id = "${oci_file_storage_file_system.sas_nfs_2.id}"
  path           = "${var.export_path_fs2_mt1}"
}
*/
// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_file_storage_export_set" "my_export_set_1" {
  # Required
  mount_target_id = "${oci_file_storage_mount_target.my_mount_target_1.id}"

  # Optional
  display_name      = "${var.export_set_name_1}"
  max_fs_stat_bytes = "${var.max_byte}"
  #max_fs_stat_files = "${var.max_files}"
}
/*
resource "oci_file_storage_export_set" "my_export_set_2" {
  # Required
  mount_target_id = "${oci_file_storage_mount_target.my_mount_target_2.id}"

  # Optional
  display_name      = "${var.export_set_name_2}"
  max_fs_stat_bytes = "${var.max_byte}"
  #max_fs_stat_files = "${var.max_files}"
}
*/
// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_file_storage_file_system" "sas_nfs" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"

  #Optional
  display_name = "${var.file_system_1_display_name}"
  #defined_tags = "${map("example-tag-namespace-all.example-tag", "value")}"

  freeform_tags = {
    "Department" = "Finance"
  }
}

resource "oci_file_storage_file_system" "sas_nfs_2" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"

  #Optional
  display_name = "${var.file_system_2_display_name}"
  #defined_tags = "${map("example-tag-namespace-all.example-tag", "value")}"

  freeform_tags = {
    "Department" = "Accounting"
  }
}
// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_instance" "my_instance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "my instance with FSS access"
  hostname_label      = "myinstance"
  shape               = "${var.instance_shape}"
subnet_id        = (local.existing_vcn ? local.gpfs_private_subnet : "")
# subnet_id           = "${oci_core_subnet.privateb.*.id[0]}"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  timeouts {
    create = "60m"
  }
}

resource "null_resource" "mount_fss_on_instance" {
  depends_on = ["oci_core_instance.my_instance",
    "oci_file_storage_export.my_export_fs1_mt1",
  ]
 count=1

  provisioner "remote-exec" {
connection {
agent               = false
timeout             = "30m"
host                = element(oci_core_instance.my_instance.*.private_ip, count.index)
user                = var.ssh_user
private_key         = var.ssh_private_key
bastion_host        = oci_core_instance.bastion[0].public_ip
bastion_port        = "22"
bastion_user        = var.ssh_user
bastion_private_key = var.ssh_private_key
}
    inline = [
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir -p /mnt${var.export_path_fs1_mt1}",
      "sudo mount ${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1} /mnt${var.export_path_fs1_mt1}",
    ]
  }
}
// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_file_storage_mount_target" "my_mount_target_1" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
subnet_id        = (local.existing_vcn ? local.gpfs_private_subnet : "")
#subnet_id           = "${oci_core_subnet.privateb.*.id[0]}"

  #Optional
  hostname_label      = "${var.nfs["hostname_prefix"]}"
  display_name = "${var.mount_target_1_display_name}"
  #defined_tags = "${map("example-tag-namespace-all.example-tag", "value")}"

  freeform_tags = {
    "Department" = "Finance"
  }
}

/*
resource "oci_file_storage_mount_target" "my_mount_target_2" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
subnet_id        = (local.existing_vcn ? local.gpfs_private_subnet : ${oci_core_subnet.privateb.*.id[0]})
#  subnet_id           = "${oci_core_subnet.privateb.*.id[0]}"

  #Optional
  display_name = "${var.mount_target_2_display_name}"
  #defined_tags = "${map("example-tag-namespace-all.example-tag", "value")}"

  freeform_tags = {
    "Department" = "Accounting"
  }
}
*/

# Use export_set.tf config to update the size for a mount target

// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_file_storage_snapshot" "my_snapshot" {
  #Required
  file_system_id = "${oci_file_storage_file_system.sas_nfs.id}"
  name           = "${var.snapshot_name}"
  #defined_tags   = "${map("example-tag-namespace-all.example-tag", "value")}"

  freeform_tags = {
    "Department" = "Finance"
  }
}


variable "file_system_1_display_name" {
  default = "sas_nfs"
}

variable "file_system_2_display_name" {
  default = "sas_nfs_2"
}

variable "mount_target_1_display_name" {
  default = "sas_nfs_mount_target"
}

variable "mount_target_2_display_name" {
  default = "sas_nfs_mount_target_2"
}

# Will be created under /mnt folder.   eg: /mnt/sas/nfs
variable "export_path_fs1_mt1" {
  default = "/sas/nfs"
}

variable "export_path_fs1_mt2" {
  default = "/sas/nfs2"
}


variable "snapshot_name" {
  default = "20180320_daily"
}

variable "export_set_name_1" {
  default = "export set for mount target 1"
}

variable "export_set_name_2" {
  default = "export set for mount target 2"
}

# 214748364800 bytes = 200 GiB
variable "max_byte" {
  default = 214748364800
}

/*
variable "max_files" {
  default = 223442
}
*/

variable "export_read_write_access_source" {
  default = "10.0.0.0/16"
}

variable "export_read_only_access_source" {
  default = "0.0.0.0/0"
}

variable "instance_image_ocid" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.5-2018.05.09-1"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaazregkysspxnktw35k4r5vzwurxk6myu44umqthjeakbkvxvxdlkq"

    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaa6ybn2lkqp2ejhijhehf5i65spqh3igt53iyvncyjmo7uhm5235ca"
    uk-london-1  = "ocid1.image.oc1.uk-london-1.aaaaaaaayodsld656eh5stds5mo4hrmwuhk2ugin4eyfpgoiiskqfxll6a4a"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaozjbzisykoybkppaiwviyfzusjzokq7jzwxi7nvwdiopk7ligoia"
  }
}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

locals {
  mount_target_1_ip_address = "${lookup(data.oci_core_private_ips.ip_mount_target1.private_ips[0], "ip_address")}"
  export_path_fs1_mt1 = "${var.export_path_fs1_mt1}"
}
