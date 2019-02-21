resource "oci_core_instance" "sas_grid" {
  count               = "${var.sas_grid_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "SAS Grid Server " #${format("%01d", count.index+1)}
  hostname_label      = "SAS-Grid-Server-" #${format("%01d", count.index+1)}
  shape               = "${var.sas_grid_server_shape}"
  subnet_id           = "${oci_core_subnet.sasgrid_private.*.id[var.AD - 1]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    #boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    #user_data = "${base64encode(data.template_file.boot_script.rendered)}"
    #user_data =  "${base64encode(file(../scripts/lustre.sh))}"
    #user_data           = "${base64encode(file("../scripts/sas_grid.sh"))}"
  }

  timeouts {
    create = "60m"
  }

}



resource "oci_core_instance" "sas_metadata" {
  count               = "${var.sas_metadata_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "SAS MetaData Server " # ${format("%01d", count.index+1)}
  hostname_label      = "SAS-MetaData-Server-" #${format("%01d", count.index+1)}
  shape               = "${var.sas_metadata_server_shape}"
  subnet_id           = "${oci_core_subnet.sasgrid_private.*.id[var.AD - 1]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    #boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    #user_data = "${base64encode(data.template_file.boot_script.rendered)}"
    #user_data =  "${base64encode(file(../scripts/lustre.sh))}"
    #user_data           = "${base64encode(file("../scripts/lustre.sh"))}"
  }

  timeouts {
    create = "60m"
  }

}


resource "oci_core_instance" "sas_midtier" {
  count               = "${var.sas_midtier_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "SAS Midtier Server " #${format("%01d", count.index+1)}
  hostname_label      = "SAS-Midtier-Server-" #${format("%01d", count.index+1)}
  shape               = "${var.sas_midtier_shape}"
  subnet_id           = "${oci_core_subnet.sasgrid_private.*.id[var.AD - 1]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    #boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    #user_data = "${base64encode(data.template_file.boot_script.rendered)}"
    #user_data =  "${base64encode(file(../scripts/lustre.sh))}"
    #user_data           = "${base64encode(file("../scripts/sas_midtier.sh"))}"
  }

  timeouts {
    create = "60m"
  }

}





/* bastion instances */

resource "oci_core_instance" "bastion" {
  count = "${var.bastion_server_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "bastion ${format("%01d", count.index+1)}"
  shape               = "${var.bastion_server_shape}"
  hostname_label      = "bastion-${format("%01d", count.index+1)}"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.public.*.id[var.AD - 1]}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }


  source_details {
    source_type = "image"
    source_id   = "${var.InstanceImageOCID[var.region]}"
  }
}


/* Remote Desktop Gateway instances */

resource "oci_core_instance" "remote_desktop_gateway" {
  count = "${var.remote_desktop_gateway_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Remote Desktop Gateway ${format("%01d", count.index+1)}"
  shape               = "${var.remote_desktop_gateway_shape}"
  hostname_label      = "remote-desktop-gateway-${format("%01d", count.index+1)}"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.public.*.id[var.AD - 1]}"
    skip_source_dest_check = true
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }


  source_details {
    source_type = "image"
    source_id   = "${var.InstanceImageOCID[var.region]}"
  }
}




