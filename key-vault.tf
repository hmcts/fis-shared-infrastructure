module "fis-kv-vault" {
  source                     = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                       = "${var.product}-kv-${var.env}"
  product                    = var.product
  env                        = var.env
  tenant_id                  = var.tenant_id
  object_id                  = var.jenkins_AAD_objectId
  resource_group_name        = azurerm_resource_group.rg.name
  product_group_name         = "DTS Family Integration"
  common_tags                = var.common_tags
  create_managed_identity    = true
  // managed_identity_object_id = var.managed_identity_object_id
}

output "vaultName" {
  value = module.fis-kv-vault.key_vault_name
}