#!/bin/bash
# Fix Directus UI displays by configuring field metadata via API

TOKEN="H1_jHEj2Y11Vs8G3Aw7P79_SJfoF5zlK"
BASE_URL="http://localhost:8055"

echo "Configuring Directus field displays..."

# Configure dealership.parent_dealership_id
curl -s -X PATCH "$BASE_URL/fields/dealership/parent_dealership_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ dealership.parent_dealership_id"

# Configure dealership.prep_center_id
curl -s -X PATCH "$BASE_URL/fields/dealership/prep_center_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ dealership.prep_center_id"

# Configure cars.dealership_id
curl -s -X PATCH "$BASE_URL/fields/cars/dealership_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ cars.dealership_id"

# Configure cars.prep_center_id
curl -s -X PATCH "$BASE_URL/fields/cars/prep_center_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ cars.prep_center_id"

# Configure resource_sharing fields
curl -s -X PATCH "$BASE_URL/fields/resource_sharing/provider_dealership_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ resource_sharing.provider_dealership_id"

curl -s -X PATCH "$BASE_URL/fields/resource_sharing/consumer_dealership_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ resource_sharing.consumer_dealership_id"

curl -s -X PATCH "$BASE_URL/fields/resource_sharing/resource_type_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{name}}"
      }
    }
  }' > /dev/null && echo "✓ resource_sharing.resource_type_id"

# Configure directus_users.dealership_id
curl -s -X PATCH "$BASE_URL/fields/directus_users/dealership_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meta": {
      "interface": "select-dropdown-m2o",
      "display": "related-values",
      "display_options": {
        "template": "{{dealership_number}} - {{dealership_name}}"
      }
    }
  }' > /dev/null && echo "✓ directus_users.dealership_id"

echo ""
echo "✅ Display templates configured!"
echo "Refresh your Directus UI to see readable names instead of IDs."
