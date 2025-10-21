#!/bin/bash
# DirectApp - Schema Sync Script
# Syncs database schema between environments
#
# Usage:
#   ./scripts/sync-schema.sh local staging   # Sync from local to staging
#   ./scripts/sync-schema.sh staging prod    # Sync from staging to production
#   ./scripts/sync-schema.sh --help          # Show help

set -e

# ========================================
# Configuration
# ========================================
SCHEMA_DIR="schema/snapshots"
STAGING_URL="https://staging-gapp.coms.no"
PRODUCTION_URL="https://gapp.coms.no"
LOCAL_URL="http://localhost:8055"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ========================================
# Functions
# ========================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Get URL for environment
get_env_url() {
    case "$1" in
        local)
            echo "$LOCAL_URL"
            ;;
        staging)
            echo "$STAGING_URL"
            ;;
        production|prod)
            echo "$PRODUCTION_URL"
            ;;
        *)
            print_error "Unknown environment: $1"
            exit 1
            ;;
    esac
}

# Export schema from environment
export_schema() {
    local ENV=$1
    local URL=$(get_env_url "$ENV")
    local OUTPUT="$SCHEMA_DIR/${ENV}.json"

    print_info "Exporting schema from $ENV ($URL)..."

    # Create schema directory if it doesn't exist
    mkdir -p "$SCHEMA_DIR"

    # Export schema using Directus CLI or API
    if [ "$ENV" = "local" ]; then
        # Use npx directus for local
        npx directus schema snapshot "$OUTPUT"
    else
        # Use API for remote environments
        # Note: Requires admin token - get from environment variable
        local TOKEN="${DIRECTUS_TOKEN:-}"

        if [ -z "$TOKEN" ]; then
            print_error "DIRECTUS_TOKEN environment variable required for remote export"
            print_info "Get token from: $URL/admin/settings/access-tokens"
            exit 1
        fi

        curl -sf "$URL/schema/snapshot" \
            -H "Authorization: Bearer $TOKEN" \
            -o "$OUTPUT"
    fi

    if [ ! -f "$OUTPUT" ]; then
        print_error "Schema export failed"
        exit 1
    fi

    # Validate JSON
    if jq empty "$OUTPUT" 2>/dev/null; then
        print_success "Schema exported: $OUTPUT"
    else
        print_error "Invalid JSON in exported schema"
        exit 1
    fi
}

# Apply schema to environment
apply_schema() {
    local ENV=$1
    local SCHEMA_FILE=$2
    local URL=$(get_env_url "$ENV")

    print_info "Applying schema to $ENV ($URL)..."

    if [ ! -f "$SCHEMA_FILE" ]; then
        print_error "Schema file not found: $SCHEMA_FILE"
        exit 1
    fi

    # Apply schema
    if [ "$ENV" = "local" ]; then
        # Use npx directus for local
        npx directus schema apply "$SCHEMA_FILE" --yes
    else
        # Use API for remote environments
        local TOKEN="${DIRECTUS_TOKEN:-}"

        if [ -z "$TOKEN" ]; then
            print_error "DIRECTUS_TOKEN environment variable required for remote apply"
            print_info "Get token from: $URL/admin/settings/access-tokens"
            exit 1
        fi

        curl -sf -X POST "$URL/schema/apply" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d @"$SCHEMA_FILE"
    fi

    print_success "Schema applied to $ENV"
}

# Sync schema between environments
sync_schema() {
    local FROM=$1
    local TO=$2

    print_header "Schema Sync: $FROM → $TO"

    # Confirm if syncing to production
    if [ "$TO" = "production" ] || [ "$TO" = "prod" ]; then
        print_warning "You are about to sync schema to PRODUCTION"
        echo ""
        read -p "Type 'yes' to continue: " CONFIRM

        if [ "$CONFIRM" != "yes" ]; then
            print_info "Sync cancelled"
            exit 0
        fi
    fi

    # Export from source
    export_schema "$FROM"

    # Apply to target
    local SCHEMA_FILE="$SCHEMA_DIR/${FROM}.json"
    apply_schema "$TO" "$SCHEMA_FILE"

    print_success "Schema sync complete: $FROM → $TO"
}

# Show diff between schemas
show_diff() {
    local ENV1=$1
    local ENV2=$2

    print_header "Schema Diff: $ENV1 ↔ $ENV2"

    local FILE1="$SCHEMA_DIR/${ENV1}.json"
    local FILE2="$SCHEMA_DIR/${ENV2}.json"

    if [ ! -f "$FILE1" ]; then
        print_error "Schema not found: $FILE1"
        print_info "Run: ./scripts/sync-schema.sh export $ENV1"
        exit 1
    fi

    if [ ! -f "$FILE2" ]; then
        print_error "Schema not found: $FILE2"
        print_info "Run: ./scripts/sync-schema.sh export $ENV2"
        exit 1
    fi

    # Show diff
    diff -u <(jq -S . "$FILE1") <(jq -S . "$FILE2") || true
}

# Show help
show_help() {
    cat << EOF
DirectApp Schema Sync Script

Usage:
  ./scripts/sync-schema.sh <source> <target>
  ./scripts/sync-schema.sh export <environment>
  ./scripts/sync-schema.sh diff <env1> <env2>

Commands:
  <source> <target>   Sync schema from source to target
  export <env>        Export schema from environment
  diff <env1> <env2>  Show schema differences

Environments:
  local       Local development (http://localhost:8055)
  staging     Staging (https://staging-gapp.coms.no)
  production  Production (https://gapp.coms.no)

Examples:
  # Export local schema
  ./scripts/sync-schema.sh export local

  # Sync local to staging
  ./scripts/sync-schema.sh local staging

  # Sync staging to production
  ./scripts/sync-schema.sh staging production

  # Show diff between local and staging
  ./scripts/sync-schema.sh diff local staging

Environment Variables:
  DIRECTUS_TOKEN    Admin access token (required for remote operations)

Notes:
  - Schemas are saved to: schema/snapshots/
  - Production sync requires confirmation
  - Local uses Directus CLI, remote uses API
  - Get admin token from: Settings → Access Tokens

For more information, see: schema/README.md
EOF
}

# ========================================
# Main
# ========================================

case "${1:-}" in
    export)
        export_schema "${2:-}"
        ;;
    diff)
        show_diff "${2:-}" "${3:-}"
        ;;
    --help|-h|help)
        show_help
        ;;
    *)
        if [ -z "$1" ] || [ -z "$2" ]; then
            print_error "Missing arguments"
            echo ""
            echo "Usage: ./scripts/sync-schema.sh <source> <target>"
            echo "Run './scripts/sync-schema.sh --help' for more information"
            exit 1
        fi
        sync_schema "$1" "$2"
        ;;
esac
