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
    issuer: 'https://vstoken.dev.azure.com/<MyOrgGUID>' // This is the GUID or your Azure DevOps Organization
    subject: 'sc://<MyOrgName>/<MyProjectName>/<MyServiceConnectionName>'
  }
  {
    name: 'GitHubActions-FederatedCredential'
    audiences: ['api://AzureADTokenExchange']
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:<MyOrg>/<MyRepo>:environment:<MyEnv>'
    // subject: repo:<MyOrg>/<MyRepo>:pull_request
    // subject: repo:<MyOrg>/<MyRepo>:ref:refs/heads/<MyBranch>
    // subject: repo:<MyOrg>/<MyRepo>:ref:refs/tags/<MyTag>
  }
]
