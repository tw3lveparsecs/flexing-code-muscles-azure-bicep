@description('Group name.')
param groupName string

@description('Optional. Resource location.')
param location string = resourceGroup().location

@description('Optional. User principal names to assign to the group.')
param userPrincipalNames array = []

@description('Name of the key vault containing credentials for service principal.')
param keyVaultName string

@description('Secret name containing service principal client ID.')
param keyVaultClientIdSecretName string

@description('Secret name containing service principal password.')
param keyVaultPasswordSecretName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

module deployScriptDemo 'entra-id-group-deploy-script.bicep' = {
  name: 'deploy-script-demo-${uniqueString(deployment().name, location)}'
  params: {
    name: 'entra-id-goup-script'
    groupName: groupName
    location: location
    servicePrincipalClientId: keyVault.getSecret(keyVaultClientIdSecretName)
    servicePrincipalPassword: keyVault.getSecret(keyVaultPasswordSecretName)
    userPrincipalNames: userPrincipalNames
  }
}
