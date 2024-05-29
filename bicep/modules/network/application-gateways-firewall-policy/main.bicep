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

@description('Optional. Firewall policy settings.')
@metadata({
  requestBodyCheck: 'Whether allow WAF to check request Body. Acceptable values are "true" or "false".'
  maxRequestBodySizeInKb: 'Maximum request body size in Kb for WAF.'
  fileUploadLimitInMb: 'Maximum file upload size in Mb for WAF.'
  state: 'The state of the policy. Acceptable values are "Enabled" or "Disabled".'
  mode: 'The mode of the policy. Acceptable values are "Detection" or "Prevention".'
})
param policySettings object = {
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
  state: 'Enabled'
  mode: 'Detection'
}

@description('Optional. The custom rules inside the policy.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#webapplicationfirewallcustomrule'
  example: {
    action: 'Allow'
    matchConditions: [
      {
        matchValues: [
          'string'
        ]
        matchVariables: [
          {
            selector: 'string'
            variableName: 'RequestBody'
          }
        ]
        negationConditon: true
        operator: 'Contains'
        transforms: [
          'Lowercase'
        ]
      }
    ]
    name: 'string'
    priority: 100
    ruleType: 'MatchRule'
  }
})
param customRules array = []

@description('Optional. The managed rule sets that are associated with the policy.')
@metadata({
  ruleGroupOverrides: [
    {
      ruleGroupName: 'The managed rule group to override.'
      rules: [
        {
          ruleId: 'Identifier for the managed rule.'
          state: 'The state of the managed rule. Defaults to Disabled. Acceptable values are "Enabled" or "Disabled".'
        }
      ]
    }
  ]
  ruleSetType: 'Defines the rule set type to use.'
  ruleSetVersion: 'Defines the version of the rule set to use.'
})
param managedRuleSets array = [
  {
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.0'
  }
]

@description('Optional. The Exclusions that are applied on the policy.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#owaspcrsexclusionentry'
  example: {
    exclusionManagedRuleSets: [
      {
        ruleGroups: [
          {
            ruleGroupName: 'string'
            rules: [
              {
                ruleId: 'string'
              }
            ]
          }
        ]
        ruleSetType: 'string'
        ruleSetVersion: 'string'
      }
    ]
    matchVariable: 'RequestArgNames'
    selector: 'string'
    selectorMatchOperator: 'Contains'
  }
})
param managedRuleExclusions array = []

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${firewallPolicy.name}-${resourceLock}-lck')

resource firewallPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    customRules: customRules
    policySettings: policySettings
    managedRules: {
      managedRuleSets: managedRuleSets
      exclusions: managedRuleExclusions
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: firewallPolicy
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed firewall policy.')
output name string = firewallPolicy.name

@description('The resource ID of the deployed firewall policy.')
output resourceId string = firewallPolicy.id
