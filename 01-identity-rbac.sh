#!/usr/bin/env bash
set -euo pipefail

RG="rg-governance-lab"
LOC="uksouth"
DOMAIN=$(az rest --method get --url https://graph.microsoft.com/v1.0/domains \
  --query "value[?isDefault].id" -o tsv)
SUB_ID=$(az account show --query id -o tsv)
PASS="$(openssl rand -base64 18)Aa1!"

echo "Domain: $DOMAIN"

# Resource group with tags
az group create -n "$RG" -l "$LOC" --tags env=lab owner=ravi project=governance

# Groups
az ad group create --display-name "grp-lab-readers" --mail-nickname "grp-lab-readers"
az ad group create --display-name "grp-lab-contributors" --mail-nickname "grp-lab-contributors"

# Users
az ad user create --display-name "Lab Reader" \
  --user-principal-name "lab.reader@$DOMAIN" --password "$PASS" \
  --force-change-password-next-sign-in true
az ad user create --display-name "Lab Contributor" \
  --user-principal-name "lab.contributor@$DOMAIN" --password "$PASS" \
  --force-change-password-next-sign-in true

# Add users to groups
az ad group member add --group "grp-lab-readers" \
  --member-id "$(az ad user show --id lab.reader@$DOMAIN --query id -o tsv)"
az ad group member add --group "grp-lab-contributors" \
  --member-id "$(az ad user show --id lab.contributor@$DOMAIN --query id -o tsv)"

# RBAC: assign roles to GROUPS (not users) at resource group scope
az role assignment create --assignee "$(az ad group show -g grp-lab-readers --query id -o tsv)" \
  --role "Reader" --scope "/subscriptions/$SUB_ID/resourceGroups/$RG"
az role assignment create --assignee "$(az ad group show -g grp-lab-contributors --query id -o tsv)" \
  --role "Contributor" --scope "/subscriptions/$SUB_ID/resourceGroups/$RG"

echo "Done. Temp password (not saved anywhere): $PASS"
