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

variable "AD" { default = "3" }

variable "vpc-cidr" { default = "10.0.0.0/16" }

// See https://docs.us-phoenix-1.oraclecloud.com/images/ or https://docs.cloud.oracle.com/iaas/images/
// Oracle-provided image "CentOS-7-2018.08.15-0"
variable "images" {
  type = map(string)
  default = {
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaatz6zixwltzswnmzi2qxdjcab6nw47xne4tco34kn6hltzdppmada"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaah6ui3hcaq7d43esyrfmyqb3mwuzn4uoxjlbbdwoiicdmntlvwpda"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaai3czrt22cbu5uytpci55rcy4mpi4j7wm46iy5wdieqkestxve4yq"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaarbacra7juwrie5idcadtgbj3llxcu7p26rj4t3xujyqwwopy2wva"
  }
}

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

variable "confluent" {
  type = "map"
  default = {
    edition = "Community"
    version = "5.1.2"
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
    shape      = "VM.Standard2.4"
    node_count = 1
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "metadata-"
  }
}

variable "mid_tier" {
  type = "map"
  default = {
    shape      = "VM.Standard2.4"
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
    shape      = "VM.Standard2.1"
    node_count = 3
    disk_count = 2
    disk_size  = 50
    hostname_prefix = "grid-"
    cluster_name = "oci_sasgrid"
  }
}

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
    hostname_prefix = "bastion-"
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
    node_count = 1
    hostname_prefix = "cu-"
  }
}

variable "sas_depot" {
  type = "map"
  default = {
    root      = "/mnt/sas/nfs/SASDEPOT/SAS_Depot_9C7Q4X"
    # URL to the SAS_Depot in tgz format to download from.  It will be download to SASDEPOT folder on NFS filesystem as part of the install process.
    # You can use OCI Object Storage to store the SAS_Depot tgz file and provide the pre-authenticated URL here.
    download_url = "http://host.com/SAS_Depot.tgz"
  }
}

variable "platform_suite" {
  type = "map"
  default = {
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

