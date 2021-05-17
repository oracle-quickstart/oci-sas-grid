
resource "null_resource" "metadata_server_install" {
  depends_on = [ oci_core_instance.metadata, null_resource.wait_for_grid_cloud_init_to_complete, null_resource.wait_for_metadata_cloud_init_to_complete, null_resource.wait_for_mid_tier_cloud_init_to_complete, null_resource.load_install_data, null_resource.platform_suite_install_update_grid_control_node]
  #count = "${var.metadata["node_count"]}"
  count = local.phase2_install_configure_sas ?  var.metadata["node_count"] : 0

  triggers = {
    instance_ids = "oci_core_instance.metadata.*.id"
  }

  provisioner "file" {
    source      = "../templates/"
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
      "sudo -s bash -c 'set -x && /tmp/metadata_server_install.sh'",
    ]
  }
}



# For first Grid nodes (node 1). Grid Control Server.
resource "null_resource" "grid_control_server_install" {
  depends_on = [ oci_core_instance.grid , null_resource.wait_for_grid_cloud_init_to_complete, null_resource.wait_for_metadata_cloud_init_to_complete, null_resource.wait_for_mid_tier_cloud_init_to_complete, null_resource.load_install_data, null_resource.platform_suite_install_update_grid_control_node,
      null_resource.metadata_server_install]
  #count = "1"
  count = local.phase2_install_configure_sas ?  1 : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id[0]"
  }

  provisioner "file" {
    source      = "../templates/"
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
      "sudo -s bash -c 'set -x && /tmp/grid_control_server_install.sh'",
    ]
  }
}

# For Grid nodes2 -subsequent_grid_nodes_install
resource "null_resource" "grid_nodes_2_install" {
  depends_on = [ oci_core_instance.grid, null_resource.grid_control_server_install]
  #count = 1
  count = local.phase2_install_configure_sas ?  1 : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id"
  }

  provisioner "file" {
    source      = "../templates/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, 1)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }


  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, 1)
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
      host                = element(oci_core_instance.grid.*.private_ip, 1)
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
      "sudo -s bash -c 'set -x && /tmp/grid_node_server_install.sh'",
    ]
  }
}


# For Grid nodes 3
resource "null_resource" "grid_nodes_3_install" {
  depends_on = [ oci_core_instance.grid, null_resource.grid_control_server_install, null_resource.grid_nodes_2_install ]
  #count = "1"
  count = local.phase2_install_configure_sas ?  ( var.grid["node_count"] >= 3 ? 1 : 0 ) : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id"
  }

  provisioner "file" {
    source      = "../templates/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
#      host                = element(oci_core_instance.grid.*.private_ip, (count.index+1))
      host                = element(oci_core_instance.grid.*.private_ip, 2)
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
  }


  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, 2)
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
      host                = element(oci_core_instance.grid.*.private_ip, 2)
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
      "sudo -s bash -c 'set -x && /tmp/grid_node_server_install.sh'",
    ]
  }
}


resource "null_resource" "mid_tier_server_install" {
  depends_on = [ oci_core_instance.mid-tier, null_resource.metadata_server_install, null_resource.grid_control_server_install,
null_resource.grid_nodes_2_install,
null_resource.grid_nodes_3_install]

#     null_resource.subsequent_grid_nodes_install,

  #count = "${var.mid_tier["node_count"]}"
  count = local.phase2_install_configure_sas ?  var.mid_tier["node_count"] : 0

  triggers = {
    instance_ids = "oci_core_instance.mid-tier.*.id"
  }

  provisioner "file" {
    source      = "../templates/"
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
      "sudo -s bash -c 'set -x && /tmp/mid_tier_server_install.sh'",
    ]
  }
}


