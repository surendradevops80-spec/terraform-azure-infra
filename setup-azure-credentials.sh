#!/bin/bash

# Script to create Azure Service Principal and GitHub Secret for Terraform CI/CD
# Usage: ./setup-azure-credentials.sh

SUBSCRIPTION_ID="28b33a86-0366-416d-8614-9dccbe3c193b"
CLIENT_ID="3110b5b8-7322-41fc-b5eb-cf7157c58954"
TENANT_ID="0e48a96c-4cf9-4bb4-bf06-2a912f0fc53e"

echo "=========================================="
echo "Setting up Azure Credentials for GitHub"
echo "=========================================="
echo ""

# Step 1: Create Service Principal credentials
echo "Step 1: Creating credentials JSON..."
echo ""

# You need to add a client secret to your app
# Run this command to get the secret:
# az ad app credential reset --id $CLIENT_ID --display-name terraform-github --query password -o tsv

read -p "Enter the Client Secret (password) from Azure Portal: " CLIENT_SECRET

if [ -z "$CLIENT_SECRET" ]; then
    echo "❌ Client Secret is required!"
    exit 1
fi

# Create the credentials JSON
CREDENTIALS_JSON="{
  \"clientId\": \"$CLIENT_ID\",
  \"clientSecret\": \"$CLIENT_SECRET\",
  \"subscriptionId\": \"$SUBSCRIPTION_ID\",
  \"tenantId\": \"$TENANT_ID\",
  \"activeDirectoryEndpointUrl\": \"https://login.microsoftonline.com\",
  \"resourceManagerEndpointUrl\": \"https://management.azure.com/\",
  \"activeDirectoryGraphResourceId\": \"https://graph.windows.net/\",
  \"sqlManagementEndpointUrl\": \"https://management.core.windows.net:8443/\",
  \"galleryEndpointUrl\": \"https://gallery.azure.com/\",
  \"managementEndpointUrl\": \"https://management.core.windows.net/\"
}"

echo ""
echo "✅ Credentials JSON created!"
echo ""
echo "Step 2: Setting GitHub Secret..."
echo ""
echo "The credentials will be set as AZURE_CREDENTIALS secret"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) not found. Please install it first!"
    echo ""
    echo "Generated Credentials JSON:"
    echo "$CREDENTIALS_JSON"
    echo ""
    echo "Then run:"
    echo "gh secret set AZURE_CREDENTIALS --body '$CREDENTIALS_JSON'"
    exit 1
fi

# Set the GitHub secret
echo "$CREDENTIALS_JSON" | gh secret set AZURE_CREDENTIALS

echo ""
echo "✅ GitHub secret AZURE_CREDENTIALS has been set!"
echo ""
echo "Pipeline should now run successfully! 🚀"
echo ""
