# metadata-0
resource "oci_core_instance" "metadata" {
  depends_on = [ oci_file_storage_export.my_export_fs1_mt1 ] 
  display_name        = "metadata-${count.index+1}"
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  shape               = "${var.metadata["shape"]}"
  fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"

  source_details {
    source_id   = var.images[var.region]
    source_type = "image"
  }

  create_vnic_details {
subnet_id           = local.privateb_subnet_id
#subnet_id        = "${oci_core_subnet.privateb.*.id[0]}"
    hostname_label   = "metadata-${count.index+1}"
assign_public_ip = "false"
  }

launch_options {
  network_type = "VFIO"
}


  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = "${base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      "set -x",
      "sshPublicKey=\"${var.ssh_public_key}\"",
      "sasUserPassword=\"${random_string.sas_user_password.result}\"",
      "nfsMountDeviceName=${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1}",
      "nfsMountDirectory=${var.nfs_mount_directory}",
      "metadataNodeCount=${var.metadata["node_count"]}",
      "metadataDiskCount=${var.metadata["disk_count"]}",
      "metadataNodeHostnamePrefix=${var.metadata["hostname_prefix"]}",
      "gridNodeCount=${var.grid["node_count"]}",
      "gridNodeHostnamePrefix=${var.grid["hostname_prefix"]}",
      "gridDiskCount=${var.grid["disk_count"]}",
      "midTierNodeCount=${var.mid_tier["node_count"]}",
      "midTierDiskCount=${var.mid_tier["disk_count"]}",
      "midTierNodeHostnamePrefix=${var.mid_tier["hostname_prefix"]}",
      "clusterName=${var.grid["cluster_name"]}",
      "sasDepotRoot=${var.sas_depot["root"]}",
      "sasDepotDownloadUrl=${var.sas_depot["download_url"]}",
      "sasDepotDownloadUrlPlanFile=${var.sas_depot["download_url_plan_file"]}",
      "sasDepotDownloadUrlLSFLicenseFile=${var.sas_depot["download_url_lsf_license_file"]}",
      "sasDepotDownloadUrlSAS94LicenseFile=${var.sas_depot["download_url_sas94_license_file"]}",
      "lsfTop=${var.lsf_home_path}",
      "jsTop=${var.platform_suite["js_top"]}",
      "metadataSASHomePath=${var.metadata_sas_home_path}",
      "metadataSASConfigPath=${var.metadata_sas_config_path}",
      "midTierSASHomePath=${var.mid_tier_sas_home_path}",
      "midTierSASConfigPath=${var.mid_tier_sas_config_path}",
      "sasWorkPath=${var.sas_work_path}",
      "sasDataPath=${var.sas_data_path}",
      "gridSASConfigPath=${var.grid_sas_config_path}",
      "gridSASHomePath=${var.grid_sas_home_path}",
      "gridJobPath=${var.grid_job_path}",
      "lsfHomePath=${var.lsf_home_path}",
      file("../scripts/firewall.sh"),
      file("../scripts/install.sh"),
      file("../scripts/metadata_disks.sh"),
      file("../scripts/x11_setup.sh"),
      file("../scripts/nfs.sh"),
     "touch /tmp/cloud_init.complete"
     )))}"
  }

  count = "${var.metadata["node_count"]}"
}


resource "oci_core_volume" "metadata" {
  count               = "${var.metadata["node_count"] * var.metadata["disk_count"]}"
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "metadata${(count.index % var.metadata["node_count"])+1}-volume${(floor(count.index / var.metadata["node_count"]))+1}"
  size_in_gbs         = "${var.metadata["disk_size"]}"
}

resource "oci_core_volume_attachment" "metadata" {
  count           = "${var.metadata["node_count"] * var.metadata["disk_count"]}"
  attachment_type = "iscsi"
#  compartment_id  = var.compartment_ocid
  instance_id     = "${oci_core_instance.metadata.*.id[count.index % var.metadata["node_count"]]}"
  volume_id       = "${oci_core_volume.metadata.*.id[count.index]}"
}



output "Metadata_Private_IPs" {
  value = "${join(",", oci_core_instance.metadata.*.private_ip)}"
}
