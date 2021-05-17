



# grid-0
resource "oci_core_instance" "grid" {
  # To ensure FSS NFS setup is complete for grid to use
depends_on = [ oci_file_storage_export.my_export_fs1_mt1 ]
display_name        = "grid-${count.index+1}"
compartment_id      = var.compartment_ocid
availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
shape               = var.grid["shape"]
fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"

source_details {
source_id   = var.images[var.region]
source_type = "image"
boot_volume_size_in_gbs = var.grid["boot_volume_size"]
}
agent_config {
  is_management_disabled = true
}

create_vnic_details {
#subnet_id           = local.privateb_subnet_id
##subnet_id        = "${oci_core_subnet.privateb.*.id[0]}"
subnet_id        = local.sas_private_subnet_id
hostname_label   = "grid-${count.index+1}"
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
)))}"
}

/*
"sshPublicKey=\"${var.ssh_public_key}\"",
"sasUserPassword=\"${random_string.sas_user_password.result}\"",
"mountDeviceName=${local.mount_device_name}",
"mountDirectory=${var.mount_directory}",
"sharedStorageGridNodesFsType=${var.shared_storage_grid_nodes_fs_type}",
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
"sudo /usr/libexec/oci-growfs -y | egrep 'NOCHANGE:|CHANGED:'",
file("../scripts/firewall.sh"),
file("../scripts/install.sh"),
file("../scripts/grid_disks.sh"),
file("../scripts/x11_setup.sh"),
file("../scripts/load_install_data.sh"),
"touch /tmp/sas_depot_nfs_download.complete",
file("../scripts/grid.sh"),
"touch /tmp/cloud_init.complete"
*/


/*
*/

count = "${var.grid["node_count"]}"
}


resource "oci_core_volume" "grid" {
count               = "${var.grid["node_count"] * var.grid["disk_count"]}"
availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
compartment_id      = var.compartment_ocid
display_name        = "grid${(count.index % var.grid["node_count"])+1}-volume${(floor(count.index / var.grid["node_count"]))+1}"
size_in_gbs         = "${var.grid["disk_size"]}"
}

resource "oci_core_volume_attachment" "grid" {
count           = "${var.grid["node_count"] * var.grid["disk_count"]}"
attachment_type = "iscsi"
#  compartment_id  = var.compartment_ocid
instance_id     = "${oci_core_instance.grid.*.id[count.index % var.grid["node_count"]]}"
volume_id       = "${oci_core_volume.grid.*.id[count.index]}"
}



output "Grid_Private_IPs" {
value = "${join(",", oci_core_instance.grid.*.private_ip)}"
}



# For all sas nodes - to configure iaas & linux settings for grid
resource "null_resource" "configure_grid_node" {
  depends_on = [ oci_core_instance.grid ]
  #count = local.phase2 ? var.grid["node_count"] : 0
  count = var.grid["node_count"]

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id[0]"
  }
  # all script files are copied to the node
  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "file" {
    content        = templatefile("${path.module}/env_variables.sh.tpl", {
      sshPublicKey = var.ssh_public_key,
      sasUserPassword = random_string.sas_user_password.result,
      mountDeviceName = local.mount_device_name,
      mountDirectory = var.mount_directory,
      sharedStorageGridNodesFsType = var.shared_storage_grid_nodes_fs_type,
      gridNodeCount = var.grid["node_count"],
      gridNodeHostnamePrefix = var.grid["hostname_prefix"],
      gridDiskCount = var.grid["disk_count"],
      midTierNodeCount = var.mid_tier["node_count"],
      midTierDiskCount = var.mid_tier["disk_count"],
      midTierNodeHostnamePrefix = var.mid_tier["hostname_prefix"],
      metadataNodeCount = var.metadata["node_count"],
      metadataDiskCount = var.metadata["disk_count"],
      metadataNodeHostnamePrefix = var.metadata["hostname_prefix"],
      clusterName = var.grid["cluster_name"],
      sasDepotRoot = var.sas_depot["root"],
      sasDepotDownloadUrl = var.sas_depot["download_url"],
      sasDepotDownloadUrlPlanFile = var.sas_depot["download_url_plan_file"],
      sasDepotDownloadUrlLSFLicenseFile = var.sas_depot["download_url_lsf_license_file"],
      sasDepotDownloadUrlSAS94LicenseFile = var.sas_depot["download_url_sas94_license_file"],
      lsfTop = var.lsf_home_path,
      jsTop = var.platform_suite["js_top"],
      metadataSASHomePath = var.metadata_sas_home_path,
      metadataSASConfigPath = var.metadata_sas_config_path,
      midTierSASHomePath = var.mid_tier_sas_home_path,
      midTierSASConfigPath = var.mid_tier_sas_config_path,
      sasWorkPath = var.sas_work_path,
      sasDataPath = var.sas_data_path,
      gridSASConfigPath = var.grid_sas_config_path,
      gridSASHomePath = var.grid_sas_home_path,
      gridJobPath = var.grid_job_path,
      lsfHomePath = var.lsf_home_path,
      
    })
    destination   = "/tmp/env_variables.sh"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /tmp/configure_node.sh'",
      "sudo -s bash -c 'set -x && /tmp/consolidated_configure_grid_node.sh'",
    ]
  }
}


# For all sas nodes - to configure iaas & linux settings for grid
resource "null_resource" "configure_metadata_node" {
  depends_on = [ oci_core_instance.metadata ]
  count = var.metadata["node_count"]
  #count = local.phase2 ?  var.metadata["node_count"] : 0

  triggers = {
    instance_ids = "oci_core_instance.metadata.*.id"
  }

  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.metadata.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "file" {
    content        = templatefile("${path.module}/env_variables.sh.tpl", {
      sshPublicKey = var.ssh_public_key,
      sasUserPassword = random_string.sas_user_password.result,
      mountDeviceName = local.mount_device_name,
      mountDirectory = var.mount_directory,
      sharedStorageGridNodesFsType = var.shared_storage_grid_nodes_fs_type,
      gridNodeCount = var.grid["node_count"],
      gridNodeHostnamePrefix = var.grid["hostname_prefix"],
      gridDiskCount = var.grid["disk_count"],
      midTierNodeCount = var.mid_tier["node_count"],
      midTierDiskCount = var.mid_tier["disk_count"],
      midTierNodeHostnamePrefix = var.mid_tier["hostname_prefix"],
      metadataNodeCount = var.metadata["node_count"],
      metadataDiskCount = var.metadata["disk_count"],
      metadataNodeHostnamePrefix = var.metadata["hostname_prefix"],
      clusterName = var.grid["cluster_name"],
      sasDepotRoot = var.sas_depot["root"],
      sasDepotDownloadUrl = var.sas_depot["download_url"],
      sasDepotDownloadUrlPlanFile = var.sas_depot["download_url_plan_file"],
      sasDepotDownloadUrlLSFLicenseFile = var.sas_depot["download_url_lsf_license_file"],
      sasDepotDownloadUrlSAS94LicenseFile = var.sas_depot["download_url_sas94_license_file"],
      lsfTop = var.lsf_home_path,
      jsTop = var.platform_suite["js_top"],
      metadataSASHomePath = var.metadata_sas_home_path,
      metadataSASConfigPath = var.metadata_sas_config_path,
      midTierSASHomePath = var.mid_tier_sas_home_path,
      midTierSASConfigPath = var.mid_tier_sas_config_path,
      sasWorkPath = var.sas_work_path,
      sasDataPath = var.sas_data_path,
      gridSASConfigPath = var.grid_sas_config_path,
      gridSASHomePath = var.grid_sas_home_path,
      gridJobPath = var.grid_job_path,
      lsfHomePath = var.lsf_home_path,
      
    })
    destination   = "/tmp/env_variables.sh"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.metadata.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }


  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.metadata.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /tmp/configure_node.sh'",
      "sudo -s bash -c 'set -x && /tmp/consolidated_configure_metadata_node.sh'",
    ]
  }
}




# For all sas nodes - to configure iaas & linux settings for grid
resource "null_resource" "configure_mid_tier_node" {
  depends_on = [ oci_core_instance.mid-tier ]

  count = var.mid_tier["node_count"]
  #count = local.phase2 ?  var.mid_tier["node_count"] : 0

  triggers = {
    instance_ids = "oci_core_instance.mid-tier.*.id"
  }

  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.mid-tier.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "file" {
    content        = templatefile("${path.module}/env_variables.sh.tpl", {
      sshPublicKey = var.ssh_public_key,
      sasUserPassword = random_string.sas_user_password.result,
      mountDeviceName = local.mount_device_name,
      mountDirectory = var.mount_directory,
      sharedStorageGridNodesFsType = var.shared_storage_grid_nodes_fs_type,
      gridNodeCount = var.grid["node_count"],
      gridNodeHostnamePrefix = var.grid["hostname_prefix"],
      gridDiskCount = var.grid["disk_count"],
      midTierNodeCount = var.mid_tier["node_count"],
      midTierDiskCount = var.mid_tier["disk_count"],
      midTierNodeHostnamePrefix = var.mid_tier["hostname_prefix"],
      metadataNodeCount = var.metadata["node_count"],
      metadataDiskCount = var.metadata["disk_count"],
      metadataNodeHostnamePrefix = var.metadata["hostname_prefix"],
      clusterName = var.grid["cluster_name"],
      sasDepotRoot = var.sas_depot["root"],
      sasDepotDownloadUrl = var.sas_depot["download_url"],
      sasDepotDownloadUrlPlanFile = var.sas_depot["download_url_plan_file"],
      sasDepotDownloadUrlLSFLicenseFile = var.sas_depot["download_url_lsf_license_file"],
      sasDepotDownloadUrlSAS94LicenseFile = var.sas_depot["download_url_sas94_license_file"],
      lsfTop = var.lsf_home_path,
      jsTop = var.platform_suite["js_top"],
      metadataSASHomePath = var.metadata_sas_home_path,
      metadataSASConfigPath = var.metadata_sas_config_path,
      midTierSASHomePath = var.mid_tier_sas_home_path,
      midTierSASConfigPath = var.mid_tier_sas_config_path,
      sasWorkPath = var.sas_work_path,
      sasDataPath = var.sas_data_path,
      gridSASConfigPath = var.grid_sas_config_path,
      gridSASHomePath = var.grid_sas_home_path,
      gridJobPath = var.grid_job_path,
      lsfHomePath = var.lsf_home_path,
      
    })
    destination   = "/tmp/env_variables.sh"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.mid-tier.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.mid-tier.*.private_ip, (count.index))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /tmp/configure_node.sh'",
      "sudo -s bash -c 'set -x && /tmp/consolidated_configure_mid_tier_node.sh'",
    ]
  }
}


resource "null_resource" "install_configure_gpfs" {
  depends_on = [ oci_core_instance.grid, null_resource.configure_grid_node  ]
  count = local.phase1_install_configure_gpfs ? var.grid["node_count"] : 0
  #count = var.grid["node_count"]

  triggers = {
    instance_ids = join("," , oci_core_instance.grid.*.id )
  }

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /usr/bin/hostname'",
      # Add some poll/wait process scripy to ensure all nodes are ready and configured correctly
    ]
  }
}


resource "null_resource" "install_configure_lustre" {
  depends_on = [ oci_core_instance.grid, null_resource.configure_grid_node  ]
  count = local.phase1_install_configure_lustre ? var.grid["node_count"] : 0
  #count = var.grid["node_count"]

  triggers = {
    instance_ids = join("," , oci_core_instance.grid.*.id )
  }

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /usr/bin/hostname'",
    ]
  }
}






resource "null_resource" "load_install_data" {
  depends_on = [ oci_core_instance.grid , oci_core_instance.metadata , oci_core_instance.mid-tier , null_resource.configure_grid_node , null_resource.configure_metadata_node,   null_resource.configure_mid_tier_node, null_resource.install_configure_gpfs  ,  null_resource.install_configure_lustre ,  ]
  #count = local.phase2 ? var.grid["node_count"] : 0
  count = local.phase1_load_install_data ? (var.grid["node_count"] + var.metadata["node_count"] + var.mid_tier["node_count"]) : 0
  #count = var.grid["node_count"]

  triggers = {
    instance_ids = join("," , local.gmm_node_ids )
    # "oci_core_instance.grid.*.id[0]"
  }

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
#      host                = element(oci_core_instance.grid.*.private_ip, count.index)
      host                = element(local.gmm_node_private_ips, count.index)
        
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /usr/bin/hostname'",
      "sudo -s bash -c 'set -x && /tmp/load_install_data.sh'",
    ]
  }
}

