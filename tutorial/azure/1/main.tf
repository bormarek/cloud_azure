terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tutorial_resource" {
  name     = "tutorial_resource"
  location = "polandcentral"
  tags = var.tags
}

resource "azurerm_virtual_network" "tutorial_vnet" {
  name = "Tutorial_VNET"
  location = azurerm_resource_group.tutorial_resource.location
  resource_group_name = azurerm_resource_group.tutorial_resource.name
  address_space = ["10.1.0.0/16"]
  
  subnet {
    name = "dev_subnet"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name = "tst_subnet"
    address_prefix = "10.1.2.0/24"
  }

}

resource "azurerm_subnet" "main_vnet_subnets" {
  for_each = var.subnets
  resource_group_name = azurerm_resource_group.tutorial_resource.name
  virtual_network_name = azurerm_virtual_network.tutorial_vnet.name
  name = each.key
  address_prefixes = each.value["address"]
}

resource "azurerm_public_ip" "dev01vm_pub_ip" {
  name = "dev01vm_ip"
  resource_group_name = azurerm_resource_group.tutorial_resource.name
  location = azurerm_resource_group.tutorial_resource.location
  allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "dev01vm_nic" {
  name = "dev01vm-nic"
  location = azurerm_resource_group.tutorial_resource.location
  resource_group_name = azurerm_resource_group.tutorial_resource.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_virtual_network.tutorial_vnet.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.dev01vm_pub_ip.id
  }
}

resource "azurerm_network_security_group" "nsg_ssh" {
  name = "dev01vm-nsg"
  location = azurerm_resource_group.tutorial_resource.location
  resource_group_name = azurerm_resource_group.tutorial_resource.name

  security_rule {
    name = "SSH"
    priority = 300
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name = "HTTP"
    priority = 310
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id = azurerm_network_interface.dev01vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_ssh.id
}

resource "azurerm_linux_virtual_machine" "dev01vm" {
  name = "dev01vm"
  resource_group_name = azurerm_resource_group.tutorial_resource.name
  location = azurerm_resource_group.tutorial_resource.location
  size = "Standard_B2s"

  network_interface_ids = [
    azurerm_network_interface.dev01vm_nic.id
  ]

  admin_username = "azureuser"
  admin_ssh_key {
    username = "azureuser"
    public_key = file("/Users/marek/.ssh/id_rsa.pub")
    }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

    custom_data = base64encode(<<EOF
#!/bin/bash
sudo apt update && sudo apt install -y nginx
EOF
  )
}
output "public_ip_address" {
  value = azurerm_public_ip.dev01vm_pub_ip.ip_address
  description = "The public IP address of the virtual machine."
}
