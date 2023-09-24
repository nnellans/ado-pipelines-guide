# Azure Devops - Workload Identity Federation
This repo contains an example [Bicep template](deploy.bicep) that will deploy an Azure User-Assigned Managed Identity.  It will also create zero or more Federated Credentials for this identity.

These Federated Credentials could be used for things like Service Connections in Azure DevOps Pipelines, GitHub Actions, or more.  In the example [parameter file](deploy.bicepparam), you'll find examples on how to create Federated Credentials for both Azure DevOps and GitHub Actions.

## Deployment Steps for Azure DevOps
1. First, create the Managed Identity and the Federated Credential
  - Use [any method](https://www.nathannellans.com/post/all-about-bicep-deploying-bicep-files) you'd like to deploy the Bicep template, one option is the Azure CLI:

    ```
    az deployment group create -g resourceGroupName -f deploy.bicep -p deploy.bicepparam
    ```
  - For the Federated Credential `issuer` and `subject` just put dummy values for now.  We'll come back and change them later.
  - Use a good value for the Federated Credential `name` as this can not be changed later.
2. Assign the new Managed Identity to an RBAC role on your Subscription (contributor, owner, etc.)
3. Create a new Service Connection in Azure DevOps
  - Choose `Azure Resource Manager` then choose `Workload Identity federation (manual)`
  - Copy the `issuer` and `subject` values that are shown, update your Managed Identity's Federated Credential with these values (one option is to update your Bicep files and re-deploy)
  - Fill in all the required information, including Subscription, Tenant, etc.
  - For `Service Principal Id` enter the `Client ID` of your Managed Identity
