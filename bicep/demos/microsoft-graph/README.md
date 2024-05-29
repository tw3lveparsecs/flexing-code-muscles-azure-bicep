# Microsoft Graph Bicep Demo: Creating a Service Principal with Federated Credentials

This demo showcases how to use the Microsoft Graph Bicep extension to do the following:

- Create a service principal with federated credentials
- Create an Entra ID group and add the service principal to the group
- Assign the group access to a resource group

## Prerequisites

Before running this demo, make sure you have the following prerequisites:

- Bicep experimental settings enabled in `bicepconfig.json` as per below.

```json
{
  "experimentalFeaturesEnabled": {
    "extensibility": true
  }
}
```

## Deployment

To deploy the deployment script, run the following command:

```bash
az deployment group create -g <resource-group> -f .\service-principal-with-rbac.bicep -p .\service-principal-with-rbac.bicepparam
```
