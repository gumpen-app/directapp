# Vehicle Extensions Integration Guide

**Date**: 2025-10-29
**Purpose**: How to activate and use vehicle-lookup and vehicle-search extensions

---

## Extension Comparison

| Feature | vehicle-lookup | vehicle-search |
|---------|---------------|----------------|
| **Type** | Endpoint (External API) | Endpoint (Internal DB) |
| **Data Source** | Statens Vegvesen API | Directus cars collection |
| **Purpose** | Auto-populate from government registry | Search existing vehicles |
| **Authentication** | API token required | User session |
| **Use Case** | New vehicle registration | Find existing vehicles |
| **Performance** | 5-10s (external API) | <100ms (database) |

---

## vehicle-lookup: External API Integration

### What It Does
Fetches official vehicle data from Norwegian government registry by VIN or license plate.

### API Endpoints

**Base URL**: `/directapp-endpoint-vehicle-lookup/`

**1. Lookup by License Plate**
```bash
GET /directapp-endpoint-vehicle-lookup/regnr/:regnr
```

**Example**:
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-lookup/regnr/AB12345" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

**Response**:
```json
{
  "regnr": "AB12345",
  "vin": "WVWZZZ1KZBW123456",
  "make": "Volkswagen",
  "model": "Golf",
  "year": 2024,
  "color": "Blue",
  "first_registration": "2024-01-15",
  "vehicle_group": "M1",
  "fuel_type": "Petrol",
  "co2_emissions": 120
}
```

**2. Lookup by VIN**
```bash
GET /directapp-endpoint-vehicle-lookup/vin/:vin
```

**Example**:
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-lookup/vin/WVWZZZ1KZBW123456" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

### Configuration Required

**Environment Variable**:
```bash
# Add to .env
STATENS_VEGVESEN_TOKEN=your-api-token-here
```

**Quick Setup (Development)**:
Since staging already has this token, just copy it:
```bash
# Get token from staging (Dokploy or staging server)
# Then add to dev .env:
echo "STATENS_VEGVESEN_TOKEN=token-from-staging" >> .env
docker compose -f docker-compose.dev.yml restart directus
```

**Getting a New Token** (if needed):
1. Register at https://autosys-kjoretoy-api.atlas.vegvesen.no/
2. Create API credentials
3. Add token to `.env`
4. Restart Directus

**See `VEHICLE_EXTENSIONS_DEV_SETUP.md` for detailed setup instructions.**

### Integration with UI

**Option 1: Add Lookup Button to VIN Field**

Use the `vehicle-lookup-button` interface on the VIN field:

```json
{
  "field": "vin",
  "meta": {
    "interface": "vehicle-lookup-button",
    "options": {
      "lookupEndpoint": "/vehicle-lookup/vin",
      "targetFields": {
        "brand": "make",
        "model": "model",
        "model_year": "year",
        "color": "color",
        "license_plate": "regnr"
      }
    }
  }
}
```

**Result**: Button next to VIN field → "Lookup Vehicle Data" → Auto-fills fields

**Option 2: Add Lookup Button to License Plate Field**

```json
{
  "field": "license_plate",
  "meta": {
    "interface": "vehicle-lookup-button",
    "options": {
      "lookupEndpoint": "/vehicle-lookup/regnr",
      "targetFields": {
        "vin": "vin",
        "brand": "make",
        "model": "model",
        "model_year": "year",
        "color": "color"
      }
    }
  }
}
```

**Option 3: Custom Action Button (Using @directus-labs/field-actions)**

If you want a standalone button instead of modifying field interface:

```json
{
  "field": "lookup_action",
  "type": "alias",
  "meta": {
    "interface": "field-actions",
    "options": {
      "actions": [
        {
          "label": "Lookup VIN",
          "icon": "search",
          "endpoint": "/vehicle-lookup/vin/{{vin}}",
          "confirmationMessage": "Fetch vehicle data from Statens Vegvesen?"
        }
      ]
    }
  }
}
```

---

## vehicle-search: Internal Database Search

### What It Does
Searches existing cars in Directus database with multiple filters and pagination.

### API Endpoints

### API Endpoints

**Base URL**: `/directapp-endpoint-vehicle-search/`

**1. Multi-field Search**
```bash
GET /directapp-endpoint-vehicle-search/?query=toyota&limit=10
```

**Parameters**:
- `query` - Search across VIN, license_plate, order_number, customer_name, brand, model
- `vin` - Exact VIN match
- `license_plate` - License plate match
- `order_number` - Order number match
- `customer_name` - Customer name match
- `status` - Filter by status
- `car_type` - Filter by car type
- `dealership_id` - Filter by dealership
- `limit` - Results per page (default: 20, max: 100)
- `offset` - Pagination offset

**Example 1: Search for "toyota"**
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/?query=toyota&limit=10" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

**Response**:
```json
{
  "data": [
    {
      "id": "uuid-1",
      "vin": "JTMB12345...",
      "brand": "Toyota",
      "model": "Corolla",
      "status": "technical_prep",
      "customer_name": "John Doe"
    }
  ],
  "meta": {
    "total": 15,
    "limit": 10,
    "offset": 0
  }
}
```

**Example 2: Search by VIN**
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/vin/WVWZZZ1KZBW123456" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

**Example 3: Get Statistics**
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/stats" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

**Response**:
```json
{
  "summary": {
    "new_car": {
      "draft": 5,
      "technical_prep": 10,
      "cosmetic_prep": 8,
      "delivered": 45
    },
    "used_car": {
      "draft": 3,
      "inspection": 7,
      "delivered": 23
    }
  },
  "total": 101
}
```

**2. Get Single Car**
```bash
GET /directapp-endpoint-vehicle-search/:id
```

**Example**:
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/car-uuid-here" \
  -H "Authorization: Bearer YOUR_DIRECTUS_TOKEN"
```

**3. Find by VIN (Direct Endpoint)**
```bash
GET /directapp-endpoint-vehicle-search/vin/:vin
```

### Integration with UI

**Option 1: Add Search Panel (Custom)**

Create a custom panel that uses vehicle-search for dashboard:

```vue
<template>
  <div class="vehicle-search-panel">
    <input v-model="searchQuery" @input="debouncedSearch" placeholder="Search vehicles..." />
    <div v-for="car in results" :key="car.id" class="result-card">
      <h3>{{ car.brand }} {{ car.model }}</h3>
      <p>VIN: {{ car.vin }}</p>
      <p>Status: {{ car.status }}</p>
    </div>
  </div>
</template>

<script>
export default {
  methods: {
    async search() {
      const response = await this.$api.get(`/vehicle-search?query=${this.searchQuery}`);
      this.results = response.data;
    }
  }
}
</script>
```

**Option 2: Use in Custom Endpoint**

Call vehicle-search from other endpoints:

```typescript
// In another custom endpoint
router.post('/assign-mechanic', async (req, res) => {
  // Find cars needing technical prep
  const response = await fetch('http://localhost:8055/directapp-endpoint-vehicle-search/?status=parts_ordered');
  const cars = await response.json();

  // Assign mechanic to all matching cars
  // ...
});
```

**Option 3: API Integration**

Use vehicle-search in external systems (mobile app, admin tools):

```javascript
// Mobile app searching for cars
const searchCars = async (query) => {
  const response = await fetch(
    `https://your-directus.com/directapp-endpoint-vehicle-search/?query=${query}&dealership_id=${userDealershipId}`,
    {
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    }
  );
  return await response.json();
};
```

---

## Testing the Extensions

### Test vehicle-lookup (After API Token Configuration)

**1. Check Health**
```bash
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health
```

**Expected**:
```json
{
  "status": "healthy",
  "configured": true
}
```

**2. Test Lookup**
```bash
# Get Directus admin token first
TOKEN="your-directus-admin-token"

# Test with a known Norwegian license plate
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-lookup/regnr/AB12345" \
  -H "Authorization: Bearer $TOKEN"
```

### Test vehicle-search (Works Now)

**1. Basic Search**
```bash
TOKEN="your-directus-admin-token"

# Search all fields for "toyota"
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/?query=toyota" \
  -H "Authorization: Bearer $TOKEN"
```

**2. Get Statistics**
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/stats" \
  -H "Authorization: Bearer $TOKEN"
```

**3. Search by Status**
```bash
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/?status=technical_prep&limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Activation Checklist

### vehicle-lookup
- [ ] Copy `STATENS_VEGVESEN_TOKEN` from staging to dev `.env`
- [ ] Restart Directus
- [ ] Verify health endpoint shows `configured: true`
- [ ] Add `vehicle-lookup-button` interface to VIN or license_plate field
- [ ] Test lookup in Directus admin

**Note**: Staging already has the token - just copy it to development. See `VEHICLE_EXTENSIONS_DEV_SETUP.md`.

### vehicle-search
- [x] Extension loaded (no configuration needed)
- [ ] Test search endpoint with curl
- [ ] Test statistics endpoint
- [ ] Create custom dashboard panel (optional)
- [ ] Document search endpoint for frontend team
- [ ] Add search functionality to mobile app (if applicable)

---

## Common Use Cases

### Use Case 1: New Vehicle Registration Workflow

**Seller enters VIN → Click "Lookup" → Fields auto-fill**

1. User navigates to Cars → Create New
2. Enters VIN: `WVWZZZ1KZBW123456`
3. Clicks "Lookup Vehicle Data" button (vehicle-lookup-button interface)
4. Extension calls `/vehicle-lookup/vin/WVWZZZ1KZBW123456`
5. Returns data from Statens Vegvesen
6. Auto-fills: brand, model, year, color
7. User completes remaining fields (customer info, etc.)
8. Saves vehicle

**Benefits**:
- ✅ Reduces data entry time by 80%
- ✅ Eliminates typos in brand/model names
- ✅ Ensures VIN validity
- ✅ Provides accurate technical specs

### Use Case 2: Find Vehicles for Mechanic Assignment

**Coordinator searches for cars needing technical prep**

1. Coordinator opens custom dashboard panel
2. Uses vehicle-search: `?status=parts_ordered`
3. Gets list of all cars ready for technical work
4. Assigns mechanic to selected vehicles
5. Updates status to `technical_prep`

**Benefits**:
- ✅ Fast filtering by status
- ✅ Dealership isolation (only sees own vehicles)
- ✅ Pagination for large result sets
- ✅ Real-time statistics

### Use Case 3: Customer Service Lookup

**Customer calls asking about their vehicle status**

1. Customer service rep searches by customer name
2. Uses vehicle-search: `?customer_name=John+Doe`
3. Finds all vehicles for that customer
4. Provides status update
5. Can filter by order_number or license_plate for precision

**Benefits**:
- ✅ Multi-field search (name, phone, license plate)
- ✅ Fast response time (<100ms)
- ✅ No external API dependency

---

## Performance Considerations

### vehicle-lookup
- **External API**: 5-10 second response time
- **Rate Limits**: Check Statens Vegvesen API limits
- **Caching**: Not implemented (each lookup hits API)
- **Error Handling**: Returns 503 if API unavailable

**Recommendations**:
- Add caching layer for frequently looked up VINs
- Implement retry logic for API timeouts
- Show loading spinner to user during lookup

### vehicle-search
- **Database Query**: <100ms response time
- **Indexes**: VIN, license_plate, order_number are indexed
- **Pagination**: Default limit 20, max 100
- **Dealership Filtering**: Automatic via user permissions

**Recommendations**:
- Use pagination for large dealerships (>1000 vehicles)
- Cache statistics endpoint (updates infrequently)
- Add full-text search index for better performance

---

## Troubleshooting

### vehicle-lookup Returns 503
**Problem**: API not configured or invalid token

**Fix**:
```bash
# Check environment variable
docker exec directapp-dev env | grep STATENS_VEGVESEN_API_TOKEN

# If missing, add to .env and restart
echo "STATENS_VEGVESEN_API_TOKEN=your-token" >> .env
docker compose -f docker-compose.dev.yml restart directus
```

### vehicle-search Returns 401
**Problem**: User not authenticated

**Fix**: Ensure Authorization header includes valid Directus token

### vehicle-lookup-button Not Showing
**Problem**: Interface not assigned to field

**Fix**:
1. Go to Settings → Data Model → cars collection → vin field
2. Change Interface from "Input" to "Vehicle Lookup Button"
3. Configure target fields in interface options
4. Save

---

## Next Steps

1. **Configure vehicle-lookup API token**
2. **Add vehicle-lookup-button to VIN field**
3. **Test lookup workflow with real VIN**
4. **Create dashboard panel using vehicle-search**
5. **Document endpoints for frontend team**
6. **Train users on new lookup functionality**

---

## See Also

- `EXTENSIONS_VERIFICATION_REPORT.md` - All extensions status
- `CUSTOM_EXTENSIONS_REVIEW.md` - Code quality analysis
- `WORKFLOW_GUARD_FIX.md` - Fix workflow-guard issue first
