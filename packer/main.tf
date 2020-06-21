# Configure the Azure Provider
provider "azurerm" {
    version = "~>2.14"

    features {}
}

# Create a resource group
resource "azurerm_resource_group" "packer_rg" {
  name     = var.AZURE_PACKER_RESOURCE_GROUP
  location = "Canada East"

  tags = {
      environment = "DC902 Packer"
  }
}