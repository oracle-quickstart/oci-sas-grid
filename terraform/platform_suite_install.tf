
# For first Grid nodes (node 1). Grid Control Server.
resource "null_resource" "platform_suite_install" {
  depends_on = [ oci_core_instance.grid , null_resource.wait_for_grid_cloud_init_to_complete, null_resource.configure_grid_node , null_resource.load_install_data ]
  #count = "1"
  count = local.phase2_install_configure_sas ? 1 : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id[0]"
  }

# platform_suite_install_1.sh
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
#"echo about to run /tmp/nodes-cloud-init-complete-status-check.sh",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /tmp/platform_suite_install_1.sh'",
      "sudo -s bash -c 'set -x && /tmp/platform_suite_install_as_root_user.sh'",
    ]
  }
}

# For rest of the Grid nodes (2 ..n)
resource "null_resource" "platform_suite_install_subsequent_grid_nodes" {
  depends_on = [ oci_core_instance.grid, null_resource.platform_suite_install]
  #count = "${var.grid["node_count"] - 1}"
  count = local.phase2_install_configure_sas ? (var.grid["node_count"] - 1) : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id"
  }

# platform_suite_install_1.sh
  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, (count.index+1))
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
      host                = element(oci_core_instance.grid.*.private_ip, (count.index+1))
      user                = var.ssh_user
      private_key         = var.ssh_private_key
      bastion_host        = oci_core_instance.bastion[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.ssh_user
      bastion_private_key = var.ssh_private_key
    }
    inline = [
      "set -x",
#"echo about to run /tmp/nodes-cloud-init-complete-status-check.sh",
      "sudo -s bash -c 'set -x && chmod 777 /tmp/*.sh'",
      "sudo -s bash -c 'set -x && /tmp/platform_suite_install_add_grid_nodes.sh'",
      #"sudo -s bash -c 'set -x && /tmp/platform_suite_install_as_root_user.sh'",
    ]
  }
}


resource "null_resource" "platform_suite_install_update_grid_control_node" {
  depends_on = [ null_resource.platform_suite_install_subsequent_grid_nodes ]
  #count = "1"
  count = local.phase2_install_configure_sas ?  1 : 0

  triggers = {
    instance_ids = "oci_core_instance.grid.*.id[0]"
  }

  provisioner "file" {
    source      = "${var.scripts_directory}/"
    destination = "/tmp/"
    connection {
      agent               = false
      timeout             = "30m"
      host                = element(oci_core_instance.grid.*.private_ip, (count.index))
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
      host                = element(oci_core_instance.grid.*.private_ip, (count.index))
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
      "sudo su -l -c 'set -x && /tmp/platform_suite_install_update_grid_control_node.sh'",
    ]
  }
}
