# oci-sas-grid

This Terraform modules provisions all infrastructure required to deploy [SAS Grid](http://support.sas.com/software/products/gridmgr/index.html) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).

## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle-quickstart/oci-prerequisites).

## Clone the Terraform template
Now, you'll want a local copy of this repo.  You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-sas-grid
    cd oci-sas-grid/terraform
    ls

## Update variables.tf file (optional)
This is optional, but you can update the `variables.tf` to change compute shapes, block volumes, etc. 

## Deployment and Post Deployment
Deploy using standard Terraform commands

    terraform init
    terraform plan
    terraform apply

![](./images/Single-Node-TF-apply.PNG)
