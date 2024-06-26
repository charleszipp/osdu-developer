@description('The name of the parent key vault.')
param keyVaultName string

@description('The name of the partition.')
param partitionName string

@description('The name of the service bus.')
param serviceBusName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = if (serviceBusName != 'null') {
  name: serviceBusName
}

// Conditional variable for connection string
var serviceBusEndpoint = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'

resource serviceBusConnection 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (serviceBusName != 'null') {
  name: '${partitionName}-sb-connection'
  parent: keyVault

  properties: {
    value: listKeys(serviceBusEndpoint, serviceBus.apiVersion).primaryConnectionString
  }
}

output keyVaultName string = keyVault.name
