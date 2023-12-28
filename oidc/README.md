# Azure Devops - Workload Identity Federation
This repo contains an example [Bicep template](deploy.bicep) that will deploy an Azure User-Assigned Managed Identity.  It will also create zero or more Federated Credentials for this identity.

These Federated Credentials could be used for things like Service Connections in Azure DevOps Pipelines, GitHub Actions, or more.  In the example [parameter file](deploy.bicepparam), you'll find examples on how to create Federated Credentials for both Azure DevOps and GitHub Actions.

## Azure DevOps - Deployment Steps
1. First, create the Managed Identity and the Federated Credential
   - Use [any method](https://www.nathannellans.com/post/all-about-bicep-deploying-bicep-files) you'd like to deploy the Bicep template, one option is the Azure CLI:

     ```
     az deployment group create -g resourceGroupName -f deploy.bicep -p deploy.bicepparam
     ```
   - For the Federated Credential `issuer` and `subject` just put dummy values for now.  We'll come back and change them later.
   - Use a good value for the Federated Credential `name` as this can not be changed later.
2. Assign the new Managed Identity to an RBAC role on a Subscription.
3. Create a new Service Connection in Azure DevOps:
   - Choose `Azure Resource Manager` then choose `Workload Identity federation (manual)`
   - Fill in all the required information, including Subscription, Tenant, etc.
   - For `Service Principal Id` enter the `Client ID` from your Managed Identity
   - Copy the `issuer` and `subject` values that are shown here.  Use these values to update your Managed Identity's Federated Credential.
4. Click save, and if you did everything correctly you should have a new Service Connection that is tied to a Managed Identity using Federated Credentials. No more passwords, yay!

## Sources
- [Manually configure Azure Resource Manager workload identity service connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/configure-workload-identity)
