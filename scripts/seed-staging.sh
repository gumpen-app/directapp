#!/bin/bash
# DirectApp - Seed Staging Data
# Populates staging environment with sample data for testing
#
# Usage:
#   ./scripts/seed-staging.sh

set -e

# ========================================
# Configuration
# ========================================
STAGING_URL="https://staging-gapp.coms.no"

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Get admin token
get_admin_token() {
    local TOKEN="${DIRECTUS_TOKEN:-}"

    if [ -z "$TOKEN" ]; then
        print_error "DIRECTUS_TOKEN environment variable required"
        print_info "Get token from: $STAGING_URL/admin/settings/access-tokens"
        exit 1
    fi

    echo "$TOKEN"
}

# Create dealerships
seed_dealerships() {
    local TOKEN=$1

    print_header "Seeding Dealerships"

    # Sample dealerships
    local DEALERSHIPS=(
        '{"name":"Gumpen Oslo","code":"OSLO","location":"Oslo","dealership_type":"self_sustained","is_active":true}'
        '{"name":"Gumpen Bergen","code":"BERGEN","location":"Bergen","dealership_type":"sales_only","is_active":true}'
        '{"name":"Gumpen Trondheim","code":"TROND","location":"Trondheim","dealership_type":"prep_center","is_active":true}'
    )

    for dealership in "${DEALERSHIPS[@]}"; do
        local NAME=$(echo "$dealership" | jq -r '.name')

        curl -sf -X POST "$STAGING_URL/items/dealership" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$dealership" > /dev/null

        print_success "Created: $NAME"
    done
}

# Create sample users
seed_users() {
    local TOKEN=$1

    print_header "Seeding Users"

    # Get dealership IDs
    local OSLO_ID=$(curl -sf "$STAGING_URL/items/dealership?filter[code][_eq]=OSLO" \
        -H "Authorization: Bearer $TOKEN" | jq -r '.data[0].id')

    # Sample users
    local USERS=(
        "{\"email\":\"selger@gumpen.no\",\"password\":\"Test1234!\",\"role\":\"nybilselger\",\"dealership\":\"$OSLO_ID\",\"first_name\":\"Test\",\"last_name\":\"Selger\"}"
        "{\"email\":\"booking@gumpen.no\",\"password\":\"Test1234!\",\"role\":\"booking\",\"dealership\":\"$OSLO_ID\",\"first_name\":\"Test\",\"last_name\":\"Booking\"}"
    )

    for user in "${USERS[@]}"; do
        local EMAIL=$(echo "$user" | jq -r '.email')

        curl -sf -X POST "$STAGING_URL/users" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$user" > /dev/null

        print_success "Created user: $EMAIL"
    done
}

# Create sample vehicles
seed_vehicles() {
    local TOKEN=$1

    print_header "Seeding Sample Vehicles"

    # Get dealership ID
    local OSLO_ID=$(curl -sf "$STAGING_URL/items/dealership?filter[code][_eq]=OSLO" \
        -H "Authorization: Bearer $TOKEN" | jq -r '.data[0].id')

    # Sample vehicles
    local VEHICLES=(
        "{\"vin\":\"YV1CZ59H621234567\",\"license_plate\":\"AB12345\",\"make\":\"Volvo\",\"model\":\"XC60\",\"year\":2024,\"dealership\":\"$OSLO_ID\",\"status\":\"ubehandlet\",\"is_new\":true}"
        "{\"vin\":\"YV1CZ59H621234568\",\"license_plate\":\"CD67890\",\"make\":\"Volvo\",\"model\":\"V90\",\"year\":2023,\"dealership\":\"$OSLO_ID\",\"status\":\"klar_for_planlegging\",\"is_new\":false}"
    )

    for vehicle in "${VEHICLES[@]}"; do
        local VIN=$(echo "$vehicle" | jq -r '.vin')

        curl -sf -X POST "$STAGING_URL/items/cars" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$vehicle" > /dev/null

        print_success "Created vehicle: $VIN"
    done
}

# Main seeding function
seed_staging() {
    print_header "DirectApp - Seed Staging Data"

    print_info "Target: $STAGING_URL"
    echo ""

    local TOKEN=$(get_admin_token)

    # Seed data
    seed_dealerships "$TOKEN"
    seed_users "$TOKEN"
    seed_vehicles "$TOKEN"

    print_header "Seeding Complete"
    print_success "Staging environment populated with sample data"
    print_info "Access: $STAGING_URL/admin"
    echo ""
}

# ========================================
# Main
# ========================================

seed_staging
