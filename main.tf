# RESOURCE GROUP
resource "azurerm_resource_group" "sky_rg" {
  for_each = var.resource_group
  name     = each.value.name
  location = each.value.location
}

# STORAGE ACCOUNT
#rg ke andar storage account banta h iska flow =rg-storage account
resource "azurerm_storage_account" "sky_sa" {
  for_each                 = var.storage_account
  name                     = each.value.name
  resource_group_name      = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location                 = azurerm_resource_group.sky_rg[each.value.resource_group].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# VIRTUAL NETWORK
#rg ke andar vnet banta h iska flow =rg-vnet
resource "azurerm_virtual_network" "sky_vnet" {
  for_each            = var.virtual_network
  name                = each.value.name
  resource_group_name = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location            = azurerm_resource_group.sky_rg[each.value.resource_group].location
  address_space       = each.value.address_space

}

# SUBNET 
#Subnet hamesha VNET ke andar banti hai.=rg - vnet - subnet
resource "azurerm_subnet" "sky_subnet" {
  for_each             = var.subnet
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.sky_rg[each.value.resource_group].name
  virtual_network_name = azurerm_virtual_network.sky_vnet[each.value.virtual_network].name
  address_prefixes     = each.value.address_prefixes

}

# NETWORK SECURITY GROUP
#NSG Kyu Chahiye?,NSG = Firewall
#Control karta hai:Kaunsa Port Open Hoga,Kaunsa Traffic Allow Hoga,Kaunsa Block Hoga
#Example:SSH = Port 22,HTTP = Port 80,HTTPS = Port 443

resource "azurerm_network_security_group" "sky_nsg" {
  for_each            = var.network_security_group
  name                = each.value.name
  resource_group_name = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location            = azurerm_resource_group.sky_rg[each.value.resource_group].location

  security_rule {
    name      = "AllowSSH"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "22"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG ASSOCIATION
#NSG ko Subnet ya NIC ke sath associate karna hota hai,iska flow =rg - vnet - subnet - nsg association
#Subnet + NSG Connection

resource "azurerm_subnet_network_security_group_association" "sky_subnet_nsg_assoc" {
  for_each                  = var.subnet_nsg_association
  subnet_id                 = azurerm_subnet.sky_subnet[each.value.subnet].id
  network_security_group_id = azurerm_network_security_group.sky_nsg[each.value.network_security_group].id
}

# PUBLIC IP
#Agar internet se VM access karni hai to public IP chaiye.
#Example:SSH,RDP,Web Server,Jenkins,Nginx

resource "azurerm_public_ip" "sky_public_ip" {
  for_each            = var.public_ip
  name                = each.value.name
  resource_group_name = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location            = azurerm_resource_group.sky_rg[each.value.resource_group].location
  allocation_method   =  each.value.allocation_method
  sku                 = "Standard"
}

# NIC
#NIC Kya Hai?NIC = Network Interface Card
#VM directly subnet me connect nahi hoti.Pehle NIC banti hai.
#Diagram:VM-NIC-Subnet-VNET

resource "azurerm_network_interface" "sky_nic" {
  for_each            = var.network_interface
  name                = each.value.name
  resource_group_name = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location            = azurerm_resource_group.sky_rg[each.value.resource_group].location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sky_subnet[each.value.subnet].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sky_public_ip[each.value.public_ip].id

  }
}

# LINUX VM
resource "azurerm_linux_virtual_machine" "sky_linux_vm" {
  for_each                        = var.linux_vm
  name                            = each.value.name
  resource_group_name             = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location                        = azurerm_resource_group.sky_rg[each.value.resource_group].location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  network_interface_ids           = [azurerm_network_interface.sky_nic[each.value.network_interface].id]
  disable_password_authentication = false
  source_image_reference {

    publisher = "Canonical"

    offer = "0001-com-ubuntu-server-jammy"

    sku = "22_04-lts"

    version = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#Managed Disk Resource
#Agar tum 3 VMs bana rahe ho using for_each, to Managed Disk bhi for_each se create karna chahiye.
#Ye code VM resource ke baad add kar sakte ho.
resource "azurerm_managed_disk" "sky_managed_disk" {
  for_each             = var.managed_disk
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.sky_rg[each.value.resource_group].name
  location             = azurerm_resource_group.sky_rg[each.value.resource_group].location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
}

#Disk Attachment Resource
#Managed Disk banane ke baad usko VM se attach karna padta hai.
resource "azurerm_virtual_machine_data_disk_attachment" "attach" {

  for_each = azurerm_managed_disk.sky_managed_disk

  managed_disk_id = azurerm_managed_disk.sky_managed_disk[each.key].id

  virtual_machine_id = azurerm_linux_virtual_machine.sky_linux_vm[each.key].id

  lun = 10

  caching = "ReadWrite"

}

# # LOAD BALANCER PUBLIC IP
# #Agar tumhare paas 3 VMs hain aur unke aage Azure Load Balancer lagana hai, to architecture aisa hoga:

# #Internet
#  #   │
# #Public Load Balancer
#    # │
# #Backend Pool
#  #┌──┴──┐
# #VM1   VM2   VM3

# #1. Public Load Balancer IP
# #########################################
# # LOAD BALANCER PUBLIC IP
# #########################################

# resource "azurerm_public_ip" "lb_pip" {

#   name                = "lb-public-ip"

#   location            = azurerm_resource_group.rg["rg1"].location

#   resource_group_name = azurerm_resource_group.rg["rg1"].name

#   allocation_method   = "Static"

#   sku                 = "Standard"
# }
# #2. Azure Load Balancer
# #########################################
# # LOAD BALANCER
# #########################################

# resource "azurerm_lb" "lb" {

#   name                = "enterprise-lb"

#   location            = azurerm_resource_group.rg["rg1"].location

#   resource_group_name = azurerm_resource_group.rg["rg1"].name

#   sku = "Standard"

#   frontend_ip_configuration {

#     name = "frontend-ip"

#     public_ip_address_id = azurerm_public_ip.lb_pip.id
#   }
# }
# #3. Backend Pool
# #########################################
# # BACKEND POOL
# #########################################

# resource "azurerm_lb_backend_address_pool" "backend" {

#   loadbalancer_id = azurerm_lb.lb.id

#   name = "backend-pool"
# }

# # NIC TO BACKEND POOL
# ##4. NIC Attach to Backend Pool

# ##Har VM ka NIC backend pool me register hoga.

# #########################################
# # NIC TO BACKEND POOL
# #########################################

# resource "azurerm_network_interface_backend_address_pool_association" "backend_association" {

#   for_each = var.virtual_machines

#   network_interface_id = azurerm_network_interface.nic[each.key].id

#   ip_configuration_name = "internal"

#   backend_address_pool_id =
#   azurerm_lb_backend_address_pool.backend.id
# }
# #5. Health Probe

# #Load Balancer check karega VM healthy hai ya nahi.

# #########################################
# # HEALTH PROBE
# #########################################

# resource "azurerm_lb_probe" "probe" {

#   loadbalancer_id = azurerm_lb.lb.id

#   name = "http-probe"

#   port = 80

#   protocol = "Http"

#   request_path = "/"
# }
# ##
# ##6. Load Balancer Rule

# ##Traffic distribute karega.

# #########################################
# # LOAD BALANCER RULE
# #########################################

# resource "azurerm_lb_rule" "http_rule" {

#   loadbalancer_id = azurerm_lb.lb.id

#   name = "http-rule"

#   protocol = "Tcp"

#   frontend_port = 80

#   backend_port = 80

#   frontend_ip_configuration_name = "frontend-ip"

#   backend_address_pool_ids = [
#     azurerm_lb_backend_address_pool.backend.id
#   ]

#   probe_id = azurerm_lb_probe.probe.id
# }

# #########################################
# # AVAILABILITY SET
# #########################################

# resource "azurerm_availability_set" "avset" {

#   name                = "enterprise-avset"

#   location            = azurerm_resource_group.rg["rg1"].location

#   resource_group_name = azurerm_resource_group.rg["rg1"].name

#   managed = true

#   platform_fault_domain_count  = 2

#   platform_update_domain_count = 5
# }

# #Availability Zone
# #Agar tumhare paas 3 VMs hain aur unko Availability Zone me distribute karna hai, to architecture aisa hoga:

# resource "azurerm_linux_virtual_machine" "vm" {

#   for_each = var.virtual_machines

#   ...

#   zone = each.value.zone

# }

# #########################################
# # RECOVERY VAULT
# #########################################

# resource "azurerm_recovery_services_vault" "vault" {

#   name = "enterprise-rsv"

#   location = azurerm_resource_group.rg["rg1"].location

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   sku = "Standard"

#   soft_delete_enabled = true
# }

# #########################################
# # BACKUP POLICY
# #########################################

# resource "azurerm_backup_policy_vm" "policy" {

#   name = "daily-backup"

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   recovery_vault_name =
#   azurerm_recovery_services_vault.vault.name

#   backup {

#     frequency = "Daily"

#     time = "23:00"
#   }

#   retention_daily {

#     count = 30
#   }
# }

# #########################################
# # VM BACKUP
# #########################################

# resource "azurerm_backup_protected_vm" "backup" {

#   for_each = var.virtual_machines

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   recovery_vault_name =
#   azurerm_recovery_services_vault.vault.name

#   source_vm_id =
#   azurerm_linux_virtual_machine.vm[each.key].id

#   backup_policy_id =
#   azurerm_backup_policy_vm.policy.id
# }

# #########################################
# # LOG ANALYTICS
# #########################################

# resource "azurerm_log_analytics_workspace" "law" {

#   name = "enterprise-law"

#   location =
#   azurerm_resource_group.rg["rg1"].location

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   sku = "PerGB2018"

#   retention_in_days = 30
# }

# #########################################
# # ACTION GROUP
# #########################################

# resource "azurerm_monitor_action_group" "action" {

#   name = "critical-alert"

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   short_name = "alert"

#   email_receiver {

#     name = "admin"

#     email_address = "admin@company.com"
#   }
# }

# #########################################
# # CPU ALERT
# #########################################

# resource "azurerm_monitor_metric_alert" "cpu_alert" {

#   name = "cpu-high"

#   resource_group_name =
#   azurerm_resource_group.rg["rg1"].name

#   scopes = [
#     azurerm_linux_virtual_machine.vm["vm1"].id
#   ]

#   description = "CPU High"

#   severity = 2

#   frequency = "PT5M"

#   window_size = "PT5M"

#   criteria {

#     metric_namespace = "Microsoft.Compute/virtualMachines"

#     metric_name = "Percentage CPU"

#     aggregation = "Average"

#     operator = "GreaterThan"

#     threshold = 80
#   }

#   action {

#     action_group_id =
#     azurerm_monitor_action_group.action.id
#   }
# }