@export()
type backendAddressPoolsType = ({
  name: string
  backendAddresses: [
    {
      fqdn: string?
      ipAddress: string
    }
  ]
})[]

@export()
type frontEndPortsType = ({
  name: string
  port: int
})[]

@export()
type virtualNetworkSubnetsType = ({
  name: string
  addressPrefix: string
  networkSecurityGroupId: string?
  routeTableId: string?
  natGatewayId: string?
  privateEndpointNetworkPolicies: bool?
  privateLinkServiceNetworkPolicies: bool?
  delegation: string?
  serviceEndpoints: [
    {
      service: string
    }
  ]?
})[]

// User defined function to lookup the resource id of a subnet based on its name
@export()
func getSubnetResourceId(subId string, resourceGroup string, vNetName string, subnetName string) string =>
  resourceId(subId, resourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
