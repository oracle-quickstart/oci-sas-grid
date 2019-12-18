// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

############
# Cloudinit
############
# Generate a new strong password for your instance
resource "random_string" "instance_password" {
  length  = 16
  special = true
}

# Use the cloudinit.ps1 as a template and pass the instance name, user and password as variables to same
data "template_file" "cloudinit_ps1" {
  vars = {
    instance_user     = "${var.instance_user}"
    instance_password = "${random_string.instance_password.result}"
instance_name     = "${var.remote_desktop_gateway["hostname_prefix"]}01"
  }

  template = "${file("${var.userdata}/${var.cloudinit_ps1}")}"
}

data "template_cloudinit_config" "cloudinit_config" {
  gzip          = false
  base64_encode = true

  # The cloudinit.ps1 uses the #ps1_sysnative to update the instance password and configure winrm for https traffic
  part {
    filename     = "${var.cloudinit_ps1}"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloudinit_ps1.rendered}"
  }

  # The cloudinit.yml uses the #cloud-config to write files remotely into the instance, this is executed as part of instance setup
  part {
    filename     = "${var.cloudinit_config}"
    content_type = "text/cloud-config"
    content      = "${file("${var.userdata}/${var.cloudinit_config}")}"
  }
}

###########
# Compute
###########
resource "oci_core_instance" "remote_desktop_gateway" {
  count = "${var.remote_desktop_gateway["node_count"]}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.remote_desktop_gateway["hostname_prefix"]}${format("%01d", count.index + 1)}"
hostname_label      = "${var.remote_desktop_gateway["hostname_prefix"]}${format("%01d", count.index + 1)}"

  shape            = "${var.remote_desktop_gateway["shape"]}"
 #subnet_id        = "${oci_core_subnet.public.*.id[0]}"
subnet_id        = (local.existing_vcn ? local.public_subnet : "")


  # Refer cloud-init in https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/datatypes/LaunchInstanceDetails
  metadata = {
    # Base64 encoded YAML based user_data to be passed to cloud-init
    user_data = "${data.template_cloudinit_config.cloudinit_config.rendered}"
  }

  source_details {
    boot_volume_size_in_gbs = "${var.remote_desktop_gateway["boot_volume_size_in_gbs"]}"
    source_id   = "${var.w_images[var.region]}"
    source_type = "image"
  }

}

data "oci_core_instance_credentials" "InstanceCredentials" {
  instance_id = "${oci_core_instance.remote_desktop_gateway.*.id[0]}"
}



##########
# Outputs
##########
output "Windows_Remote_Desktop_Username" {
  value = ["${data.oci_core_instance_credentials.InstanceCredentials.username}"]
}

output "Windows_Remote_Desktop_Password" {
  value = ["${random_string.instance_password.result}"]
}

output "Windows_Remote_Desktop_Instance_PublicIP" {
  value = ["${oci_core_instance.remote_desktop_gateway.*.public_ip[0]}"]
}

output "Windows_Remote_Desktop_Instance_PrivateIP" {
  value = ["${oci_core_instance.remote_desktop_gateway.*.private_ip[0]}"]
}
