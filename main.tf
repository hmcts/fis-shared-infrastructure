resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location

  tags = var.common_tags
}

module "key-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product             = var.product
  env                 = var.env
  tenant_id           = var.tenant_id
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name

  # dcd_platformengineering group object ID
  product_group_name = "DTS Family Integration"
  common_tags                = var.common_tags
  create_managed_identity    = true
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.product}-kv-${var.env}" # update these values if required
  resource_group_name = "${var.product}-${var.env}" # update these values if required
}

data "azurerm_subnet" "core_infra_redis_subnet" {
  name                 = "core-infra-subnet-1-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name = "core-infra-${var.env}"
}

module "fis-ds-update-web-session-storage" {
  source   = "git@github.com:hmcts/cnp-module-redis?ref=master"
  product  = "${var.product}-${var.citizen_component}-redis"
  location = var.location
  env      = var.env
  subnetid = data.azurerm_subnet.core_infra_redis_subnet.id
  common_tags  = var.common_tags
}