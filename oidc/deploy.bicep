metadata description = 'Creates a User-Assigned Managed Identity, and zero or more Federated Credentials for the Identity'
metadata author = 'me@nathannellans.com'

targetScope = 'resourceGroup'

//-----------------------
// Parameters
//-----------------------
@description('Required. Name of the User-Assigned Managed Identity')
param name string

@description('Optional. Location to deploy the Identity into. Default is the same location as the deployment Resource Group')
param location string = resourceGroup().location

@description('Optional. Tags to assign to the Identity. Default is no tags')
param tags object = {}

// Custom type used by the 'fedCreds' param
type fedCredsType = {
  @description('The name of the Federated Credential')
  name: string
  
  @description('Audiences to use for the Federated Credential. Must be an array of strings')
  audiences: array
  
  @description('Issuer to use for the Federated Credential')
  issuer: string
  
  @description('The subject to use for the Federated Credential')
  subject: string
}[]

@description('Optional. An array of objects defining the Federated Credential(s) for the Identity. Default is no credentials')
param fedCreds fedCredsType = []

//-----------------------
// Resources
//-----------------------
resource uamIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

@batchSize(1) // Can only deploy 1 Federated Credential at a time
resource fedCred 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = [for item in fedCreds: {
  parent: uamIdentity
  
  name: item.name
  properties: {
    audiences: item.audiences
    issuer: item.issuer
    subject: item.subject
  }
}]
