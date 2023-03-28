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

resource "azurerm_key_vault_secret" "AZURE_APPINSIGHTS_KEY" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-appinsights-${var.env}"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance..
      application_type,
    ]
  }
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.product}-${var.env}" # update these values if required
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

resource "azurerm_key_vault_secret" "redis_access_key" {
  name         = "redis-access-key"
  value        = module.fis-ds-update-web-session-storage.access_key
  key_vault_id = data.azurerm_key_vault.key_vault.id
}