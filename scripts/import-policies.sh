#!/bin/bash

# Import Role Policies Script
# Imports comprehensive role-based policies and permissions into Directus

set -e

API_URL="${PUBLIC_URL:-http://localhost:8055}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@dev.local}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-DevPassword123!}"

echo "📋 Importing Role-Based Access Control Policies..."
echo ""

# Authenticate and get token
echo "🔐 Authenticating as admin..."
AUTH_RESPONSE=$(cat <<EOF | curl -s -X POST "${API_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d @-
{
  "email": "${ADMIN_EMAIL}",
  "password": "${ADMIN_PASSWORD}"
}
EOF
)

TOKEN=$(echo "$AUTH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])" 2>/dev/null || echo "")

if [ -z "$TOKEN" ]; then
  echo "❌ Authentication failed!"
  echo "$AUTH_RESPONSE"
  exit 1
fi

echo "✅ Authenticated"
echo ""

# Function to create a policy
create_policy() {
  local name="$1"
  local description="$2"

  echo "   ➕ Creating policy: $name"

  POLICY_DATA=$(cat <<EOF
{
  "name": "$name",
  "icon": "badge",
  "description": "$description",
  "ip_access": null,
  "enforce_tfa": true,
  "admin_access": false,
  "app_access": true
}
EOF
)

  RESPONSE=$(echo "$POLICY_DATA" | curl -s -X POST "${API_URL}/policies" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d @-)

  POLICY_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null || echo "")

  if [ -z "$POLICY_ID" ]; then
    echo "      ⚠️  Policy may already exist or error occurred"
    # Try to get existing policy ID
    EXISTING=$(curl -s -X GET "${API_URL}/policies?filter[name][_eq]=$name" \
      -H "Authorization: Bearer $TOKEN")
    POLICY_ID=$(echo "$EXISTING" | python3 -c "import sys, json; data=json.load(sys.stdin)['data']; print(data[0]['id'] if data else '')" 2>/dev/null || echo "")
  else
    echo "      ✅ Created with ID: $POLICY_ID"
  fi

  echo "$POLICY_ID"
}

# Create all policies
echo "📦 Creating policies..."
echo ""

POL_NYBILSELGER=$(create_policy "Nybilselger" "Nybilselger - Can create and manage nybil for own dealership")
POL_BRUKTBILSELGER=$(create_policy "Bruktbilselger" "Bruktbilselger - Can create bruktbil and search across dealerships")
POL_DELELAGER=$(create_policy "Delelager" "Delelager - Manages parts ordering and tracking")
POL_MOTTAKSKONTROLL=$(create_policy "Mottakskontrollør" "Mottakskontrollør - Performs vehicle inspections")
POL_BOOKING=$(create_policy "Booking" "Booking - Workshop scheduling and assignment")
POL_MEKANIKER=$(create_policy "Mekaniker" "Mekaniker - Technical prep work with time banking")
POL_BILPLEIER=$(create_policy "Bilpleiespesialist" "Bilpleiespesialist - Cosmetic prep work with time banking")
POL_DAGLIG_LEDER=$(create_policy "Daglig leder" "Daglig leder - Read-only access to all dealership data")
POL_OKONOMI=$(create_policy "Økonomiansvarlig" "Økonomiansvarlig - Financial data access and pricing")

echo ""
echo "✅ All policies created"
echo ""

# Now import all permissions from JSON file using Python
echo "🔐 Creating permissions from JSON template..."
echo ""

python3 <<PYTHON_SCRIPT
import json
import requests
import sys

API_URL = "${API_URL}"
TOKEN = "${TOKEN}"

# Policy ID mapping
policy_map = {
    "pol-nybilselger": "${POL_NYBILSELGER}",
    "pol-bruktbilselger": "${POL_BRUKTBILSELGER}",
    "pol-delelager": "${POL_DELELAGER}",
    "pol-mottakskontroll": "${POL_MOTTAKSKONTROLL}",
    "pol-booking": "${POL_BOOKING}",
    "pol-mekaniker": "${POL_MEKANIKER}",
    "pol-bilpleier": "${POL_BILPLEIER}",
    "pol-daglig-leder": "${POL_DAGLIG_LEDER}",
    "pol-okonomi": "${POL_OKONOMI}"
}

# Load permissions JSON
with open('schema/policies/complete-role-policies.json') as f:
    data = json.load(f)

permission_count = 0
headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

for perm in data['permissions']:
    # Skip comments
    if 'comment' in perm:
        print(f"\n{perm['comment']}")
        continue

    # Replace template policy ID with real UUID
    perm_data = perm.copy()
    perm_data['policy'] = policy_map.get(perm['policy'], perm['policy'])

    try:
        response = requests.post(
            f"{API_URL}/permissions",
            headers=headers,
            json=perm_data
        )

        if response.status_code == 200 or response.status_code == 204:
            permission_count += 1
            policy_name = [k for k, v in policy_map.items() if v == perm_data['policy']][0] if perm_data['policy'] in policy_map.values() else perm_data['policy']
            print(f"   ✅ {perm['collection']}.{perm['action']} ({policy_name})")
        else:
            print(f"   ⚠️  Failed: {perm['collection']}.{perm['action']} - {response.text}")
    except Exception as e:
        print(f"   ⚠️  Error: {perm['collection']}.{perm['action']} - {str(e)}")

print(f"\n✅ Created {permission_count} permissions")
PYTHON_SCRIPT

echo ""
echo "📊 Import Summary:"
echo "   Policies: 9"
echo "   Permissions: Check output above"
echo ""
echo "🎉 Import complete!"
echo ""
echo "Next steps:"
echo "1. Go to Settings → Roles & Permissions"
echo "2. For each role, assign the corresponding policy via the 'Access' tab"
echo "3. Test with test users from Issue #23"
echo ""
