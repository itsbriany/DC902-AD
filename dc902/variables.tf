# Shared environment variables
variable AZURE_RESOURCE_GROUP {
    type = string
    description = "The azure resource group for this deployment."
}

variable AZURE_PACKER_RESOURCE_GROUP {
    type = string
    description = "The azure resource group where we use images built by packer for this deployment."
}

variable AZURE_REGION {
    type = string
    description = "The azure region for this deployment."
}

# Firewall related variables
variable WHITELISTED_CIDR {
    type = string
    description = "The CIDR range that is allowed to communicate with the network."
}

# DC01 related variables
variable DC01_VM_SIZE {
    type = string
    description = "The VM size for the DC01 image. Bigger = better; Bigger = more $$$"
    default = "Standard_DS1_v2"
}

variable DC01_MANAGED_IMAGE_NAME {
    type = string
    description = "The azure DC01 image which should be built by packer."
}

variable DC01_COMPUTER_NAME {
    type = string
    description = "The DC01 computer name."
    default = "DC01"
}

variable DC01_ADMIN_USERNAME {
    type = string
    description = "The DC01 administrator's user name."
}

variable DC01_ADMIN_PASSWORD {
    type = string
    description = "The DC01 administrator's password."
}