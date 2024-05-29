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

@description('Tier of an application gateway.')
@allowed([
  'Standard'
  'Standard_v2'
  'WAF'
  'WAF_v2'
])
param tier string

@description('Name of an application gateway SKU.')
@allowed([
  'Standard_Large'
  'Standard_Medium'
  'Standard_Small'
  'Standard_v2'
  'WAF_Large'
  'WAF_Medium'
  'WAF_v2'
])
param sku string

@description('Optional. Autoscale minimum capacity on application gateway resource.')
@minValue(1)
@maxValue(32)
param autoScaleMinCapacity int = 2

@description('Optional. Autoscale maximum capacity on application gateway resource.')
@minValue(1)
@maxValue(32)
param autoScaleMaxCapacity int = 10

@description('Optional. Whether HTTP2 is enabled on the application gateway resource.')
param http2Enabled bool = true

@description('Name of the application gateway public IP address.')
param publicIpAddressName string

@description('Resource ID of the application gateway subnet.')
param subnetResourceId string

@description('Optional. SSL certificates of the application gateway resource.')
@metadata({
  name: 'Name of the SSL certificate that is unique within an application gateway.'
  keyVaultResourceId: 'Resource ID of key vault resource containing (base-64 encoded unencrypted pfx) "Secret" or "Certificate" object.'
  secretName: 'Key vault secret name.'
})
param sslCertificates array = []

@description('Optional. SSL policy of the application gateway resource.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewaysslpolicy'
  example: {
    cipherSuites: [
      'string'
    ]
    disabledSslProtocols: [
      'string'
    ]
    minProtocolVersion: 'string'
    policyName: 'string'
    policyType: 'string'
  }
})
param sslPolicy object = {
  policyName: 'AppGwSslPolicy20170401S'
  policyType: 'Predefined'
}

@description('Optional. Trusted root certificates of the application gateway resource.')
@metadata({
  name: 'Name of the SSL certificate that is unique within an application gateway.'
  keyVaultResourceId: 'Resource ID of key vault resource containing (base-64 encoded unencrypted pfx) "Secret" or "Certificate" object.'
  secretName: 'Key vault secret name.'
})
param trustedRootCertificates array = []

@description('Http listeners of the application gateway resource.')
@metadata({
  name: 'Name of the HTTP listener that is unique within an application gateway.'
  protocol: 'Protocol of the HTTP listener.'
  frontEndPort: 'Frontend port name of an application gateway.'
  frontEndType: 'Frontend type of an application gateway. Value must be Public or Private. public is the default. '
  sslCertificate: 'SSL certificate name of an application gateway (only required for HTTPS listeners).'
  hostNames: [
    'List of host names for HTTP Listener that allows special wildcard characters as well.'
  ]
  firewallPolicyId: 'Resource ID of the firewall policy to use for this listener.'
})
param httpListeners array

@description('Optional. Backend address pool of the application gateway resource.')
@metadata({
  name: 'Name of the backend address pool that is unique within an application gateway.'
  backendAddresses: [
    {
      fqdn: 'Fully qualified domain name (FQDN).'
      ipAddress: 'IP address.'
    }
  ]
})
param backendAddressPools array = []

@description('Optional. Backend http settings of the application gateway resource.')
@metadata({
  name: 'Name of the backend http settings that is unique within an application gateway.'
  port: 'The destination port on the backend.'
  protocol: 'The protocol used to communicate with the backend.'
  cookieBasedAffinity: 'Cookie based affinity. Acceptable values are "Enabled" or "Disabled".'
  requestTimeout: 'Request timeout in seconds. application gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds.'
  connectionDraining: {
    drainTimeoutInSec: '	The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds.'
    enabled: 'Whether connection draining is enabled or not.'
  }
  trustedRootCertificate: 'Trusted root certificate name of an application gateway.'
  hostName: 'Host header to be sent to the backend servers.'
  probeName: 'Probe name of an application gateway.'
})
param backendHttpSettings array = []

@description('Request routing rules of the application gateway resource.')
@metadata({
  name: 'Name of the request routing rule that is unique within an application gateway.'
  ruleType: 'Rule type. Acceptable values are "Basic" or "PathBasedRouting".'
  httpListener: 'Http listener name of the application gateway.'
  backendAddressPool: 'Backend address pool name of the application gateway.'
  backendHttpSettings: 'Backend http settings name of the application gateway.'
  redirectConfiguration: 'Redirect configuration name of the application gateway.'
  priority: 'The rule priority.'
})
param requestRoutingRules array

@description('Optional. Redirect configurations of the application gateway resource.')
@metadata({
  name: 'Name of the redirect configuration that is unique within an application gateway.'
  redirectType: 'HTTP redirection type. Acceptable values are "Found", "Permanent", "SeeOther" or "Temporary".'
  targetUrl: 'Url to redirect the request to.'
  includePath: 'Include path in the redirected url. Acceptable values are "true" or "false".'
  includeQueryString: 'Include query string in the redirected url. Acceptable values are "true" or "false".'
  requestRoutingRule: 'Request routing rule name specifiying redirect configuration.'
})
param redirectConfigurations array = []

@description('Frontend ports of the application gateway resource.')
@metadata({
  name: 'Name of the frontend port that is unique within an application gateway.'
  port: 'Frontend port.'
})
param frontEndPorts array

@description('Optional. Frontend private IP address for application gateway resource. IP address must be based on the supplied subnet supported IP range.')
param frontEndPrivateIpAddress string = ''

@description('Optional. Probes of the application gateway resource.')
@metadata({
  name: 'Name of the probe that is unique within an application gateway.'
  protocol: 'The protocol used for the probe. Acceptable values are "Http", "Https", "Tcp" or "Tls".'
  host: 'Host name to send the probe to.'
  path: 'Relative path of probe. Valid path starts from /. Probe is sent to {Protocol}://{host}:{port}{path}.'
  interval: 'The probing interval in seconds. This is the time interval between two consecutive probes. Acceptable values are from 1 second to 86400 seconds.'
  timeout: 'The probe timeout in seconds. Probe marked as failed if valid response is not received with this timeout period. Acceptable values are from 1 second to 86400 seconds.'
  unhealthyThreshold: 'The probe retry count. Backend server is marked down after consecutive probe failure count reaches UnhealthyThreshold. Acceptable values are from 1 second to 20.'
  pickHostNameFromBackendHttpSettings: 'Whether the server name indication should be picked from the backend settings for Tls protocol. Default value is false. Acceptable values are "true" or "false".'
  minServers: 'Minimum number of servers that are always marked healthy. Default value is 0.'
  match: {
    body: 'Body that must be contained in the health response. Default value is empty.'
    statusCodes: [
      'Allowed ranges of healthy status codes. Default range of healthy status codes is 200-399.'
    ]
  }
})
param probes array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Resource ID of the firewall policy.')
param firewallPolicyId string = ''

@description('Optional. A list of availability zones denoting where the resource should be deployed.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

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

var lockName = toLower('${applicationGateway.name}-${resourceLock}-lck')

var publicIpDiagnosticsName = toLower('${publicIpAddress.name}-dgs')

var applicationGatewayDiagnosticsName = toLower('${applicationGateway.name}-dgs')

var identityType = systemAssignedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

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

var gatewayIpConfigurationName = 'appGatewayIpConfig'

var frontendPublicIpConfigurationName = 'appGwPublicFrontendIp'
var frontendPrivateIpConfigurationName = 'appGwPrivateFrontendIp'

var frontendPublicIpConfiguration = {
  name: frontendPublicIpConfigurationName
  properties: {
    publicIPAddress: {
      id: publicIpAddress.id
    }
  }
}

var frontendPrivateIpConfiguration = {
  name: frontendPrivateIpConfigurationName
  properties: {
    privateIPAddress: frontEndPrivateIpAddress
    privateIPAllocationMethod: 'Static'
    subnet: {
      id: subnetResourceId
    }
  }
}

var frontendIPConfigurations = empty(frontEndPrivateIpAddress)
  ? [frontendPublicIpConfiguration]
  : [frontendPublicIpConfiguration, frontendPrivateIpConfiguration]

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIpAddressName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: availabilityZones
}

#disable-next-line use-recent-api-versions
resource diagnosticsPublicIp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: publicIpAddress
  name: publicIpDiagnosticsName
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

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-11-01' = {
  name: name
  location: location
  zones: availabilityZones
  #disable-next-line BCP036
  identity: identity
  properties: {
    sku: {
      name: sku
      tier: tier
    }
    autoscaleConfiguration: {
      minCapacity: autoScaleMinCapacity
      maxCapacity: autoScaleMaxCapacity
    }
    enableHttp2: http2Enabled
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigurationName
        properties: {
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: [
      for frontEndPort in frontEndPorts: {
        name: frontEndPort.name
        properties: {
          port: frontEndPort.port
        }
      }
    ]
    probes: [
      for probe in probes: {
        name: probe.name
        properties: {
          protocol: probe.protocol
          host: contains(probe, 'host') ? probe.host : null
          path: probe.path
          interval: probe.interval
          timeout: probe.timeout
          unhealthyThreshold: probe.unhealthyThreshold
          pickHostNameFromBackendHttpSettings: probe.pickHostNameFromBackendHttpSettings
          minServers: contains(probe, 'minServers') ? probe.minServers : 0
          match: probe.match
        }
      }
    ]
    backendAddressPools: [
      for backendAddressPool in backendAddressPools: {
        name: backendAddressPool.name
        properties: {
          backendAddresses: backendAddressPool.backendAddresses
        }
      }
    ]
    firewallPolicy: !empty(firewallPolicyId)
      ? {
          id: firewallPolicyId
        }
      : null
    trustedRootCertificates: [
      for trustedRootCertificate in trustedRootCertificates: {
        name: trustedRootCertificate.name
        properties: {
          keyVaultSecretId: '${reference(trustedRootCertificate.keyVaultResourceId, '2021-10-01').vaultUri}secrets/${trustedRootCertificate.secretName}'
        }
      }
    ]
    sslCertificates: [
      for sslCertificate in sslCertificates: {
        name: sslCertificate.name
        properties: {
          keyVaultSecretId: '${reference(sslCertificate.keyVaultResourceId, '2021-10-01').vaultUri}secrets/${sslCertificate.secretName}'
        }
      }
    ]
    sslPolicy: sslPolicy
    backendHttpSettingsCollection: [
      for backendHttpSetting in backendHttpSettings: {
        name: backendHttpSetting.name
        properties: {
          port: backendHttpSetting.port
          protocol: backendHttpSetting.protocol
          cookieBasedAffinity: backendHttpSetting.cookieBasedAffinity
          affinityCookieName: contains(backendHttpSetting, 'affinityCookieName')
            ? backendHttpSetting.affinityCookieName
            : null
          requestTimeout: backendHttpSetting.requestTimeout
          connectionDraining: backendHttpSetting.connectionDraining
          probe: contains(backendHttpSetting, 'probeName')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId('Microsoft.Network/applicationGateways/probes', name, backendHttpSetting.probeName)
              }
            : null
          trustedRootCertificates: contains(backendHttpSetting, 'trustedRootCertificate')
            ? [
                {
                  #disable-next-line use-resource-id-functions
                  id: az.resourceId(
                    'Microsoft.Network/applicationGateways/trustedRootCertificates',
                    name,
                    backendHttpSetting.trustedRootCertificate
                  )
                }
              ]
            : []
          hostName: contains(backendHttpSetting, 'hostName') ? backendHttpSetting.hostName : null
          pickHostNameFromBackendAddress: contains(backendHttpSetting, 'pickHostNameFromBackendAddress')
            ? backendHttpSetting.pickHostNameFromBackendAddress
            : false
        }
      }
    ]
    httpListeners: [
      for httpListener in httpListeners: {
        name: httpListener.name
        properties: {
          frontendIPConfiguration: {
            #disable-next-line use-resource-id-functions
            id: az.resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              name,
              contains(httpListener, 'frontEndType')
                ? toLower(httpListener.frontEndType) == 'private'
                    ? frontendPrivateIpConfigurationName
                    : frontendPublicIpConfigurationName
                : frontendPublicIpConfigurationName
            )
          }
          frontendPort: {
            #disable-next-line use-resource-id-functions
            id: az.resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, httpListener.frontEndPort)
          }
          protocol: httpListener.protocol
          sslCertificate: contains(httpListener, 'sslCertificate')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId(
                  'Microsoft.Network/applicationGateways/sslCertificates',
                  name,
                  httpListener.sslCertificate
                )
              }
            : null
          hostNames: contains(httpListener, 'hostNames') ? httpListener.hostNames : null
          hostName: contains(httpListener, 'hostName') ? httpListener.hostName : null
          requireServerNameIndication: contains(httpListener, 'requireServerNameIndication')
            ? httpListener.requireServerNameIndication
            : false
          firewallPolicy: contains(httpListener, 'firewallPolicyId')
            ? {
                id: httpListener.firewallPolicyId
              }
            : !empty(firewallPolicyId)
                ? {
                    id: firewallPolicyId
                  }
                : null
        }
      }
    ]
    requestRoutingRules: [
      for rule in requestRoutingRules: {
        name: rule.name
        properties: {
          ruleType: rule.ruleType
          priority: rule.priority
          httpListener: contains(rule, 'httpListener')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId('Microsoft.Network/applicationGateways/httpListeners', name, rule.httpListener)
              }
            : null
          backendAddressPool: contains(rule, 'backendAddressPool')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId(
                  'Microsoft.Network/applicationGateways/backendAddressPools',
                  name,
                  rule.backendAddressPool
                )
              }
            : null
          backendHttpSettings: contains(rule, 'backendHttpSettings')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId(
                  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                  name,
                  rule.backendHttpSettings
                )
              }
            : null
          redirectConfiguration: contains(rule, 'redirectConfiguration')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId(
                  'Microsoft.Network/applicationGateways/redirectConfigurations',
                  name,
                  rule.redirectConfiguration
                )
              }
            : null
        }
      }
    ]
    redirectConfigurations: [
      for redirectConfiguration in redirectConfigurations: {
        name: redirectConfiguration.name
        properties: {
          redirectType: redirectConfiguration.redirectType
          targetUrl: redirectConfiguration.targetUrl
          targetListener: contains(redirectConfiguration, 'targetListener')
            ? {
                #disable-next-line use-resource-id-functions
                id: az.resourceId(
                  'Microsoft.Network/applicationGateways/httpListeners',
                  name,
                  redirectConfiguration.targetListener
                )
              }
            : null
          includePath: redirectConfiguration.includePath
          includeQueryString: redirectConfiguration.includeQueryString
          requestRoutingRules: [
            {
              #disable-next-line use-resource-id-functions
              id: az.resourceId(
                'Microsoft.Network/applicationGateways/requestRoutingRules',
                name,
                redirectConfiguration.requestRoutingRule
              )
            }
          ]
        }
      }
    ]
  }
}

#disable-next-line use-recent-api-versions
resource diagnosticsApplicationGateway 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: applicationGateway
  name: applicationGatewayDiagnosticsName
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

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: applicationGateway
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed application gateway.')
output name string = applicationGateway.name

@description('The resource ID of the deployed application gateway.')
output resourceId string = applicationGateway.id
