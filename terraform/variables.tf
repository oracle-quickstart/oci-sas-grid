###
## Variables.tf for Terraform
###

variable "tenancy_ocid" { }

variable "user_ocid" { }

variable "fingerprint" { }

variable "private_key_path" { }

variable "region" { default = "us-phoenix-1" }

variable "compartment_ocid" { }

variable "ssh_public_key" { }

variable "ssh_private_key" { }

variable "ssh_private_key_path" { }

# For instances created using Oracle Linux and CentOS images, the user name opc is created automatically.
# For instances created using the Ubuntu image, the user name ubuntu is created automatically.
# The ubuntu user has sudo privileges and is configured for remote access over the SSH v2 protocol using RSA keys. The SSH public keys that you specify while creating instances are added to the /home/ubuntu/.ssh/authorized_keys file.
# For more details: https://docs.cloud.oracle.com/iaas/Content/Compute/References/images.htm#one
variable "ssh_user" { default = "opc" }

# For Ubuntu images,  set to ubuntu. 
# variable "ssh_user" { default = "ubuntu" }

variable "AD" { default = "1" }

variable "vpc-cidr" { default = "10.0.0.0/16" }

variable "images" {
  type = map(string)
  default = {
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaabfqn5vmh3pg6ynpo6bqdbg7fwruu7qgbvondjic5ccr4atlj4j7q"
    ap-seoul-1   = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaxfeztdrbpn452jk2yln7imo4leuhlqicoovoqu7cxqhkr3j2zuqa"
    ap-sydney-1    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaanrubykp6xrff5xzd6gu2g6ul6ttnyoxgaeeq434urjz5j6wfq4fa"
    ap-tokyo-1   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaakkqtoabcjigninsyalinvppokmgaza6amynam3gs2ldelpgesu6q"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaab4hxrwlcs4tniwjr4wvqocmc7bcn3apnaapxabyg62m2ynwrpe2a"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawejnjwwnzapqukqudpczm4pwtpcsjhohl7qcqa5vzd3gxwmqiq3q"
    eu-zurich-1   = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa7hdfqf54qcnu3bizufapscopzdlxp54yztuxauxyraprxnqjj7ia"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa2iqobvkeowx4n2nqsgy32etohkw2srqireqqk3bhn6hv5275my6a"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaakgrjgpq3jej3tyqfwsyk76tl25zoflqfjjuuv43mgisrmhfniofq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa5phjudcfeyomogjp6jjtpcl3ozgrz6s62ltrqsfunejoj7cqxqwq"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaag7vycom7jhxqxfl6rxt5pnf5wqolksl6onuqxderkqrgy4gsi3hq"
  }
}

// See https://docs.us-phoenix-1.oraclecloud.com/images/ or https://docs.cloud.oracle.com/iaas/images/
// Oracle-provided image "CentOS-7-2018.08.15-0"
/*
variable "images" {
  type = map(string)
  default = {
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaatz6zixwltzswnmzi2qxdjcab6nw47xne4tco34kn6hltzdppmada"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaah6ui3hcaq7d43esyrfmyqb3mwuzn4uoxjlbbdwoiicdmntlvwpda"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaai3czrt22cbu5uytpci55rcy4mpi4j7wm46iy5wdieqkestxve4yq"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaarbacra7juwrie5idcadtgbj3llxcu7p26rj4t3xujyqwwopy2wva"
  }
}
*/


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



# Generate a new strong password for sas user
resource "random_string" "sas_user_password" {
  length  = 16
  special = true
}

output "SAS_User_Password" {
  value = ["${random_string.sas_user_password.result}"]
}


variable "metadata" {
  type = "map"
  default = {
    shape      = "VM.Standard2.16"
    node_count = 1
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "metadata-"
  }
}

variable "mid_tier" {
  type = "map"
  default = {
    shape      = "VM.Standard2.16"
    node_count = 1
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "mid-tier-"
    }
}

# BM.DenseIO2.52 , VM.DenseIO2.24
variable "grid" {
  type = "map"
  default = {
    shape      = "VM.DenseIO2.24"
    node_count = 3
    disk_count = 0
    disk_size  = 50
    hostname_prefix = "grid-"
    cluster_name = "oci_sasgrid"
  }
}

/* Used in nfs_sas.tf for target mount point */
variable "nfs" {
  type = "map"
  default = {
    hostname_prefix = "sas-nfs"
  }
}

variable "bastion" {
  type = "map"
  default = {
    shape      = "VM.Standard2.2"
    node_count = 1
    hostname_prefix = "sas-bastion-"
  }
}

variable "remote_desktop_gateway" {
  type = "map"
  default = {
    shape      = "VM.Standard2.4"
    node_count = 1
    hostname_prefix = "rdg-"
    boot_volume_size_in_gbs = "256"
  }
}


variable "client_utility" {
  type = "map"
  default = {
    shape      = "VM.Standard2.1"
    node_count = 0
    hostname_prefix = "cu-"
  }
}

variable "sas_depot" {
  type = "map"
  default = {
# Only provide the top/root level folder name for the SAS_Depot files.  By defaut,  it is "SAS_Depot"
    root      = "SAS_Depot_9C7Q4X"
    # URL to the SAS_Depot in tgz format to download from.  It will be download to SASDEPOT folder on NFS filesystem as part of the install process.
    # You can use OCI Object Storage to store the SAS_Depot tgz file and provide the pre-authenticated URL here.
    download_url = "http://host.com/SAS_Depot.tgz"
    object_storage_access_key="83bd53544431dff354452d9685eb6e810b2c8964"
    object_storage_secret_key="BX0B924rOiaR/uP6/bNtJ6onHNSXZPL86uqi5zdxcyo="
  }
}


/*
  Generally, this should not require a change by the deployer.
*/
variable "platform_suite" {
  type = "map"
  default = {
#    lsf_top      = "${local.mount_target_1_ip_address}:${local.export_path_fs1_mt1}/APPLSF"
   lsf_top      = "/mnt/sas/nfs/APPLSF"
    js_top = "/usr/share/pm"
  }
}



variable "scripts_directory" { default="../scripts" }

# "nfsMountDeviceName=${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1}",
# Assuming there is only 1 FileSystem to mount.
variable "nfs_mount_device_name" {
  type = "map"
  default = {
    # if there is an existing NFS filesystem already created using OCI FSS service, then set fss_nfs_exist to "yes", else "no"
    fss_nfs_exist = "no"
    mount_target_ip_address  = ""
    export_path = ""
  }
}

# Uncomment this, if you already created an OCI FSS NFS filesystem in the same vcn private subnet. Also remove nfs_sas.tf, so Terraform will not create new OCI FSS NFS.
###locals {
  # if there is an existing NFS filesystem already created using OCI FSS service, then set fss_nfs_exist to "yes", else "no"
###  fss_nfs_exist = "yes"
###  mount_target_1_ip_address = "1.1.1.1"
###  export_path_fs1_mt1 = "/mnt/sas/nfs"
###}

# To use existing vcn, private and public subnets instead of creating new ones, provide the below 2 values for existing private and public subnets and remove/rename network.tf from current folder (mv network.tf network.tf.backup).  The private subnet should be the subnet which is used by IBM GPFS or Lustre Clients nodes (not server nodes).  The SAS install assumes the Grid nodes were already provisioned and GPFS or Lustre was already installed on them.
variable "private_subnet_ocid_for_sas_install" {
  default = ""
}

variable "public_subnet_ocid_for_sas_install" {
  default = ""
}

# The SAS install assumes the Grid nodes were already provisioned and GPFS or Lustre was already installed on them.
# The first OCID in the list will be used as grid-control manager
variable "grid_nodes_ocids" {
  type    = list(string)
  default = [""]
}



locals {
  gpfs_private_subnet = "ocid1.subnet.oc1.iad.aaaaaaaaufhmbidkvjpabtfbue5vjpegiz6354566xgotbvbqhezyoyl2wuq"
  public_subnet = "ocid1.subnet.oc1.iad.aaaaaaaa2jvfhodwt5yby6tw66622xtxdxnb64iawr4pd6iem4d2wel6a3bq"
  existing_vcn = (length(local.gpfs_private_subnet) > 0 ? true : false)
}
