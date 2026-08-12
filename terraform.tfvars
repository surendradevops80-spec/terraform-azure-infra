#########################################
# RESOURCE GROUP
#########################################

resource_group = {
  rg1 = {
    name     = "rg-dev"
    location = "Central India"
  }

  rg2 = {
    name     = "rg-prod"
    location = "East US"
  }
}

#########################################
# STORAGE ACCOUNT
#########################################

storage_account = {
  st1 = {
    name           = "sky1storage321"
    resource_group = "rg1"
  }

  st2 = {
    name           = "sky2storageprod123"
    resource_group = "rg2"
  }
}

#########################################
# VIRTUAL NETWORK
#########################################

virtual_network = {
  vnet1 = {
    name           = "vnet-dev"
    resource_group = "rg1"
    address_space  = ["10.0.0.0/16"]
  }

  vnet2 = {
    name           = "vnet-prod"
    resource_group = "rg2"
    address_space  = ["10.1.0.0/16"]
  }
}

#########################################
# SUBNET
#########################################

subnet = {

  subnet1_dev = {
    name             = "subnet1-dev"
    resource_group   = "rg1"
    virtual_network  = "vnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet2_dev = {
    name             = "subnet2-dev"
    resource_group   = "rg1"
    virtual_network  = "vnet1"
    address_prefixes = ["10.0.2.0/24"]
  }

  subnet1_prod = {
    name             = "subnet1-prod"
    resource_group   = "rg2"
    virtual_network  = "vnet2"
    address_prefixes = ["10.1.1.0/24"]
  }

  subnet2_prod = {
    name             = "subnet2-prod"
    resource_group   = "rg2"
    virtual_network  = "vnet2"
    address_prefixes = ["10.1.2.0/24"]
  }
}

#########################################
# NETWORK SECURITY GROUP
#########################################

network_security_group = {

  nsg1 = {
    name           = "nsg-dev"
    resource_group = "rg1"
  }

  nsg2 = {
    name           = "nsg-prod"
    resource_group = "rg2"
  }
}

#########################################
# NSG ASSOCIATION
#########################################

subnet_nsg_association = {

  assoc1 = {
    subnet                 = "subnet1_dev"
    network_security_group = "nsg1"
  }

  assoc2 = {
    subnet                 = "subnet1_prod"
    network_security_group = "nsg2"
  }
}

#########################################
# PUBLIC IP
#########################################

public_ip = {

  pip1 = {
    name               = "pip-dev"
    resource_group     = "rg1"
    allocation_method  = "Static"
  }

  pip2 = {
    name               = "pip-prod"
    resource_group     = "rg2"
    allocation_method  = "Static"
  }
}

#########################################
# NETWORK INTERFACE
#########################################

network_interface = {

  nic1 = {
    name           = "nic-dev"
    resource_group = "rg1"
    subnet         = "subnet1_dev"
    public_ip      = "pip1"
  }

  nic2 = {
    name           = "nic-prod"
    resource_group = "rg2"
    subnet         = "subnet1_prod"
    public_ip      = "pip2"
  }
}

#########################################
# LINUX VM
#########################################

linux_vm = {

  vm1 = {
    name              = "vm-dev"
    resource_group    = "rg1"
    size              = "Standard_B1s"
    admin_username    = "azureuser"
    admin_password    = "Password@1234!"
    network_interface = "nic1"
  }

  vm2 = {
    name              = "vm-prod"
    resource_group    = "rg2"
    size              = "Standard_B1s"
    admin_username    = "azureuser"
    admin_password    = "Password@1234!"
    network_interface = "nic2"
  }
}

#########################################
# MANAGED DISK
#########################################

managed_disk = {

  vm1 = {
    name           = "disk-dev"
    resource_group = "rg1"
    disk_size_gb   = 30
  }

  vm2 = {
    name           = "disk-prod"
    resource_group = "rg2"
    disk_size_gb   = 30
  }
}