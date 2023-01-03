targetScope = 'subscription'

// ----------
// PARAMETERS
// ----------

param name string
param location string = deployment().location

@description('ISO 8601 format datetime when the application, workload, or service was first deployed.')
param startDate string = dateTimeAdd(utcNow(),'-PT5H','G')

@allowed(['Dev','Prod','QA','Stage','Test'])
@description('Deployment environment of the application, workload, or service.')
param env string

@description('When creating Hub VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses.')
param vnetHubAddressSpace object

@description('Subnets to segment Hub VNet into one or more sub-networks and allocate a portion of the address space to each subnet.')
param vnetHubSubnets array

// ---------
// VARIABLES
// ---------

var tags = {
  Env: env
  StartDate: startDate
}

// ---------
// RESOURCES
// ---------

// Resource group is a container that holds related resources for an Azure solution
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}-${env}'
  location: location
  tags: tags
}

// Hub virtual network acts as a central point of connectivity to spoke virtual networks
module vnetHub 'modules/vnet.bicep' = {
  scope: rg
  // Linked Deployment Name
  name: 'VirtualNetwork-Hub'
  params: {
    name: 'hub-${name}-${env}'
    location: location
    tags: tags
    addressSpace: vnetHubAddressSpace
    subnets: vnetHubSubnets
  }
}
