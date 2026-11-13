using 'deploy.bicep'

param name = 'identityName'
param location = 'EastUS2'
param tags = {
  tagName1: 'tagValue1'
  tagName2: 'tagValue2'
}
param federatedCredentials = [
  {
    name: 'AzureDevOps-FederatedCredential'
    audiences: ['api://AzureADTokenExchange']
    issuer: 'https://login.microsoftonline.com/<MyTenantID>/v2.0'
    subject: '<MyEntraPrefix>/sc/<MyDevopsOrgID>/<MyServiceConnectionID>'

    // DO NOT USE - Old Issuer & Subject
    // More info: https://learn.microsoft.com/en-us/azure/devops/release-notes/2025/sprint-253-update#workload-identity-federation-uses-entra-issuer
    // issuer: 'https://vstoken.dev.azure.com/<MyDevopsOrgGUID>'
    // subject: 'sc://<MyDevopsOrgName>/<MyProjectName>/<MyServiceConnectionName>'
  }
]
