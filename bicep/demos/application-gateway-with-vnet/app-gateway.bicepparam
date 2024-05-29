using 'app-gateway.bicep'
// example use of variables and expressions within a Bicep parameter file
var prefix = 'lab'
var description = 'flexdemo'
var appGwSuffix = 'agw'
var vnetSuffix = 'vnet'
var managedIdentitySuffix = 'id'
var publicIpSuffix = 'pip'
var wafPolicySuffix = 'waf'
var resourceGroupSuffix = 'rg'

param appGwName = '${prefix}-${description}-${appGwSuffix}'

param resourceGroup = '${prefix}-${description}-${resourceGroupSuffix}'

param virtualNetworkName = '${prefix}-${description}-${vnetSuffix}'

param virtualNetworkIpAddressSpace = ['10.70.0.0/23']

param appGatewaySubnetName = 'AzureWAFSubnet'

// example of a Bicep array configured with user-defined data type
param virtualNetworkSubnets = [
  {
    name: appGatewaySubnetName
    addressPrefix: '10.70.0.0/24'
  }
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.70.1.0/24'
  }
]

param managedIdentityName = '${prefix}-${description}-${managedIdentitySuffix}'

param publicIpName = '${appGwName}-${publicIpSuffix}'

param firewallPolicyName = '${appGwName}-default-${wafPolicySuffix}'

// example of a Bicep array configured with user-defined data type
param frontEndPorts = [
  {
    name: 'port_443'
    port: 443
  }
  {
    name: 'port_80'
    port: 80
  }
]

// example of a Bicep array NOT configured with user-defined data type
param sslCertificates = []

param httpListeners = [
  {
    name: 'http-80-listener'
    protocol: 'Http'
    frontEndPort: 'port_80'
  }
]
// example of a Bicep array configured with user-defined data type
param backendAddressPools = [
  {
    name: 'myapp-backend-pool'
    backendAddresses: [
      {
        ipAddress: '10.1.2.3'
      }
    ]
  }
]

param probes = [
  {
    name: 'myapp-probe'
    protocol: 'https'
    host: 'myapp.deploy.local'
    pickHostNameFromBackendHttpSettings: false
    path: '/'
    interval: 30
    timeout: 30
    unhealthyThreshold: 3
    match: {
      statusCodes: [
        '200-499'
      ]
    }
  }
]

param backendHttpSettings = [
  {
    name: 'http-80-backend-settings'
    port: 80
    protocol: 'Http'
    cookieBasedAffinity: 'Enabled'
    affinityCookieName: 'MyCookieAffinityName'
    requestTimeout: 300
    connectionDraining: {
      drainTimeoutInSec: 60
      enabled: true
    }
  }
]

param requestRoutingRules = [
  {
    name: 'myapp-http-80-rule'
    ruleType: 'Basic'
    httpListener: 'http-80-listener'
    backendAddressPool: 'myapp-backend-pool'
    backendHttpSettings: 'http-80-backend-settings'
    priority: 100
  }
]
