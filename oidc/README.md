# Azure Devops - Workload Identity Federation
This repo contains an example Bicep template that will deploy an Azure User-Assigned Managed Identity.  It will also create zero or more Federated Credentials for this identity.

These Federated Credentials could be used for things like Service Connections in Azure DevOps Pipelines, GitHub Actions, or more.  In the `deploy.bicepparam` file, you'll find examples on how to create Federated Credentials for both Azure DevOps and GitHub Actions.

## Deployment
Use any method you'd like to deploy the Bicep template, one option is the Azure CLI:

```
az deployment group create -g resourceGroupName -f deploy.bicep -p deploy.bicepparam
```