resource "oci_core_instance" "bastion" {
  display_name        = "${var.bastion["hostname_prefix"]}${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.AD - 1],"name")
  shape               = var.bastion["shape"]
  fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"

  source_details {
    source_id   = var.images[var.region]
    source_type = "image"
  }

  create_vnic_details {
#subnet_id        = "${oci_core_subnet.public.*.id[0]}"
subnet_id           = local.public_subnet_id

    hostname_label   = "bastion-${count.index}"
  }


  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      "bastionNodeCount=${var.bastion["node_count"]}",
      file("../scripts/firewall.sh")
    )))
  }



  count = var.bastion["node_count"]
}

output "Bastion_Public_IPs" {
  value = join(",", oci_core_instance.bastion.*.public_ip)
}
