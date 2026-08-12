# 🚀 Terraform Azure Pipeline Setup

## Current Status
✅ Pipeline code is ready  
⏳ Waiting for Azure Credentials secret in GitHub

## What You Need to Do

### Step 1: Get the Client Secret from Azure Portal

1. Go to **Azure Portal** → **Entra ID** → **App registrations**
2. Search and open app with ID: `3110b5b8-7322-41fc-b5eb-cf7157c58954`
3. Click **"Certificates & secrets"** (left menu)
4. Click **"+ New client secret"**
5. Set expiration and click **"Add"**
6. **COPY THE VALUE** (not the Secret ID) - this is your `CLIENT_SECRET`

### Step 2: Run the Setup Script

```bash
chmod +x setup-azure-credentials.sh
./setup-azure-credentials.sh
```

Then paste the **Client Secret** when prompted.

### Step 3: Or Set Secret Manually

If the script doesn't work, go to:
**GitHub Repo** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

**Name:** `AZURE_CREDENTIALS`  
**Value:** (Copy the full JSON below with your CLIENT_SECRET)

```json
{
  "clientId": "3110b5b8-7322-41fc-b5eb-cf7157c58954",
  "clientSecret": "YOUR_CLIENT_SECRET_HERE",
  "subscriptionId": "28b33a86-0366-416d-8614-9dccbe3c193b",
  "tenantId": "0e48a96c-4cf9-4bb4-bf06-2a912f0fc53e",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Step 4: Push Something to Trigger Pipeline

```bash
git commit --allow-empty -m "trigger: pipeline run"
git push origin main
```

Pipeline will run automatically! ✅

## Hardcoded Values

Everything else is hardcoded and ready:
- ✅ Terraform configuration
- ✅ Azure provider settings
- ✅ GitHub workflow (just needs credentials)
- ✅ Terraform plan output

The pipeline will:
1. ✅ Checkout code
2. ✅ Login to Azure
3. ✅ Format check
4. ✅ Initialize Terraform
5. ✅ Validate configuration
6. ✅ Plan infrastructure
7. ✅ Upload plan artifact
