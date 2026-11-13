# Azure Devops - Workload Identity Federation
This repo contains an example [Bicep template](deploy.bicep) that will deploy an Azure User-Assigned Managed Identity.  It will also create zero or more Federated Credentials for this identity.

These Federated Credentials can then be used for your Service Connections in Azure DevOps Pipelines.  In the example [parameter file](deploy.bicepparam), you'll find examples on how to create Federated Credentials for Azure DevOps.

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
   - Choose `Azure Resource Manager`, then click `Next`
   - Choose `App registration or managed identity (manual)`, then `Workload identity federation`
   - Fill in all the required information: Service Connection name, your Azure environment and Tenant ID, etc., then click `Next`
   - Pick the scope you want to use (like `Subscription`) and fill in the necessary info for that scope (like `Subscription ID`)
   - Fill in the `Application (Client ID)` with your Managed Identity's client ID
   - Lastly, click on `Keep as draft`
   - Copy down the `issuer` and `subject` values that are shown
4. Update the Federated Credential on your Azure Managed Identity, update the `issuer` and `subject` values with the correct values
5. Go back to the Service Connection in Azure DevOps, click on `Finish Setup`
   - Finally, click on `Verify and save`

## Sources
- [Manually set an ARM workload identity service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/configure-workload-identity)
