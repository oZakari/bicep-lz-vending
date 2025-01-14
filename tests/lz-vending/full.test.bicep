targetScope = 'managementGroup'

param location string = 'uksouth'

param prNumber string

param subscriptionBillingScope string

module createSub '../../main.bicep' = {
  name: 'sub-blzv-tests-pr-${prNumber}-blank-sub'
  params: {
    subscriptionAliasEnabled: true
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionAliasName: 'sub-blzv-tests-pr-${prNumber}'
    subscriptionDisplayName: 'sub-blzv-tests-pr-${prNumber}'
    subscriptionTags: {
      prNumber: prNumber
    }
    subscriptionWorkload: 'Production'
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: 'bicep-lz-vending-automation-child'
    virtualNetworkEnabled: false
    roleAssignments: [
      {
        principalId: '7eca0dca-6701-46f1-b7b6-8b424dab50b3'
        definition: 'Reader'
        relativeScope: ''
      }
    ]
  }
}

module hubSpoke '../../main.bicep' = {
  name: 'sub-blzv-tests-pr-${prNumber}-add-vnet-spoke'
  params: {
    subscriptionAliasEnabled: false
    existingSubscriptionId: createSub.outputs.subscriptionId
    virtualNetworkEnabled: true
    virtualNetworkLocation: location
    virtualNetworkResourceGroupName: 'rsg-${location}-net-hs-pr-${prNumber}'
    virtualNetworkName: 'vnet-${location}-hs-pr-${prNumber}'
    virtualNetworkAddressSpace: [
      '10.100.0.0/16'
    ]
    virtualNetworkResourceGroupLockEnabled: false
    virtualNetworkPeeringEnabled: true
    virtualNetworkUseRemoteGateways: false
    hubNetworkResourceId: '/subscriptions/e4e7395f-dc45-411e-b425-95f75e470e16/resourceGroups/rsg-blzv-perm-hubs-001/providers/Microsoft.Network/virtualNetworks/vnet-uksouth-hub-blzv'
  }
}

module vwanSpoke '../../main.bicep' = {
  name: 'sub-blzv-tests-pr-${prNumber}-add-vwan-spoke'
  params: {
    subscriptionAliasEnabled: false
    existingSubscriptionId: createSub.outputs.subscriptionId
    virtualNetworkEnabled: true
    virtualNetworkLocation: location
    virtualNetworkResourceGroupName: 'rsg-${location}-net-vwan-pr-${prNumber}'
    virtualNetworkName: 'vnet-${location}-vwan-pr-${prNumber}'
    virtualNetworkAddressSpace: [
      '10.200.0.0/16'
    ]
    virtualNetworkResourceGroupLockEnabled: false
    virtualNetworkPeeringEnabled: true
    hubNetworkResourceId: '/subscriptions/e4e7395f-dc45-411e-b425-95f75e470e16/resourceGroups/rsg-blzv-perm-hubs-001/providers/Microsoft.Network/virtualHubs/vhub-uksouth-blzv'
  }
}

output createdSubId string = createSub.outputs.subscriptionId
