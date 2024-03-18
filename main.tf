# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "polandcentral"
}

# create a virtual network

resource "azurerm_virtual_network" "vnet" {
  name = "myNetwork"
  address_space = ["10.0.0.0/24"]
  location = "polandcentral"
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = "Terraform getting started"
    Team = "DevOps"
  }
}
