using './create-entra-id-group.bicep'

param groupName = 'flexdemo-entra-id-group'
param keyVaultName = 'lab-flexdemo-kv'
param keyVaultClientIdSecretName = 'flex-demo-svcp-client-id'
param keyVaultPasswordSecretName = 'flex-demo-svcp-password'
param userPrincipalNames = [
  'r2d2@arincoauajbajada.onmicrosoft.com'
]
