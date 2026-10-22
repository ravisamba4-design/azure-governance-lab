#!/usr/bin/env bash
set -euo pipefail

RG="rg-governance-lab"
SUB_ID=$(az account show --query id -o tsv)
SCOPE="/subscriptions/$SUB_ID/resourceGroups/$RG"

# Look up built-in policy definitions by name
LOC_POLICY=$(az policy definition list \
  --query "[?displayName=='Allowed locations'].name | [0]" -o tsv)
TAG_POLICY=$(az policy definition list \
  --query "[?displayName=='Require a tag on resources'].name | [0]" -o tsv)

# 1. Allowed locations: uksouth only
az policy assignment create \
  --name "allowed-locations-uksouth" \
  --display-name "Allowed locations: UK South only" \
  --policy "$LOC_POLICY" \
  --scope "$SCOPE" \
  --params '{"listOfAllowedLocations":{"value":["uksouth"]}}'

# 2. Require an env tag on all resources
az policy assignment create \
  --name "require-env-tag" \
  --display-name "Require env tag on resources" \
  --policy "$TAG_POLICY" \
  --scope "$SCOPE" \
  --params '{"tagName":{"value":"env"}}'

echo "Policies assigned to $RG"
