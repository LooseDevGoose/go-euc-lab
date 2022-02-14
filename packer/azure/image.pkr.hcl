packer {
  required_plugins {
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "azure-arm" "windows" {

#authentication
  client_id                         = var.azure_client_id
  client_secret                     = var.azure_client_secret
  subscription_id                   = var.azure_subscription_id
  tenant_id                         = var.azure_tenant_id

  build_resource_group_name         = var.resource_group
  communicator                      = local.communicator[var.os_type]
  image_offer                       = var.image_offer
  image_publisher                   = var.image_publisher
  image_sku                         = var.image_sku
  os_type                           = var.os_type
  vm_size                           = var.vm_size
  winrm_insecure                    = var.winrm_insecure
  winrm_timeout                     = var.winrm_timeout
  winrm_use_ssl                     = var.winrm_use_ssl
  winrm_username                    = var.winrm_username
  managed_image_name                = "${local.environment_abbreviations[var.environment]}-${var.managed_image_name}"
  managed_image_resource_group_name = "rg-golab-${local.environment_abbreviations[var.environment]}-${var.var.compute_gallery_resource_group}"
  virtual_network_resource_group_name    = "rg-golab-${local.environment_abbreviations[var.environment]}-${var.virtual_network_resource_group_name}" 
  virtual_network_name                   = "vnet-infra-${var.var.virtual_network_name}"  
  virtual_network_subnet_name            = "sn-infra-${var.var.virtual_network_name}"
  private_virtual_network_with_public_ip = var.private_virtual_network_with_public_ip


  shared_image_gallery_destination {
    subscription   = var.subscription_id
    resource_group = "rg-golab-${local.environment_abbreviations[var.environment]}-${var.var.compute_gallery_resource_group}"  
    gallery_name   = var.gallery_name
    image_name     = var.image_name
    image_version  = var.image_version
    replication_regions = [var.replication_regions]
  }
}

build {
  sources = ["source.azure-arm.windows"]
    provisioner "powershell" {
      script = "./scripts/ConfigureRemotingForAnsible.ps1"
}

    provisioner "ansible" {
      playbook_file = "./azure.yml"
      user = "packer"
      use_proxy       = false
      extra_arguments = [
        "-v",
        "-e",
        "ansible_winrm_server_cert_validation=ignore"
      ]
  }
}