#!/bin/bash
set -e

# Fix permissions on writable directories
chmod -R 777 storage bootstrap/cache 2>/dev/null || true

# Check if 1Password integration is enabled
if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ] && [ -n "$OP_ITEM" ] && [ -n "$OP_VAULT" ]; then
  echo "🔐 Loading secrets from 1Password item: $OP_ITEM (vault: $OP_VAULT)"
  
  # Fetch all fields from the 1Password item as references
  # Format: LABEL=op://vault/item/field
  MAP=$(op item get "$OP_ITEM" --vault "$OP_VAULT" --format json | jq -r '.fields[] | "\(.label)=\(.reference)"')
  
  # Use op run to execute with secrets injected via --env-file
  # Secrets are resolved at process injection time, not stored in shell environment
  # $@ allows any command to be passed from docker-compose
  echo "🚀 Starting: $@"
  echo "$MAP" | exec op run --env-file /dev/stdin -- "$@"
else
  echo "⚙️  Running without 1Password integration"
  echo "   To enable, set OP_SERVICE_ACCOUNT_TOKEN, OP_ITEM, and OP_VAULT environment variables"
  
  # Run the provided command directly
  echo "🚀 Starting: $@"
  exec "$@"
fi
