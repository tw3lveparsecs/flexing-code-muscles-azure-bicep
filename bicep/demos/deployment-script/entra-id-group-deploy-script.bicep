@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Name of the Azure AD group to create.')
param groupName string

@description('Optional. User principal name(s) of users to add to Azure AD group.')
param userPrincipalNames array = []

@description('Service principal client id.')
@secure()
param servicePrincipalClientId string

@description('Service principal password.')
@secure()
param servicePrincipalPassword string

@description('Optional. Tenant ID.')
param tenantId string = tenant().tenantId

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.5'
    scriptContent: '''
    param(
      [string] $groupName,
      [array] $userPrincipalNames,
      [string] $servicePrincipalClientId,
      [string] $tenant
      )
      [securestring]$secStringPassword = ConvertTo-SecureString ${Env:servicePrincipalPassword} -AsPlainText -Force
      [pscredential]$creds = New-Object System.Management.Automation.PSCredential ($servicePrincipalClientId, $secStringPassword)
      Connect-AzAccount -Credential $creds -ServicePrincipal -tenant $tenant
      $group = Get-AzADGroup -DisplayName $groupName
      if ($group -eq $null -or $group -eq "" ) {
        $group = New-AzADGroup -DisplayName $groupName -MailNickname $groupName
      }
      $members=@()
      foreach ($upn in $userPrincipalNames){
        $upnformatted = $upn.replace('[',"").replace(']',"")
        $members+=(Get-AzADUser -UserPrincipalName $upnformatted).Id
      }
      Add-AzADGroupMember -TargetGroupObjectId $group.id -MemberObjectId $members
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs["groupId"] = $group.id
    '''
    arguments: '-groupName ${groupName} -userPrincipalNames ${userPrincipalNames} -servicePrincipalClientId ${servicePrincipalClientId} -tenant ${tenantId}'
    environmentVariables: [
      {
        name: 'servicePrincipalPassword'
        secureValue: servicePrincipalPassword
      }
    ]
    timeout: 'PT15M'
    retentionInterval: 'PT1H'
    cleanupPreference: 'Always'
  }
}

output groupId string = deploymentScript.properties.outputs.groupId
