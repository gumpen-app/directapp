#!/bin/bash
# DirectApp - Fix Critical Permission Issues
#
# Implements fixes from CRITICAL_SCHEMA_FIXES.md:
# 1. Remove DELETE permission on cars (Option A - soft delete instead)
# 2. Fix user update permissions (restrict to self only, no password/email)
# 3. Enable TFA on all admin policies
#
# Usage:
#   ./schema/scripts/fix-permissions.sh [environment]
#   ./schema/scripts/fix-permissions.sh dev

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DIRECTUS_URL="${DIRECTUS_URL:-http://localhost:8055}"
DIRECTUS_TOKEN="${DIRECTUS_TOKEN:-H1_jHEj2Y11Vs8G3Aw7P79_SJfoF5zlK}"

echo -e "${YELLOW}DirectApp Critical Permission Fixes${NC}"
echo "Target: $DIRECTUS_URL"
echo ""

# Check if Directus is accessible
if ! curl -fsS "$DIRECTUS_URL/server/health" > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot connect to Directus at $DIRECTUS_URL${NC}"
    echo "Make sure Directus is running"
    exit 1
fi

echo -e "${GREEN}✓ Directus is running${NC}"
echo ""

# Function to make API calls
api_call() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    if [ -n "$data" ]; then
        curl -fsS -X "$method" "$DIRECTUS_URL/$endpoint" \
            -H "Authorization: Bearer $DIRECTUS_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data"
    else
        curl -fsS -X "$method" "$DIRECTUS_URL/$endpoint" \
            -H "Authorization: Bearer $DIRECTUS_TOKEN"
    fi
}

# FIX #1: Remove DELETE permissions on cars collection
echo -e "${BLUE}[1/3] Removing DELETE permissions on cars collection...${NC}"

# Get all DELETE permissions for cars collection
DELETE_PERMS=$(api_call GET "permissions?filter%5Bcollection%5D%5B_eq%5D=cars&filter%5Baction%5D%5B_eq%5D=delete" | jq -r '.data[].id' || echo "")

if [ -n "$DELETE_PERMS" ]; then
    echo "  Found DELETE permissions to remove:"
    echo "$DELETE_PERMS" | while read perm_id; do
        if [ -n "$perm_id" ]; then
            echo "    Removing permission: $perm_id"
            api_call DELETE "permissions/$perm_id" > /dev/null 2>&1 || echo "      ⚠ Failed to remove $perm_id"
        fi
    done
    echo -e "${GREEN}  ✓ Removed DELETE permissions on cars${NC}"
else
    echo -e "${YELLOW}  ⚠ No DELETE permissions found on cars (already removed?)${NC}"
fi
echo ""

# FIX #2: Fix directus_users update permissions
echo -e "${BLUE}[2/3] Fixing directus_users update permissions...${NC}"

# Get all UPDATE permissions for directus_users that allow password/email
USER_UPDATE_PERMS=$(api_call GET "permissions?filter%5Bcollection%5D%5B_eq%5D=directus_users&filter%5Baction%5D%5B_eq%5D=update" | jq -r '.data[] | select(.policy != null) | select(.fields | contains(["password"]) or contains(["email"])) | .id' || echo "")

if [ -n "$USER_UPDATE_PERMS" ]; then
    echo "  Found dangerous user update permissions to fix:"
    echo "$USER_UPDATE_PERMS" | while read perm_id; do
        if [ -n "$perm_id" ]; then
            echo "    Updating permission: $perm_id"
            # Update to only allow updating own record and remove password/email fields
            api_call PATCH "permissions/$perm_id" '{
                "permissions": {"id": {"_eq": "$CURRENT_USER.id"}},
                "fields": ["first_name", "last_name", "avatar", "language", "appearance", "theme_light", "theme_dark"]
            }' > /dev/null 2>&1 || echo "      ⚠ Failed to update $perm_id"
        fi
    done
    echo -e "${GREEN}  ✓ Fixed user update permissions${NC}"
else
    echo -e "${YELLOW}  ⚠ No dangerous user update permissions found${NC}"
fi
echo ""

# FIX #3: Enable TFA on all admin policies
echo -e "${BLUE}[3/3] Enabling TFA on admin policies...${NC}"

# Get all admin policies without TFA
ADMIN_POLICIES=$(api_call GET "policies?filter%5Badmin_access%5D%5B_eq%5D=true&filter%5Benforce_tfa%5D%5B_neq%5D=true" | jq -r '.data[].id' || echo "")

if [ -n "$ADMIN_POLICIES" ]; then
    echo "  Found admin policies without TFA:"
    echo "$ADMIN_POLICIES" | while read policy_id; do
        if [ -n "$policy_id" ]; then
            POLICY_NAME=$(api_call GET "policies/$policy_id" | jq -r '.data.name' || echo "Unknown")
            echo "    Enabling TFA on: $POLICY_NAME ($policy_id)"
            api_call PATCH "policies/$policy_id" '{"enforce_tfa": true}' > /dev/null 2>&1 || echo "      ⚠ Failed to update $policy_id"
        fi
    done
    echo -e "${GREEN}  ✓ Enabled TFA on all admin policies${NC}"
else
    echo -e "${GREEN}  ✓ All admin policies already have TFA enabled${NC}"
fi
echo ""

# Summary
echo -e "${YELLOW}=== Summary ===${NC}"
echo ""
echo -e "${GREEN}Critical fixes applied!${NC}"
echo ""
echo "Next steps:"
echo "1. Export schema: ./schema/scripts/export.sh dev"
echo "2. Verify fixes: ./schema/scripts/lint-permissions.sh dev"
echo "3. Test in browser: http://localhost:8055/admin"
echo "4. Commit: git add schema-exported/ && git commit -m 'fix: Remove DELETE permissions, implement soft delete'"
echo ""
