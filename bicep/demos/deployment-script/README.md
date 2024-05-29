# Deployment Script

This demo shows how to deploy a deployment script using Bicep.

The deployment script will create an Entra ID Group and do the following:

- Create the group if it does not exist
- Add users to the group based on the `userPrincipalNames` parameter

## Pre-requisites

- Service Principal with `Groups Administrator` role in Entra ID
- Key vault with secrets containing the service principal client id and secret

## Deployment

To deploy the deployment script, run the following command:

```bash
az deployment group create -g <resource-group> -f .\create-entra-id-group.bicep -p .\create-entra-id-group.bicepparam
```
