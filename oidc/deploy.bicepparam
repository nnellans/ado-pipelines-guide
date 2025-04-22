using 'deploy.bicep'

param name = 'identityName'
param location = 'EastUS2'
param tags = {
  tagName1: 'tagValue1'
  tagName2: 'tagValue2'
}
param fedCreds = [
  {
    name: 'AzureDevOps-FederatedCredential'
    audiences: ['api://AzureADTokenExchange']
    issuer: 'https://login.microsoftonline.com/<MyTenantID>/v2.0' // This is the ID of your EntraID Tenant
    subject: '<MyEntraPrefix>/sc/<MyOrgID>/<MyServiceConnectionID>'
    // Old Issuer & Subject:  https://learn.microsoft.com/en-us/azure/devops/release-notes/2025/sprint-253-update#workload-identity-federation-uses-entra-issuer
    // issuer: 'https://vstoken.dev.azure.com/<MyOrgGUID>' // This is the GUID or your Azure DevOps Organization
    // subject: 'sc://<MyOrgName>/<MyProjectName>/<MyServiceConnectionName>'
  }
  {
    name: 'GitHubActions-FederatedCredential'
    audiences: ['api://AzureADTokenExchange']
    issuer: 'https://token.actions.githubusercontent.com'
    // Example pointing at an environment
    subject: 'repo:<MyOrg>/<MyRepo>:environment:<MyEnv>'
    // Example pointing at pull requests
    subject: repo:<MyOrg>/<MyRepo>:pull_request
    // Example pointing at a branch
    subject: repo:<MyOrg>/<MyRepo>:ref:refs/heads/<MyBranch>
    // Example pointing at a tag
    subject: repo:<MyOrg>/<MyRepo>:ref:refs/tags/<MyTag>
  }
]
