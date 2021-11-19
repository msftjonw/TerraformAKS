terraform {
  
  required_providers {
    azurerm = "2.52.0"
  }
  
  backend "azurerm" {
    resource_group_name  = "RG-Terraform"
    storage_account_name = "jonwterraformstorage"
    container_name       = "terraformstate"
    key                  = $(mySecret)
  }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-AzureDevOps2"
  location = "West US 2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "VNet-AzureDevOps2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "Subnet-AzureDevOps2"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "AKS-AzureDevOps2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dns-azuredevops2"

  default_node_pool {
    name                = "systempool"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2"]
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 4

    # Required for advanced networking
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "azuredevops2"
  }
}
