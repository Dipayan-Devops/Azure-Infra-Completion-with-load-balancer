module "Azurerm_RG" {
  source   = "../Child Module/Azurerm_RG"
  rg_name  = "insider-rg"
  location = "east us"
}

module "Azurerm_Key_vault" {
  source     = "../Child Module/Azurerm_Key vault"
  depends_on = [module.Azurerm_RG]
  kv_name    = "Insider-Key-vault"
  location   = "east us"
  rg_name    = "insider-rg"
}

module "Azurerm_Vnet" {
  source        = "../Child Module/Azurerm_Vnet"
  depends_on    = [module.Azurerm_RG]
  vnet_name     = "insider-vnet"
  location      = "east us"
  rg_name       = "insider-rg"
  address_space = ["10.0.0.0/16"]
}

module "Azurerm_Subnet" {
  source           = "../Child Module/Azurerm_Subnet"
  depends_on       = [module.Azurerm_RG, module.Azurerm_Vnet]
  subnet_name      = "insider-subnet"
  rg_name          = "insider-rg"
  vnet_name        = "insider-vnet"
  address_prefixes = ["10.0.1.0/24"]
}

module "Azurerm_Subnet-bastion" {
  source           = "../Child Module/Azurerm_Subnet"
  depends_on       = [module.Azurerm_RG, module.Azurerm_Vnet]
  subnet_name      = "AzureBastionSubnet"
  rg_name          = "insider-rg"
  vnet_name        = "Insider-vnet"
  address_prefixes = ["10.0.3.0/26"]
}

module "Azurerm_PIP" {
  source            = "../Child Module/Azurerm_PIP"
  depends_on        = [module.Azurerm_RG]
  pip_name          = "insider-pip"
  rg_name           = "insider-rg"
  location          = "east us"
  allocation_method = "Static"
}

module "Azurerm_PIP-bastion" {
  source            = "../Child Module/Azurerm_PIP"
  depends_on        = [module.Azurerm_RG]
  pip_name          = "insider-pip-bastion"
  rg_name           = "insider-rg"
  location          = "east us"
  allocation_method = "Static"
}

module "Azurerm_Bastion" {
  source          = "../Child Module/Azurerm_Bastion"
  depends_on      = [module.Azurerm_Subnet-bastion, module.Azurerm_PIP-bastion]
  pip_name        = "insider-pip-bastion"
  rg_name         = "insider-rg"
  subnet_name     = "AzureBastionSubnet"
  vnet_name       = "insider-vnet"
  bastion_name    = "insider-bastion"
  location        = "east us"
  bastion_ip_name = "insider-bastion-pip"
}

module "Azurerm_VM" {
  source         = "../Child Module/Azurerm_VM"
  depends_on     = [module.Azurerm_Subnet]
  subnet_name    = "insider-subnet"
  vnet_name      = "insider-vnet"
  rg_name        = "insider-rg"
  nic_name       = "insider-nic"
  location       = "east us"
  nsg_name       = "insider-nsg"
  vm_name        = "insider-vm"
  admin_username = "devopsinsider"
  admin_password = "Devops@12345"
}

module "Azurerm_VM-1" {
  source         = "../Child Module/Azurerm_VM"
  depends_on     = [module.Azurerm_Subnet]
  subnet_name    = "insider-subnet"
  vnet_name      = "insider-vnet"
  rg_name        = "insider-rg"
  nic_name       = "insider-nic-1"
  location       = "east us"
  nsg_name       = "insider-nsg-1"
  vm_name        = "insider-vm-1"
  admin_username = "devopsinsider"
  admin_password = "Devops@12345"
}

module "Azurerm_Load_Balancer" {
  source            = "../Child Module/Azurerm_Load_Balancer"
  depends_on        = [module.Azurerm_RG, module.Azurerm_VM, module.Azurerm_VM-1, module.Azurerm_PIP, module.Azurerm_Subnet]
  pip_name          = "insider-pip"
  rg_name           = "insider-rg"
  lb_name           = "insider-lb"
  location          = "east us"
  backend_pool_name = "insider-backend-pool"
  probe_name        = "insider-probe"
  lb_rule_name      = "insider-lb-rule"
}

module "Azurerm_NIC-BAP_connection" {
  source         = "../Child Module/Azurerm_NIC-BAP_connection"
  depends_on     = [module.Azurerm_Load_Balancer, module.Azurerm_VM]
  nic_name       = "insider-nic"
  rg_name        = "insider-rg"
  lb_name        = "insider-lb"
  bap_name       = "insider-backend-pool"
  ip_config_name = "internal"
}

module "Azurerm_NIC-BAP_connection-1" {
  source         = "../Child Module/Azurerm_NIC-BAP_connection"
  depends_on     = [module.Azurerm_Load_Balancer, module.Azurerm_VM-1]
  nic_name       = "insider-nic-1"
  rg_name        = "insider-rg"
  lb_name        = "insider-lb"
  bap_name       = "insider-backend-pool"
  ip_config_name = "internal"
}