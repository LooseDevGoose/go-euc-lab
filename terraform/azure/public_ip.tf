#PIP used for Azure Bastion
resource "azurerm_public_ip" "pip-bastion" {
  name                = "pip-bastion-${local.environment_abbreviations[terraform.workspace]}"
  resource_group_name = azurerm_resource_group.Bastion.name
  location            = local.azure_location
  allocation_method   = "Dynamic" #Static only allowed by standard sku
  sku                 = "Basic" #Alligning basic SKU, this is cheaper
}