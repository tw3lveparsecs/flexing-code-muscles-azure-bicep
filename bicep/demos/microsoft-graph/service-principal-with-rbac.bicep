provider microsoftGraph

@description('Azure resource location.')
param location string = resourceGroup().location

@description('Display name of the Entra ID application.')
param appDisplayName string

@description('Unique name of the Entra ID application.')
param appUniqueName string

@description('The name of the federated identity credential.')
param fedCredName string

@description('The issuer of the federated identity credential. This is the URL of the token issuer that the federated identity credentials are issued by. This is typically the URL of the GitHub token issuer.')
param fedCredIssuer string

@description('The subject of the federated identity credentials. This is the identifier of the resource that the federated identity credentials are for. This is typically a resource identifier in the format of `repo:<owner>/<repo>:environment:<environment>`.')
@metadata({
  doc: 'https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims'
})
param fedCredSubject string

@description('The name of the Entra ID group.')
param groupName string

var roleDefintionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
var audiences = ['api://AzureADTokenExchange']
var sleepSeconds = 20

resource resourceApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: appUniqueName
  displayName: appDisplayName
}

resource githubFedCred 'Microsoft.Graph/applications/federatedIdentityCredentials@v1.0' = {
  name: '${appUniqueName}/${fedCredName}'
  issuer: fedCredIssuer
  subject: fedCredSubject
  audiences: audiences
}

resource resourceSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: resourceApp.appId
}

resource entraGroup 'Microsoft.Graph/groups@v1.0' = {
  displayName: groupName
  uniqueName: groupName
  mailEnabled: false
  mailNickname: groupName
  securityEnabled: true
  members: [
    resourceSp.id
  ]
}
// add a delay to ensure the group is created before the role assignment
resource sleepDelay 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'sleepDelay'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.5'
    scriptContent: '''
    param ( [string] $seconds )
    Write-Output Sleeping for: $seconds ....
    Start-Sleep -Seconds $seconds
    Write-Output Sleep over - resuming ....
    '''
    arguments: '-seconds ${sleepSeconds}'
    timeout: 'PT15M'
    retentionInterval: 'PT1H'
    cleanupPreference: 'Always'
  }
}

resource rbacAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  dependsOn: [sleepDelay]
  name: guid(roleDefintionId, groupName)
  properties: {
    principalId: entraGroup.id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefintionId)
    principalType: 'Group'
  }
}

output appClientId string = resourceApp.appId
