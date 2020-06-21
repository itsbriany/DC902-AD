# Configure the Azure Provider
provider "azurerm" {
    version = "~>2.14"

    features {}
}

# Create a resource group
resource "azurerm_resource_group" "dc902_rg" {
  name     = var.AZURE_RESOURCE_GROUP
  location = var.AZURE_REGION

  tags = {
      environment = "DC902"
  }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "dc902_network" {
    name = "dc902_network"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.dc902_rg.location
    resource_group_name = azurerm_resource_group.dc902_rg.name 
}

# Create a subnet in the virtual network. This is required so that we can allocate a subnet inside the virtual network.
resource "azurerm_subnet" "dc902_subnet" {
    name = "demo_subnet"
    resource_group_name = azurerm_resource_group.dc902_rg.name
    virtual_network_name = azurerm_virtual_network.dc902_network.name
    address_prefixes = ["10.0.2.0/24"]
}

# Assign public IP addresses. This is necessary for accessing resources accross the Internet.
resource "azurerm_public_ip" "dc01_public_ip" {
    name                         = "dc01_public_ip"
    location                     = azurerm_resource_group.dc902_rg.location
    resource_group_name          = azurerm_resource_group.dc902_rg.name
    allocation_method            = "Dynamic"
    tags = azurerm_resource_group.dc902_rg.tags
}

# Create a network security group. This allows the flow of network traffic in and out of the VM.
resource "azurerm_network_security_group" "dc902_nsg" {
    name                = "dc902_nsg"
    location            = azurerm_resource_group.dc902_rg.location
    resource_group_name = azurerm_resource_group.dc902_rg.name
    
    security_rule {
        name                       = "all_tcp_from_home"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.WHITELISTED_CIDR
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "all_udp_from_home"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Udp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.WHITELISTED_CIDR
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "all_icmp_from_home"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.WHITELISTED_CIDR
        destination_address_prefix = "*"
    }

    tags = azurerm_resource_group.dc902_rg.tags
}

# Create a virtual network interface card. Thsi connects your VM to a given virtual network, public IP address, and network security group.
resource "azurerm_network_interface" "dc01_nic" {
    name                        = "dc01_nic"
    location                    = azurerm_resource_group.dc902_rg.location
    resource_group_name         = azurerm_resource_group.dc902_rg.name

    ip_configuration {
        name                          = "dc01_nic_configuration"
        subnet_id                     = azurerm_subnet.dc902_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.dc01_public_ip.id
    }

    tags = azurerm_resource_group.dc902_rg.tags
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.dc01_nic.id
    network_security_group_id = azurerm_network_security_group.dc902_nsg.id
}

resource "random_id" "dc902_storage_account_random_id" {
    byte_length = 8
}

resource "azurerm_storage_account" "dc902_storage_account" {
    name                        = "diag${random_id.dc902_storage_account_random_id.hex}"
    resource_group_name         = azurerm_resource_group.dc902_rg.name
    location                    = azurerm_resource_group.dc902_rg.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = azurerm_resource_group.dc902_rg.tags
}

# Create a virtual machine.
resource "azurerm_windows_virtual_machine" "dc01_vm" {
    name                  = var.DC01_COMPUTER_NAME
    location              = azurerm_resource_group.dc902_rg.location
    resource_group_name   = azurerm_resource_group.dc902_rg.name
    size                  = var.DC01_VM_SIZE
    admin_username        = var.DC01_ADMIN_USERNAME
    admin_password        = var.DC01_ADMIN_PASSWORD
    network_interface_ids = [azurerm_network_interface.dc01_nic.id]

    os_disk {
        caching                 = "ReadWrite"
        storage_account_type    = "Standard_LRS"
    }

#    source_image_reference {
#        publisher = "MicrosoftWindowsServer"
#        offer     = "WindowsServer"
#        sku       = "2019-Datacenter"
#        version   = "latest"
#    }

    # Lookup images with: az vm image list --output table
    source_image_id = data.azurerm_image.dc01_image.id

    tags = azurerm_resource_group.dc902_rg.tags
}

# Packer related configuration
data "azurerm_image" "dc01_image" {
    name                = var.DC01_MANAGED_IMAGE_NAME
    resource_group_name = var.AZURE_PACKER_RESOURCE_GROUP
}