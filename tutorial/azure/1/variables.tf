variable "rg_name" {
    type = string
    description = "Name of the main resource group"
    default = "HelloTerraform_RG"
}

variable "location" {
    type = string
    description = "Location (region) of resources"
    default = "polandcentral"
  
}

variable "vnet_address_space" {
    type = string
    description = "Address space for VNET"
    default = "10.1.0.0/16"
  
}

variable "vm_name" {
    type = string
    description = "Name of the virtusal machine"
    default = "dev01vm"
  
}

variable "subnets_names" {
    type = list(string)
    description = "Names of subnets"
    default = [ "dev_subnet", "tst_subnet" ]
  
}

variable "subnet_addresses" {
    type = list(string)
    description = "Adresses of subnets"
    default = [ "10.1.1.0/24", "10.1.2.0/24" ]
  
}

variable "tags" {
    type = map(string)
    description = "Tags for resources"
    default = {
      "environment" = "DEV"
      "project" = "NewDevHome"
      "team" = "Software House"
    }
}

variable "subnets" {
    type = map(any)
    description = "Subnets information"
    default = {
      uat_subnet = {
        address = ["10.1.3.0/24"]
      },
      prd_subnet = {
        address = ["10.1.4.0/24"]
      }
    }
  
}