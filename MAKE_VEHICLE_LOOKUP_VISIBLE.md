# Make Vehicle Lookup Button Visible in UI

**Problem**: You've never seen the vehicle-lookup-button in Directus UI
**Reason**: The interface extension is loaded but NOT added to any field
**Solution**: Add an alias field with this interface (2 minutes)

---

## Quick Fix: Add Field Via Directus Admin

### Step 1: Navigate to Data Model

1. Open Directus admin: http://localhost:8055/admin
2. Go to **Settings** (gear icon)
3. Click **Data Model**
4. Click **cars** collection

### Step 2: Create Alias Field

1. Click **"+ Create Field"** button
2. Choose **"Standard Field"** (NOT "One to Many", NOT "Many to One")
3. Set field details:
   - **Key**: `vehicle_lookup_action`
   - **Type**: Select **"Alias"** from dropdown
   - **Field**: Keep as `vehicle_lookup_action`

### Step 3: Choose Interface

1. In the **"Interface"** section
2. Click the interface dropdown
3. Scroll to find **"Vehicle Lookup Button"** or **"vehicle-lookup-button"**
4. Select it

### Step 4: Configure Interface Options

You'll see configuration options:

**Basic Settings**:
- **Lookup Field**: Select `vin` (or `license_plate`)
- **Lookup Mode**: Choose **"Manual (Button Only)"**
- **Button Label**: Enter `"Fetch Vehicle Data"`

**Field Population**:
- **Overwrite Mode**: Choose **"Only Fill Empty Fields"**
- **Fields to Populate**: Select all vehicle fields:
  - brand
  - model
  - model_year
  - color
  - license_plate (if looking up by VIN)
  - vin (if looking up by license_plate)

**Validation**:
- **Validate Input**: ✅ Enable
- **When No Results**: Choose **"Show Error Only"**

**UI Options**:
- **Show Updated Fields List**: ✅ Enable
- **Compact Mode**: ❌ Disable

### Step 5: Set Field Position

1. Scroll to **"Field Settings"**
2. Set **Width**: **"Full"**
3. Set **Sort**: **9** (to appear after VIN field)
4. Set **Field Group**: **vehicle_info_group** (if it exists)

### Step 6: Save

1. Click **"Save"** button (top right)
2. Wait for confirmation

### Step 7: Test It

1. Go to **Content** → **Cars**
2. Click any existing car OR create new car
3. Look for the **"vehicle_lookup_action"** field
4. You should see a button: **"Fetch Vehicle Data"**
5. Enter a VIN in the VIN field
6. Click the button
7. Watch fields auto-populate!

---

## Alternative: Add Field Via MCP (Faster)

If you want to use MCP tools instead:

```bash
# Use the directapp-dev MCP to add the field
```

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
      "sort": 9,
      "group": null
    },
    "schema": null
  }]
}
```

---

## What Happens After Adding

### Before (Current State)
```
Cars Collection Edit Form:
┌─────────────────────────────┐
│ VIN: [_________________]    │  ← Just input field
│ Brand: [______________]     │
│ Model: [______________]     │
└─────────────────────────────┘
```

### After (With Button)
```
Cars Collection Edit Form:
┌─────────────────────────────┐
│ VIN: [_________________]    │
│                             │
│ [📋 Fetch Vehicle Data]     │  ← NEW BUTTON!
│                             │
│ Brand: [______________]     │
│ Model: [______________]     │
└─────────────────────────────┘
```

### User Workflow
1. User enters VIN: `WVWZZZ1KZBW123456`
2. User clicks **"Fetch Vehicle Data"**
3. Loading spinner appears
4. API calls Statens Vegvesen
5. Fields auto-fill:
   - Brand: "Volkswagen"
   - Model: "Golf"
   - Model Year: 2024
   - Color: "Blue Metallic"
6. Success message: "✅ Updated 4 fields"

---

## Prerequisites

Before the button will actually work:

### 1. API Token Required

The button calls `/vehicle-lookup/` endpoint which needs `STATENS_VEGVESEN_TOKEN`:

```bash
# Add to .env
echo "STATENS_VEGVESEN_TOKEN=your-token-from-staging" >> .env

# Restart
docker compose -f docker-compose.dev.yml restart directus

# Verify
curl http://localhost:8055/vehicle-lookup/health
# Should return: {"status":"healthy","configured":true}
```

### 2. Internet Access

The vehicle-lookup endpoint calls external API:
- `https://autosys-kjoretoy-api.atlas.vegvesen.no/`
- Requires internet connection from dev environment
- May take 5-10 seconds per lookup

---

## Troubleshooting

### "I don't see vehicle-lookup-button in interface dropdown"

**Cause**: Extension not loaded or wrong Directus version

**Check**:
```bash
docker logs directapp-dev 2>&1 | grep vehicle-lookup-button
# Should show: directapp-interface-vehicle-lookup-button
```

**Fix**: Rebuild extension
```bash
cd extensions/directus-extension-vehicle-lookup-button
npm run build
docker compose -f docker-compose.dev.yml restart directus
```

### "Button appears but does nothing when clicked"

**Cause**: API token not configured

**Check**:
```bash
curl http://localhost:8055/vehicle-lookup/health
# Should return: {"status":"healthy","configured":true}
```

**Fix**: Add token to `.env` (see Prerequisites above)

### "Button returns 'Service not configured' error"

**Cause**: Same as above - no API token

**Fix**: Add `STATENS_VEGVESEN_TOKEN` to `.env` and restart

### "Fields don't auto-fill after clicking button"

**Possible causes**:
1. VIN not valid (must be 17 characters, no I/O/Q)
2. Vehicle not in Statens Vegvesen database
3. API token invalid or expired
4. External API down

**Check logs**:
```bash
docker logs directapp-dev 2>&1 | tail -20
```

---

## Summary

**To make vehicle-lookup-button visible**:
1. Add alias field to cars collection (via admin UI)
2. Choose "vehicle-lookup-button" interface
3. Configure options (lookup field, button label)
4. Save

**To make it actually work**:
1. Add `STATENS_VEGVESEN_TOKEN` to dev `.env`
2. Restart dev environment
3. Verify health endpoint shows `configured: true`

**Total time**: 2-5 minutes

---

## Why It's Not Visible By Default

**Design decision**: The vehicle-lookup-button is an **optional enhancement**.

- Core functionality works without it (API endpoints)
- Some users may prefer direct API access
- Some users may want lookup on different field (license_plate vs VIN)
- Some users may want different button placement

**Therefore**: Extension is provided but not pre-configured.

**Your choice**:
- ✅ Add button for easy UI workflow
- ✅ Use API endpoints directly
- ✅ Build custom integration

All three approaches work with the same underlying extensions.
