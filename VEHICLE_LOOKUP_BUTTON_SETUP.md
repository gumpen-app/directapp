# Vehicle Lookup Button - Setup Instructions

**Date**: 2025-10-29
**Status**: ⚠️ Interface exists but not configured in collection

---

## Current Status

- ✅ Extension loaded: `directapp-interface-vehicle-lookup-button`
- ❌ Not added to cars collection yet
- ⚠️ Requires API token: `STATENS_VEGVESEN_API_TOKEN`

---

## What It Does

The vehicle-lookup-button is a **smart interface** that:
1. Shows a "Fetch Vehicle Data" button in the form
2. Reads VIN or license plate from another field
3. Calls Statens Vegvesen API
4. Auto-populates vehicle fields (brand, model, year, color)
5. Provides visual feedback on which fields were updated

**Key Feature**: It's a separate alias field, not a replacement for the VIN input. This allows users to:
- Enter VIN manually (if known)
- Click lookup button to auto-fill remaining fields
- Keep lookup functionality separate from data entry

---

## How to Add to Cars Collection

### Step 1: Add Lookup Button Field

**Via Directus Admin UI:**

1. Go to **Settings → Data Model → cars**
2. Click **Create Field**
3. Choose **Alias** type (no data stored)
4. Configure field:
   - **Field Name**: `vehicle_lookup_action`
   - **Display Label**: "Vehicle Lookup"
   - **Interface**: `vehicle-lookup-button`
   - **Field Group**: `vehicle_info_group` (to appear near VIN/license plate)

5. Configure Interface Options:

   **Lookup Configuration**:
   - Lookup Field: `vin` (or `license_plate`)
   - Lookup Mode: `Manual (Button Only)` (recommended)
   - Button Label: `Fetch Vehicle Data`

   **Field Population**:
   - Overwrite Mode: `Only Fill Empty Fields` (recommended)
   - Fields to Populate: Select all (brand, model, model_year, color, vin, license_plate)

   **Validation**:
   - Validate Input: ✅ Enabled
   - When No Results: `Show Error Only`

   **UI**:
   - Show Updated Fields List: ✅ Enabled
   - Compact Mode: ❌ Disabled

6. **Position**: Set `sort` order to appear right after `vin` field (sort: 8.5)

7. Save field

### Step 2: Configure API Token

**Add to `.env` file:**
```bash
# Add this line to .env
STATENS_VEGVESEN_API_TOKEN=your-api-token-here
```

**Get API Token:**
1. Visit https://autosys-kjoretoy-api.atlas.vegvesen.no/
2. Register/login
3. Generate API credentials
4. Copy token to `.env`

**Restart Directus:**
```bash
docker compose -f docker-compose.dev.yml restart directus
```

### Step 3: Verify Configuration

**Test API is configured:**
```bash
curl http://localhost:8055/vehicle-lookup/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "configured": true
}
```

If `configured: false`, check:
- `.env` has `STATENS_VEGVESEN_API_TOKEN`
- Directus was restarted after adding token
- Token is valid

---

## User Workflow After Setup

### Scenario: Registering a New Car

1. **User navigates to**: Content → Cars → Create New

2. **User enters VIN**: `WVWZZZ1KZBW123456`

3. **User clicks**: "Fetch Vehicle Data" button (vehicle_lookup_action field)

4. **System**:
   - Validates VIN format (17 characters)
   - Calls `/vehicle-lookup/vin/WVWZZZ1KZBW123456`
   - Shows loading spinner

5. **API returns data**:
   ```json
   {
     "make": "Volkswagen",
     "model": "Golf",
     "year": 2024,
     "color": "Blue Metallic",
     "regnr": "AB12345"
   }
   ```

6. **System auto-fills**:
   - Brand: Volkswagen
   - Model: Golf
   - Model Year: 2024
   - Color: Blue Metallic
   - License Plate: AB12345 (if empty)

7. **User sees confirmation**: "✅ Updated 5 fields: brand, model, model_year, color, license_plate"

8. **User completes form**: Enters customer info, dealership, etc.

9. **User saves**: Vehicle saved with accurate data

---

## Interface Configuration Options

### Lookup Configuration

| Option | Values | Recommended | Notes |
|--------|--------|-------------|-------|
| **Lookup Field** | `vin`, `license_plate` | `vin` | Which field to read for lookup |
| **Lookup Mode** | `manual`, `auto`, `both` | `manual` | Prevents accidental API calls |
| **Auto-Lookup Delay** | milliseconds | 1500ms | Only if mode is `auto` or `both` |
| **Button Label** | string | "Fetch Vehicle Data" | Customize button text |

### Field Population

| Option | Values | Recommended | Notes |
|--------|--------|-------------|-------|
| **Overwrite Mode** | `always`, `empty_only`, `never` | `empty_only` | Prevents data loss |
| **Fields to Populate** | array | All fields | Select specific fields if needed |

### Validation & Error Handling

| Option | Values | Recommended | Notes |
|--------|--------|-------------|-------|
| **Validate Input** | boolean | `true` | Checks VIN/license plate format |
| **When No Results** | `error_only`, `clear_field`, `warn_keep` | `error_only` | User decides next step |

### UI Customization

| Option | Values | Recommended | Notes |
|--------|--------|-------------|-------|
| **Show Updated Fields** | boolean | `true` | Shows which fields changed |
| **Compact Mode** | boolean | `false` | Smaller button, less feedback |

---

## Interface Capabilities

### Smart Features

**1. Conditional Validation**
- VIN: Must be 17 characters, no I/O/Q
- License Plate: Norwegian format (2 letters + 5 digits)

**2. Overwrite Protection**
- `empty_only` mode prevents overwriting user-entered data
- User sees warning if data would be lost

**3. Visual Feedback**
- Loading spinner during API call
- Success message with list of updated fields
- Error messages for API failures

**4. Flexible Modes**
- **Manual**: Button only (recommended for data accuracy)
- **Auto**: Lookup on field change (useful for batch entry)
- **Both**: Button + auto-lookup (power users)

---

## Alternative Setup: Using MCP Tools

**If you prefer to add field via MCP:**

```json
{
  "action": "create",
  "collection": "cars",
  "data": [{
    "field": "vehicle_lookup_action",
    "type": "alias",
    "meta": {
      "interface": "vehicle-lookup-button",
      "special": ["alias", "no-data"],
      "options": {
        "lookupField": "vin",
        "lookupMode": "manual",
        "buttonLabel": "Fetch Vehicle Data",
        "overwriteMode": "empty_only",
        "validateInput": true,
        "onNoResults": "error_only",
        "showUpdatedFields": true,
        "compactMode": false
      },
      "width": "full",
      "sort": 8,
      "group": "vehicle_info_group",
      "translations": [
        {"language": "no-NO", "translation": "Hent kjøretøydata"},
        {"language": "en-US", "translation": "Vehicle Lookup"}
      ]
    },
    "schema": null
  }]
}
```

---

## Benefits of This Approach

### Vs. Manual Entry
- **80% faster** data entry
- **Zero typos** in brand/model names
- **Validated VINs** (only real vehicles)
- **Accurate specs** from government registry

### Vs. Auto-Population
- **User control** over when to lookup
- **No accidental API calls** while typing
- **Preserves manual edits** (if data needs correction)
- **Clear visual feedback** of what changed

### Vs. External Tools
- **Integrated workflow** (no copy/paste)
- **Audit trail** (logged in Directus)
- **Permission-aware** (only authorized users)
- **Offline-friendly** (optional lookup)

---

## Troubleshooting

### Issue: Button doesn't appear
**Cause**: Field not added to collection or wrong type

**Fix**:
1. Check Settings → Data Model → cars
2. Look for `vehicle_lookup_action` field
3. Verify Interface is `vehicle-lookup-button`
4. Verify Type is `alias`

### Issue: Button shows but doesn't work
**Cause**: API token not configured

**Fix**:
```bash
# Check token exists
docker exec directapp-dev env | grep STATENS_VEGVESEN_API_TOKEN

# Add token if missing
echo "STATENS_VEGVESEN_API_TOKEN=your-token" >> .env

# Restart
docker compose -f docker-compose.dev.yml restart directus
```

### Issue: "No results found" error
**Cause**: VIN/license plate not in Statens Vegvesen database

**Possible reasons**:
- Vehicle not registered in Norway
- VIN entered incorrectly
- License plate format wrong

**Fix**: Verify VIN/license plate is correct, enter data manually if needed

### Issue: API returns 503
**Cause**: External API unavailable or token invalid

**Fix**:
1. Check health endpoint: `curl http://localhost:8055/vehicle-lookup/health`
2. Verify token is valid
3. Check Statens Vegvesen API status
4. Contact API provider if persistent

---

## Next Steps

1. ✅ Read this guide
2. ⬜ Get Statens Vegvesen API token
3. ⬜ Add token to `.env`
4. ⬜ Restart Directus
5. ⬜ Add `vehicle_lookup_action` field to cars collection
6. ⬜ Configure interface options
7. ⬜ Test with known VIN
8. ⬜ Train users on new workflow
9. ⬜ Monitor API usage and errors

---

## Summary

**What**: Smart vehicle data lookup button
**Where**: Cars collection, vehicle_info_group
**Type**: Alias field (no data stored)
**Interface**: `vehicle-lookup-button`
**Requires**: Statens Vegvesen API token
**Benefits**: 80% faster registration, zero typos, validated data

**Ready to configure?** Follow Step 1 above to add the field in Directus admin UI.
