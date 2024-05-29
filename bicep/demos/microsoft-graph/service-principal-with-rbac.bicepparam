using './service-principal-with-rbac.bicep'

param appDisplayName = 'Flex Demo Service Principal'
param appUniqueName = 'flexdemo-svcp'
param fedCredName = 'flexdemo-fedcred'
param fedCredIssuer = 'https://token.actions.githubusercontent.com'
param fedCredSubject = 'repo:tw3lveparsecs/flexdemo:environment:demo'
param groupName = 'flexdemo-entra-graph-group'
