module "fis-kv-vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=DTSPO-31965/remove-jenkins-ptl-access"
  name                    = "${var.product}-kv-${var.env}"
  product                 = var.product
  env                     = var.env
  tenant_id               = var.tenant_id
  object_id               = var.jenkins_AAD_objectId
  jenkins_object_id       = data.azurerm_user_assigned_identity.jenkins.principal_id
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "DTS Family Integration"
  common_tags             = var.common_tags
  create_managed_identity = true
  // managed_identity_object_id = var.managed_identity_object_id
  additional_managed_identities_access = var.additional_managed_identities_access
}

data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

output "vaultName" {
  value = module.fis-kv-vault.key_vault_name
}
