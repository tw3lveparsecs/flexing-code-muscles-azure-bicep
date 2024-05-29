targetScope = 'subscription'

import * as appGwTypes from 'app-gateway-types.bicep' // currently in preview and requires compileTimeImports to be set in bicepconfig.json

@description('Application gateway name.')
param appGwName string

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('The resource group name.')
param resourceGroup string

@description('Optional. Application gateway public IP address name.')
param publicIpName string

@description('Application gateway managed identity name.')
param managedIdentityName string

@description('Application gateway front end ports.')
param frontEndPorts appGwTypes.frontEndPortsType

@description('SSL certificates of the application gateway resource.')
@metadata({
  name: 'Name of the SSL certificate that is unique within an application gateway.'
  keyVaultResourceId: 'Resource ID of key vault resource containing (base-64 encoded unencrypted pfx) "Secret" or "Certificate" object.'
  secretName: 'Key vault secret name.'
})
param sslCertificates array

@description('Application gateway http listeners.')
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

@description('Application gateway backend address pools.')
param backendAddressPools appGwTypes.backendAddressPoolsType

@description('Probes of the application gateway resource.')
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
param probes array

@description('Application gateway backend http settings.')
@metadata({
  name: 'Name of the backend http settings that is unique within an application gateway.'
  port: 'The destination port on the backend.'
  protocol: 'The protocol used to communicate with the backend.'
  cookieBasedAffinity: 'Cookie based affinity. Acceptable values are "Enabled" or "Disabled".'
  requestTimeout: 'Request timeout in seconds. application gateway will fail the request if response is not received within RequestTimeout. Acceptable values are from 1 second to 86400 seconds.'
  connectionDraining: {
    drainTimeoutInSec: 'The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds.'
    enabled: 'Whether connection draining is enabled or not.'
  }
  trustedRootCertificate: 'Trusted root certificate name of an application gateway.'
  hostName: 'Host header to be sent to the backend servers.'
  probeName: 'Probe name of an application gateway.'
})
param backendHttpSettings array

@description('Application gateway request routing rules.')
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

@description('Name of the firewall policy.')
param firewallPolicyName string

@description('Name of the virtual network.')
param virtualNetworkName string

@description('Address space of the virtual network.')
param virtualNetworkIpAddressSpace array

@description('Subnets of the virtual network.')
param virtualNetworkSubnets appGwTypes.virtualNetworkSubnetsType

@description('Name of the application gateway subnet.')
param appGatewaySubnetName string

// reference module for demonstration on bicep linter and using #disable-next-line
module vnet '../../modules/network/virtual-networks/main.bicep' = {
  name: 'vnet-${uniqueString(deployment().name, location)}'
  scope: az.resourceGroup(resourceGroup)
  params: {
    name: virtualNetworkName
    location: location
    addressPrefixes: virtualNetworkIpAddressSpace
    subnets: virtualNetworkSubnets
  }
}

module firewallPolicy '../../modules/network/application-gateways-firewall-policy/main.bicep' = {
  name: 'firewall-policy-${uniqueString(deployment().name, location)}'
  scope: az.resourceGroup(resourceGroup)
  params: {
    name: firewallPolicyName
    location: location
  }
}

module appGatewayManagedIdentity '../../modules/managed-identity/user-assigned-identities/main.bicep' = {
  name: 'app-gateway-id-${uniqueString(deployment().name, location)}'
  scope: az.resourceGroup(resourceGroup)
  params: {
    location: location
    name: managedIdentityName
  }
}

module applicationGateway '../../modules/network/application-gateways/main.bicep' = {
  scope: az.resourceGroup(resourceGroup)
  name: 'app-gateway-${uniqueString(deployment().name, location)}'
  params: {
    name: toLower(appGwName)
    location: location
    sku: 'WAF_v2'
    tier: 'WAF_v2'
    userAssignedIdentities: {
      '${appGatewayManagedIdentity.outputs.resourceId}': {}
    }
    publicIpAddressName: toLower(publicIpName)
    subnetResourceId: appGwTypes.getSubnetResourceId(
      subscription().subscriptionId,
      resourceGroup,
      virtualNetworkName,
      appGatewaySubnetName
    )
    frontEndPorts: frontEndPorts
    sslCertificates: sslCertificates
    httpListeners: httpListeners
    backendAddressPools: backendAddressPools
    backendHttpSettings: backendHttpSettings
    probes: probes
    requestRoutingRules: requestRoutingRules
    firewallPolicyId: firewallPolicy.outputs.resourceId
  }
}
