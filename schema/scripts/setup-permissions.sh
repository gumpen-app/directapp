#!/bin/bash
# setup-permissions.sh - Create roles, policies, and permissions for DirectApp
#
# This script implements the permission model defined in docs/PERMISSION_MODEL.md
# It should be run as part of Phase 0 setup (after migrations, during seed data creation)
#
# Prerequisites:
# - Directus instance running
# - Admin token in environment or .env file
# - directus_users collection has dealership_id field
#
# Related: Issue #1 (Remove unscoped DELETE), Issues #20-23 (Phase 0 setup)

set -euo pipefail

# Configuration
DIRECTUS_URL="${DIRECTUS_URL:-http://localhost:8055}"
DIRECTUS_TOKEN="${DIRECTUS_TOKEN:-}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if [ -z "$DIRECTUS_TOKEN" ]; then
        log_error "DIRECTUS_TOKEN environment variable is not set"
        log_info "Run: export DIRECTUS_TOKEN=your-admin-token"
        exit 1
    fi

    # Test API connection
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $DIRECTUS_TOKEN" \
        "$DIRECTUS_URL/server/info")

    if [ "$response" != "200" ]; then
        log_error "Cannot connect to Directus at $DIRECTUS_URL (HTTP $response)"
        exit 1
    fi

    log_success "Connected to Directus"

    # Check if dealership_id exists on directus_users
    log_warning "TODO: Verify dealership_id field exists on directus_users"
    log_warning "This field must be created by migration first (Issue #20)"
}

# API helper function
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3

    if [ "$DRY_RUN" = "true" ]; then
        log_info "DRY RUN: $method $endpoint"
        echo "$data" | jq '.' 2>/dev/null || echo "$data"
        return 0
    fi

    local url="$DIRECTUS_URL$endpoint"

    if [ "$method" = "GET" ]; then
        curl -s -X GET \
            -H "Authorization: Bearer $DIRECTUS_TOKEN" \
            -H "Content-Type: application/json" \
            "$url" | jq '.'
    else
        curl -s -X "$method" \
            -H "Authorization: Bearer $DIRECTUS_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$url" | jq '.'
    fi
}

# Create policy
create_policy() {
    local name=$1
    local description=$2
    local admin_access=$3
    local app_access=$4
    local enforce_tfa=$5

    log_info "Creating policy: $name"

    local data=$(cat <<EOF
{
  "name": "$name",
  "description": "$description",
  "admin_access": $admin_access,
  "app_access": $app_access,
  "enforce_tfa": $enforce_tfa
}
EOF
)

    local result=$(api_call "POST" "/policies" "$data")

    if echo "$result" | jq -e '.data.id' > /dev/null 2>&1; then
        local policy_id=$(echo "$result" | jq -r '.data.id')
        log_success "Created policy: $name ($policy_id)"
        echo "$policy_id"
    else
        log_error "Failed to create policy: $name"
        echo "$result" | jq '.'
        return 1
    fi
}

# Create role
create_role() {
    local name=$1
    local description=$2
    local icon=$3
    local policy_id=$4

    log_info "Creating role: $name"

    local role_data=$(cat <<EOF
{
  "name": "$name",
  "description": "$description",
  "icon": "$icon"
}
EOF
)

    local result=$(api_call "POST" "/roles" "$role_data")

    if echo "$result" | jq -e '.data.id' > /dev/null 2>&1; then
        local role_id=$(echo "$result" | jq -r '.data.id')
        log_success "Created role: $name ($role_id)"

        # Link role to policy via access table
        log_info "Linking role $name to policy"
        local access_data=$(cat <<EOF
{
  "role": "$role_id",
  "policy": "$policy_id"
}
EOF
)

        api_call "POST" "/access" "$access_data" > /dev/null
        log_success "Linked role to policy"

        echo "$role_id"
    else
        log_error "Failed to create role: $name"
        echo "$result" | jq '.'
        return 1
    fi
}

# Create permission
create_permission() {
    local policy_id=$1
    local collection=$2
    local action=$3
    local filter=$4
    local fields=$5
    local validation=$6

    log_info "  → Creating permission: $collection.$action"

    # Build permission object
    local perm_data=$(cat <<EOF
{
  "policy": "$policy_id",
  "collection": "$collection",
  "action": "$action",
  "permissions": $filter,
  "fields": $fields
EOF
)

    # Add validation if provided
    if [ "$validation" != "null" ]; then
        perm_data="$perm_data, \"validation\": $validation"
    fi

    perm_data="$perm_data }"

    local result=$(api_call "POST" "/permissions" "$perm_data")

    if echo "$result" | jq -e '.data.id' > /dev/null 2>&1; then
        log_success "    Created: $collection.$action"
    else
        log_error "    Failed: $collection.$action"
        echo "$result" | jq '.'
        return 1
    fi
}

# Setup Sales Policy
setup_sales_policy() {
    log_info "=== Setting up Sales Policy ==="

    local policy_id=$(create_policy \
        "Sales Policy" \
        "Permissions for Nybilselger and Bruktbilselger roles" \
        false \
        true \
        false)

    log_info "Creating permissions for Sales Policy ($policy_id)"

    # Cars - Create
    create_permission "$policy_id" "cars" "create" \
        '{}' \
        '["*"]' \
        'null'

    # Cars - Read (all dealership cars)
    create_permission "$policy_id" "cars" "read" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    # Cars - Update (only early workflow stages)
    create_permission "$policy_id" "cars" "update" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_in": ["registered", "parts_ordered_seller"]}}]}' \
        '["seller_notes", "parts_notes", "parts_ordered_seller_at", "parts_arrived_seller_at", "customer_name", "customer_phone", "customer_email", "sale_price"]' \
        'null'

    # Dealership - Read
    create_permission "$policy_id" "dealership" "read" \
        '{"id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["id", "dealership_number", "dealership_name", "location", "dealership_type", "brand", "active"]' \
        'null'

    # Resource bookings - Read
    create_permission "$policy_id" "resource_bookings" "read" \
        '{"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    # Notifications
    create_permission "$policy_id" "notifications" "create" \
        '{}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "notifications" "read" \
        '{"recipient": {"_eq": "$CURRENT_USER"}}' \
        '["*"]' \
        'null'

    log_success "Sales Policy setup complete"
    echo "$policy_id"
}

# Setup Reception Policy
setup_reception_policy() {
    log_info "=== Setting up Reception Policy ==="

    local policy_id=$(create_policy \
        "Reception Policy" \
        "Permissions for Mottakskontroll (Reception Inspector) role" \
        false \
        true \
        false)

    log_info "Creating permissions for Reception Policy ($policy_id)"

    # Cars - Read (only pending inspection)
    create_permission "$policy_id" "cars" "read" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_in": ["registered", "klar_for_planlegging"]}}]}' \
        '["id", "status", "vin", "license_plate", "brand", "model", "model_year", "color", "car_type", "registered_at", "inspection_completed_at", "inspection_approved", "inspection_notes", "estimated_technical_hours", "estimated_cosmetic_hours", "seller_notes", "parts_notes", "technical_notes", "cosmetic_notes"]' \
        'null'

    # Cars - Update (inspection fields)
    create_permission "$policy_id" "cars" "update" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_eq": "registered"}}]}' \
        '["status", "inspection_completed_at", "inspection_approved", "inspection_notes", "estimated_technical_hours", "estimated_cosmetic_hours"]' \
        'null'

    # Dealership - Read
    create_permission "$policy_id" "dealership" "read" \
        '{"id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["id", "dealership_number", "dealership_name", "location", "dealership_type", "brand"]' \
        'null'

    # Resource types - Read all
    create_permission "$policy_id" "resource_types" "read" \
        '{}' \
        '["*"]' \
        'null'

    log_success "Reception Policy setup complete"
    echo "$policy_id"
}

# Setup Mechanics Policy
setup_mechanics_policy() {
    log_info "=== Setting up Mechanics Policy ==="

    local policy_id=$(create_policy \
        "Mechanics Policy" \
        "Permissions for Klargjoring (Mechanic/Detailer) role" \
        false \
        true \
        false)

    log_info "Creating permissions for Mechanics Policy ($policy_id)"

    # Cars - Read (only assigned cars)
    create_permission "$policy_id" "cars" "read" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"_or": [{"assigned_mechanic_id": {"_eq": "$CURRENT_USER"}}, {"assigned_detailer_id": {"_eq": "$CURRENT_USER"}}]}]}' \
        '["id", "status", "vin", "license_plate", "brand", "model", "model_year", "color", "car_type", "scheduled_technical_date", "scheduled_technical_time", "technical_started_at", "technical_completed_at", "scheduled_cosmetic_date", "scheduled_cosmetic_time", "cosmetic_started_at", "cosmetic_completed_at", "accessories", "estimated_technical_hours", "estimated_cosmetic_hours", "seller_notes", "parts_notes", "technical_notes", "cosmetic_notes", "assigned_mechanic_id", "assigned_detailer_id"]' \
        'null'

    # Cars - Update (work progress fields)
    create_permission "$policy_id" "cars" "update" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"_or": [{"assigned_mechanic_id": {"_eq": "$CURRENT_USER"}}, {"assigned_detailer_id": {"_eq": "$CURRENT_USER"}}]}, {"status": {"_in": ["planlagt", "behandles"]}}]}' \
        '["status", "technical_started_at", "technical_completed_at", "technical_notes", "cosmetic_started_at", "cosmetic_completed_at", "cosmetic_notes"]' \
        'null'

    # Resource bookings - Read own
    create_permission "$policy_id" "resource_bookings" "read" \
        '{"user_id": {"_eq": "$CURRENT_USER"}}' \
        '["*"]' \
        'null'

    # Resource bookings - Update own
    create_permission "$policy_id" "resource_bookings" "update" \
        '{"_and": [{"user_id": {"_eq": "$CURRENT_USER"}}, {"status": {"_in": ["planned", "in_progress"]}}]}' \
        '["status", "actual_hours", "notes", "completed_at"]' \
        'null'

    # Resource types - Read all
    create_permission "$policy_id" "resource_types" "read" \
        '{}' \
        '["*"]' \
        'null'

    log_success "Mechanics Policy setup complete"
    echo "$policy_id"
}

# Setup Workshop Planner Policy
setup_workshop_planner_policy() {
    log_info "=== Setting up Workshop Planner Policy ==="

    local policy_id=$(create_policy \
        "Workshop Planner Policy" \
        "Permissions for Booking (Workshop Planner) role" \
        false \
        true \
        false)

    log_info "Creating permissions for Workshop Planner Policy ($policy_id)"

    # Cars - Read (active workflow)
    create_permission "$policy_id" "cars" "read" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_in": ["klar_for_planlegging", "planlagt", "behandles"]}}]}' \
        '["id", "status", "vin", "license_plate", "brand", "model", "car_type", "scheduled_technical_date", "scheduled_technical_time", "scheduled_cosmetic_date", "scheduled_cosmetic_time", "estimated_technical_hours", "estimated_cosmetic_hours", "assigned_mechanic_id", "assigned_detailer_id", "inspection_notes", "parts_notes", "technical_notes", "cosmetic_notes"]' \
        'null'

    # Cars - Update (scheduling fields)
    create_permission "$policy_id" "cars" "update" \
        '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_in": ["klar_for_planlegging", "planlagt"]}}]}' \
        '["status", "scheduled_technical_date", "scheduled_technical_time", "scheduled_cosmetic_date", "scheduled_cosmetic_time", "assigned_mechanic_id", "assigned_detailer_id"]' \
        'null'

    # Resource bookings - Full CRUD
    create_permission "$policy_id" "resource_bookings" "create" \
        '{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_bookings" "read" \
        '{"_or": [{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_bookings" "update" \
        '{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["car_id", "resource_type_id", "user_id", "date", "start_time", "estimated_hours", "actual_hours", "status", "notes", "completed_at"]' \
        'null'

    # Resource capacities - Full CRUD
    create_permission "$policy_id" "resource_capacities" "create" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_capacities" "read" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_capacities" "update" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    # Resource sharing - Read
    create_permission "$policy_id" "resource_sharing" "read" \
        '{"_or": [{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}' \
        '["*"]' \
        'null'

    # Resource types - Read all
    create_permission "$policy_id" "resource_types" "read" \
        '{}' \
        '["*"]' \
        'null'

    # Dealership - Read
    create_permission "$policy_id" "dealership" "read" \
        '{"id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    log_success "Workshop Planner Policy setup complete"
    echo "$policy_id"
}

# Setup Manager Policy
setup_manager_policy() {
    log_info "=== Setting up Manager Policy ==="

    local policy_id=$(create_policy \
        "Manager Policy" \
        "Permissions for Daglig leder (Dealership Manager) role" \
        false \
        true \
        false)

    log_info "Creating permissions for Manager Policy ($policy_id)"

    # Cars - Full CRUD (except delete)
    create_permission "$policy_id" "cars" "create" \
        '{}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "cars" "read" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "cars" "update" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    # Dealership - Read and Update
    create_permission "$policy_id" "dealership" "read" \
        '{"id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "dealership" "update" \
        '{"id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["dealership_name", "location", "dealership_type", "brand", "parent_dealership_id", "prep_center_id", "does_own_prep", "brand_colors", "logo", "active"]' \
        'null'

    # Resource bookings - Full CRUD
    create_permission "$policy_id" "resource_bookings" "create" \
        '{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_bookings" "read" \
        '{"_or": [{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_bookings" "update" \
        '{"_or": [{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}' \
        '["*"]' \
        'null'

    # Resource capacities - Full CRUD
    create_permission "$policy_id" "resource_capacities" "create" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_capacities" "read" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "resource_capacities" "update" \
        '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}' \
        '["*"]' \
        'null'

    # Resource sharing - Read
    create_permission "$policy_id" "resource_sharing" "read" \
        '{"_or": [{"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}' \
        '["*"]' \
        'null'

    # Resource types - Read all
    create_permission "$policy_id" "resource_types" "read" \
        '{}' \
        '["*"]' \
        'null'

    # Notifications
    create_permission "$policy_id" "notifications" "create" \
        '{}' \
        '["*"]' \
        'null'

    create_permission "$policy_id" "notifications" "read" \
        '{"_or": [{"recipient": {"_eq": "$CURRENT_USER"}}, {"recipient": {"_null": true}}]}' \
        '["*"]' \
        'null'

    log_success "Manager Policy setup complete"
    echo "$policy_id"
}

# Update Administrator Policy (ensure TFA)
update_admin_policy() {
    log_info "=== Updating Administrator Policy ==="

    # Get existing admin policy ID
    local result=$(api_call "GET" "/policies?filter[name][_eq]=Administrator" "")
    local policy_id=$(echo "$result" | jq -r '.data[0].id')

    if [ "$policy_id" = "null" ] || [ -z "$policy_id" ]; then
        log_error "Administrator policy not found"
        return 1
    fi

    log_info "Ensuring TFA is enforced on Administrator policy ($policy_id)"

    local update_data='{"enforce_tfa": true}'
    api_call "PATCH" "/policies/$policy_id" "$update_data" > /dev/null

    log_success "Administrator policy updated (TFA enforced)"
}

# Create roles and link to policies
create_roles() {
    log_info "=== Creating Roles ==="

    local sales_policy_id=$1
    local reception_policy_id=$2
    local mechanics_policy_id=$3
    local planner_policy_id=$4
    local manager_policy_id=$5

    # Sales roles (both use same policy)
    create_role "Nybilselger" "New car sales representative" "sell" "$sales_policy_id"
    create_role "Bruktbilselger" "Used car sales representative" "sell" "$sales_policy_id"

    # Operations roles
    create_role "Mottakskontroll" "Reception inspector - inspects arriving cars" "verified" "$reception_policy_id"
    create_role "Klargjoring" "Mechanic/Detailer - performs technical and cosmetic prep" "build" "$mechanics_policy_id"
    create_role "Booking" "Workshop planner - schedules resources and manages bookings" "calendar_month" "$planner_policy_id"

    # Management role
    create_role "Daglig leder" "Dealership manager - full dealership access" "admin_panel_settings" "$manager_policy_id"

    log_success "All roles created"
}

# Verify setup
verify_setup() {
    log_info "=== Verifying Setup ==="

    # Count roles
    local roles_result=$(api_call "GET" "/roles" "")
    local roles_count=$(echo "$roles_result" | jq '.data | length')
    log_info "Total roles: $roles_count (expected: 7 including Administrator)"

    # Count policies
    local policies_result=$(api_call "GET" "/policies" "")
    local policies_count=$(echo "$policies_result" | jq '.data | length')
    log_info "Total policies: $policies_count (expected: 7 including Public + Administrator)"

    # Count permissions (should be many)
    local perms_result=$(api_call "GET" "/permissions?limit=1000" "")
    local perms_count=$(echo "$perms_result" | jq '.data | length')
    log_info "Total permissions: $perms_count"

    # Check for DELETE permissions (should be ZERO on custom collections)
    local delete_perms=$(echo "$perms_result" | jq '[.data[] | select(.action == "delete" and (.collection | startswith("directus_") | not))] | length')

    if [ "$delete_perms" -eq 0 ]; then
        log_success "✓ NO DELETE permissions on custom collections"
    else
        log_error "✗ Found $delete_perms DELETE permissions on custom collections!"
        echo "$perms_result" | jq '.data[] | select(.action == "delete" and (.collection | startswith("directus_") | not))'
        return 1
    fi

    log_success "Setup verification complete"
}

# Main execution
main() {
    echo ""
    log_info "DirectApp Permission Setup"
    log_info "Implementing permission model from docs/PERMISSION_MODEL.md"
    echo ""

    if [ "$DRY_RUN" = "true" ]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    check_prerequisites
    echo ""

    # Create policies and store their IDs
    sales_policy_id=$(setup_sales_policy)
    echo ""

    reception_policy_id=$(setup_reception_policy)
    echo ""

    mechanics_policy_id=$(setup_mechanics_policy)
    echo ""

    planner_policy_id=$(setup_workshop_planner_policy)
    echo ""

    manager_policy_id=$(setup_manager_policy)
    echo ""

    update_admin_policy
    echo ""

    # Create roles and link to policies
    create_roles "$sales_policy_id" "$reception_policy_id" "$mechanics_policy_id" "$planner_policy_id" "$manager_policy_id"
    echo ""

    # Verify everything
    verify_setup
    echo ""

    log_success "Permission setup complete!"
    echo ""
    log_info "Next steps:"
    log_info "1. Run permission linter: ./schema/scripts/lint-permissions.sh"
    log_info "2. Create test users for each role (Issue #23)"
    log_info "3. Test dealership isolation"
    log_info "4. Export schema for version control"
    echo ""
}

# Run main function
main "$@"
