###
## Variables.tf for Terraform
###

# 1 , 2 , 3
variable "AD" { default = "3" }

variable "vpc-cidr" { default = "10.0.0.0/16" }

variable "use_existing_vcn" {
  default = "false"
}

variable "vcn_id" {
  default = ""
}

variable "public_subnet_id" {
  default = ""
}

variable "private_subnet_id" {
  default = ""
}
# if you are using dedicated nodes for file server and they are Bare metal with 2 physical NICs, then 2 subnets are required and all grid nodes will be provisioned in below subnet.
variable "privateb_subnet_id" {
  default = ""
}


# We recommend using OCI Object Storage to upload sas_depot tgz and create Pre-authenticated request to use below.
variable "sas_depot" {
  type = "map"
  default = {
    # Only provide the top/root level folder name for the SAS_Depot tgz file.  By defaut,  it is "SAS_Depot"
    root      = "SAS_Depot_9C7Q4X"
    # URL to the SAS_Depot in tgz format to download from.  It will be download to SASDEPOT folder on NFS filesystem as part of the install process.
    # You can use OCI Object Storage to store the SAS_Depot tgz file and provide the pre-authenticated URL here.
    download_url = "http://host.com/SAS_Depot.tgz"
    # Filename has to be plan.xml
    download_url_plan_file = "http://host.com/plan.xml"
    download_url_lsf_license_file = "http://host.com/LSF94_9CHHX3_70257869_LINUX_X86-64.txt"
    download_url_sas94_license_file = "http://host.com/SAS94_9CHHX3_70257869_LINUX_X86-64.txt"
  }
}


# CentOS7.8.2003  -  3.10.0-1127.10.1.el7.x86_64
variable "images" {
  type = map(string)
    default = {
        // See https://docs.us-phoenix-1.oraclecloud.com/images/ or https://docs.cloud.oracle.com/iaas/images/
        // Oracle-provided image "CentOS-7-2020.06.16-0"
        // https://docs.oracle.com/en-us/iaas/images/image/38c87774-4b0a-440a-94b2-c321af1824e4/
	  us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaasa5eukeizlabgietiktm7idhpegni42d4d3xz7kvi6nyao5aztlq"
	  us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaajw5o3qf7cha2mgov5vxnwyctmcy4eqayy7o4w7s6cqeyppqd3smq"
    }
}
# or
# Custom image:  OL-RHCK image with Spectrum Scale binaries pre-installed
# or
# Custom image:  OL-RHCK image



# Windows images
# https://docs.cloud.oracle.com/iaas/images/image/09f3e226-681f-405d-bc27-070896f44973/
# https://docs.cloud.oracle.com/iaas/images/windows-server-2016-vm/
# Windows-Server-2016-Standard-Edition-VM-Gen2-2019.07.15-0
variable "w_images" {
  type = map(string)
  default = {
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaabebjqpcnnnd5eojzto7twrw6wphiruxhhvj7nfve7q4cjtkyl7eq"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaavwcdcjgqrsi5antj4lrqnnpmiivijcv22vjvranz5v3ozntgt6na"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaahs5qx52v3a4n72o42v3eonrrj2dhwokni3rmv3ym5l32actm6tma"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa4ktddg54ca2gqvbusjfnpjfk4n4yvkoygpsphfwolapwep7v63qq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4qimrpdogtno7c6h3dh3j66mnpjzpeufn6he6lydim3ftzto7bkq"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaorf2gr7rdxhhliesbrqx3ktomesmghgdnysqwh5tpfcd2ge2y2za"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaao7li5qsxa6wdzysoq4pz7marynzyff57eu4uilv4tgkezs5djvxa"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaokudtg52d3palj2uq5aeli7rtl3uedbbbwlb7btv4upj34rdhbma"
    us-langley-1 = "ocid1.image.oc2.us-langley-1.aaaaaaaa6ijhwlviofxlohfhp6um57tn3d2owjqa2amh5v4euhwd5rkysaeq"
    us-luke-1 = "ocid1.image.oc2.us-luke-1.aaaaaaaaskxgygvujodzad4ghkelizqfjaq5m5sbjvg7ew5mydrkylcofyma"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaae7gdb5asazzy3fx2k4magi3mbvp7natm6xzgbjfyzcvnxns2uvwa"
  }
}



variable "mid_tier" {
  type = "map"
  default = {
    #shape      = "VM.Standard2.16"
    shape      = "VM.Standard2.1"
    node_count = 1
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "mid-tier-"
    boot_volume_size = 50
    }
}

# BM.DenseIO2.52 , VM.DenseIO2.24
variable "grid" {
  type = "map"
  default = {
    #shape      = "VM.DenseIO2.24"
    shape      = "VM.Standard2.2"
    node_count = 2
    disk_count = 0
    disk_size  = 50
    hostname_prefix = "grid-"
    cluster_name = "oci_sasgrid"
    boot_volume_size = 100

  }
}

variable "metadata" {
  type = "map"
  default = {
#    shape      = "VM.Standard2.16"
    shape      = "VM.Standard2.1"
    node_count = 1
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "metadata-"
    boot_volume_size = 50
  }
}

variable metadata_sas_home_path { default="/sas/SASHOME" }
variable metadata_sas_config_path { default="/sas/SASCFG" }
variable mid_tier_sas_home_path { default="/sas/SASHOME" }
variable mid_tier_sas_config_path { default="/sas/SASCFG" }
variable sas_work_path { default="/sas/SASWORK" }
variable sas_data_path { default="/gpfs/fs1" }


variable "bastion" {
  type = "map"
  default = {
    shape      = "VM.Standard2.2"
    node_count = 1
    hostname_prefix = "sas-bastion-"
    boot_volume_size = 100
  }
}

variable "remote_desktop_gateway" {
  type = "map"
  default = {
    shape      = "VM.Standard2.4"
    #node_count = 1
    node_count = 0
    hostname_prefix = "rdg-"
    boot_volume_size = 256
  }
}




/*
Decide - which fs will be used as shared storage for grid home, config, lsf home and sas_depot installer files
*/
# valid values -  fss, nfs, gpfs, lustre
# fss is OCI managed NFS service.
# Use nfs for Customer managed NFS server. Support for custom NFS server will be added in future
variable shared_storage_grid_nodes_fs_type { default="fss" }

# Applicable for gpfs only - converged/non-converged.  converged should be used for Direct attached GPFS. non-converged for NSD GPFS. If using other file system, keep this variable unchanged.
variable "converged" {
  default = "converged"
}


/*
if planning to use FSS NFS service as shared storage, if not, comment the below variables
*/
# Lustre:  ${mgs_ip}@tcp1:/$fsname
# FSS/NFS: $ip:$export_path - x:x:x:x:/sas_nfs. This automation create FSS nfs file system, so no need to specify any default, keep it blank.
# GPFS: not used
variable mount_device_name { default="" }

# Lustre:  /mnt/lustre
# FSS/NFS: /mnt/sas/nfs
# GPFS: /gpfs/fs1
variable mount_directory { default="/mnt/sas/nfs" }
#
# IMPORTANT - All the below path needs to be a sub directory under var.mount_directory.
#
variable grid_sas_config_path { default="/mnt/sas/nfs/SASCFG" }
variable grid_sas_home_path { default="/mnt/sas/nfs/SASHOME" }
variable grid_job_path { default="/mnt/sas/nfs/GRIDJOB" }
variable lsf_home_path { default="/mnt/sas/nfs/APPLSF" }

locals {
  mount_directory   = var.mount_directory
  mount_device_name = (var.shared_storage_grid_nodes_fs_type == "fss" ? "${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1}" : var.mount_device_name)
}

# "nfsMountDeviceName=${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1}",
# "mountDeviceName=${local.mount_device_name}",
# "sharedStorageGridNodesFsType=${var.shared_storage_grid_nodes_fs_type}",
/*
if planning to use GPFS as shared storage, if not, comment the below variables
*/
/* - Commented

# Lustre:  ${mgs_ip}@tcp1:/$fsname
# FSS/NFS: $ip:$export_path
# GPFS: not used
variable mount_device_name { default="not-applicable" }

# Lustre:  /mnt/lustre
# FSS/NFS: /mnt/sas/nfs
# GPFS: /gpfs/fs1
variable mount_directory { default="/gpfs/fs1" }
#
# IMPORTANT - All the below path needs to be a sub directory under var.mount_directory.
#
variable grid_sas_config_path { default="/gpfs/fs1/SASCFG" }
variable grid_sas_home_path { default="/gpfs/fs1/SASHOME" }
variable grid_job_path { default="/gpfs/fs1/GRIDJOB" }
variable lsf_home_path { default="/gpfs/fs1/APPLSF" }

*/


/*
if planning to use Lustre as shared storage, if not, comment the below variables
*/
/* - Commented

# Lustre:  ${mgs_ip}@tcp1:/$fsname
# FSS/NFS: $ip:$export_path
# GPFS: not used
variable mount_device_name { default="1.1.1.1@tcp1:/lustrefs" }

# Lustre:  /mnt/lustre
# FSS/NFS: /mnt/sas/nfs
# GPFS: /gpfs/fs1
variable mount_directory { default="/mnt/lustre" }
#
# IMPORTANT - All the below path needs to be a sub directory under var.mount_directory.
#
variable grid_sas_config_path { default="/mnt/lustre/SASCFG" }
variable grid_sas_home_path { default="/mnt/lustre/SASHOME" }
variable grid_job_path { default="/mnt/lustre/GRIDJOB" }
variable lsf_home_path { default="/mnt/lustre/APPLSF" }

*/



/*
Only applicable for OCI FSS NFS shared storage
Used in fss_nfs_sas.tf for target mount point
*/
variable "nfs" {
  type = "map"
  default = {
    hostname_prefix = "sas-nfs"
  }
}



/* This node is not created */
variable "client_utility" {
  type = "map"
  default = {
    shape      = "VM.Standard2.1"
    node_count = 0
    hostname_prefix = "cu-"
  }
}


/*
  Generally, this should not require a change by the deployer.
*/
variable "platform_suite" {
  type = "map"
  default = {
    js_top = "/usr/share/pm"
  }
}


########################################################################################
# This deployment happens in 4 steps and below flags are used control the execution
# Steps
# a. By default - Provision n/w, compute, storage for sas grid and OCI FSS NFS (if shared storage is fss) and configure linux for SAS requirements
# b. install_configure_gpfs/install_configure_lustre - Provision GPFS or Luste resources and configure it
# c. load_install_data - Mount Shared Storage on SAS nodes and load SASDEPOT binaries and license files, etc.
# d. install_configure_sas - Install and Configure SAS binaries on SAS nodes
########################################################################################
# used to control - provisioning and configuration of resources
# currently only supports converged direct attached architecture of GPFS. There are other automation scripts for NSD arch GPFS or client only GPFS clusters.
variable "install_configure_gpfs" {
  default = "false"
}

# used to control - provisioning and configuration of resources
# placeholder to integrate lustre client install. There are other automation scripts for full lustre install (server+clients)
variable "install_configure_lustre" {
  default = "false"
}

# used to control - provisioning and configuration of resources
# After a shared file system is ready, set this to true to mount the shared fs and to load SAS_DEPOT binaries.
variable "load_install_data" {
  default = "false"
}
  
# used to control - provisioning and configuration of resources
variable "install_configure_sas" {
  default = "false"
}



###############
# Configs which users should not be changing to deploy
###############

# Generate a new strong password for sas user
resource "random_string" "sas_user_password" {
  length  = 16
  special = true
}

output "SAS_User_Password" {
  value = ["${random_string.sas_user_password.result}"]
}

variable "ssh_user" { default = "opc" }
# For Ubuntu images,  set to ubuntu instead of opc

variable "scripts_directory" { default="../scripts" }

locals {
  public_subnet_id   = var.use_existing_vcn ? var.public_subnet_id : element(concat(oci_core_subnet.public.*.id, [""]), 0)
  private_subnet_id  = var.use_existing_vcn ? var.private_subnet_id : element(concat(oci_core_subnet.private.*.id, [""]), 0)
  privateb_subnet_id = var.use_existing_vcn ? var.privateb_subnet_id : element(concat(oci_core_subnet.privateb.*.id, [""]), 0)
  client_subnet_id   = local.privateb_subnet_id
  sas_private_subnet_id = local.is_converged ? local.private_subnet_id : local.privateb_subnet_id
}


locals {
  use_fss = var.shared_storage_grid_nodes_fs_type == "fss" ? true :  false
  phase1_install_configure_gpfs = local.use_fss ? false : (var.shared_storage_grid_nodes_fs_type == "gpfs" ? (var.install_configure_gpfs ? true : false) : false)
  phase1_install_configure_lustre = local.use_fss ? false : (var.shared_storage_grid_nodes_fs_type == "lustre" ? (var.install_configure_lustre ? true : false) : false)
  phase1_load_install_data = var.load_install_data ? true : false
  phase2_install_configure_sas = var.install_configure_sas ? true : false
  is_converged = var.converged == "converged" ? true : false
  #gmm stands for grid+metadata+mid-tier
  gmm_node_ids =  concat(oci_core_instance.grid.*.id, oci_core_instance.metadata.*.id, oci_core_instance.mid-tier.*.id)
  gmm_node_private_ips =  concat(oci_core_instance.grid.*.private_ip, oci_core_instance.metadata.*.private_ip, oci_core_instance.mid-tier.*.private_ip)

}


variable "tenancy_ocid" { }
variable "user_ocid" { }
variable "fingerprint" { }
variable "private_key_path" { }
variable "region" { default = "us-phoenix-1" }
variable "compartment_ocid" { }
variable "ssh_public_key" { }
variable "ssh_private_key" { }
variable "ssh_private_key_path" { }



