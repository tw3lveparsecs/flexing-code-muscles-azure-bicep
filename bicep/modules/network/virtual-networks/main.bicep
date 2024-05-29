@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('The address space that contains an array of IP address ranges that can be used by subnets.')
param addressPrefixes array

@description('Optional. DNS servers associated to the virtual network. Leave blank if using Azure DNS.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep#dhcpoptions'
  example: [
    '10.0.6.4'
    '10.0.6.5'
    '10.1.2.3'
  ]
})
param dnsServers array = []

@description('A list of subnets associated to the virtual network.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep#subnet'
  example: [
    {
      name: 'Subnet name.'
      addressPrefix: 'The address prefix for the subnet.'
      networkSecurityGroupId: 'The resource ID of the network security group.'
      routeTableId: 'The resource ID of the route table.'
      natGatewayId: 'The resource ID of the Nat gateway.'
      privateEndpointNetworkPolicies: 'Enable or disable apply network policies on private end point in the subnet.'
      privateLinkServiceNetworkPolicies: 'Enable or Disable apply network policies on private link service in the subnet.'
      delegation: 'The name of the service to whom the subnet should be delegated (e.g. Microsoft.Web/serverFarms).'
      serviceEndpoints: [
        {
          service: 'The type of the endpoint service (e.g. Microsoft.Web).'
        }
      ]
    }
  ]
})
param subnets array

@description('Optional. The resource ID of the DDoS protection plan associated with the virtual network.')
param ddosProtectionPlanId string = ''

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${virtualNetwork.name}-${resourceLock}-lck')

var diagnosticsName = toLower('${virtualNetwork.name}-dgs')

var diagnosticsLogs = [
  for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
    categoryGroup: categoryGroup
    enabled: true
  }
]

var diagnosticsMetrics = [
  for metric in diagnosticMetricsToEnable: {
    category: metric
    timeGrain: null
    enabled: true
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    enableDdosProtection: !empty(ddosProtectionPlanId) ? true : null
    ddosProtectionPlan: !empty(ddosProtectionPlanId)
      ? {
          id: ddosProtectionPlanId
        }
      : null
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          natGateway: contains(subnet, 'natGatewayId') && subnet.natGatewayId != null
            ? {
                id: subnet.natGatewayId
              }
            : null
          networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') && subnet.networkSecurityGroupId != null
            ? {
                id: subnet.networkSecurityGroupId
              }
            : null
          routeTable: contains(subnet, 'routeTableId') && subnet.routeTableId != null
            ? {
                id: subnet.routeTableId
              }
            : null
          privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies')
            ? subnet.privateEndpointNetworkPolicies
            : 'Disabled'
          privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies')
            ? subnet.privateLinkServiceNetworkPolicies
            : 'Enabled'
          serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
          delegations: contains(subnet, 'delegation') && subnet.delegation != null
            ? [
                {
                  name: subnet.delegation
                  properties: {
                    serviceName: subnet.delegation
                  }
                }
              ]
            : []
        }
      }
    ]
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualNetwork
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}
// demonstrates the bicep linter and when to use #disable-next-line when a false postive occurs
//#disable-next-line use-recent-api-versions
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: virtualNetwork
  name: diagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId)
      ? null
      : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

@description('The name of the deployed virtual network.')
output name string = virtualNetwork.name

@description('The resource ID of the deployed virtual network.')
output resourceId string = virtualNetwork.id

@description('List of subnets associated to the virtual network.')
output subnets array = [
  for (subnet, i) in subnets: {
    name: virtualNetwork.properties.subnets[i].name
    id: virtualNetwork.properties.subnets[i].id
  }
]
