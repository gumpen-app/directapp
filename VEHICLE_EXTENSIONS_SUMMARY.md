# Vehicle Extensions - Quick Reference

**Date**: 2025-10-29

---

## TL;DR

You have **3 related extensions** for vehicle management:

| Extension | What | When | Status |
|-----------|------|------|--------|
| **vehicle-lookup** | Fetch from government API | New vehicle registration | ✅ Loaded, needs API token |
| **vehicle-search** | Search your database | Find existing vehicles | ✅ Working |
| **vehicle-lookup-button** | UI for vehicle-lookup | Form auto-fill | ✅ Loaded, needs config |

---

## The Difference (Simple Version)

### vehicle-lookup = "Get data from outside"
**Source**: Norwegian government (Statens Vegvesen)
**Use**: When you don't have vehicle data yet
**Example**: User enters VIN → Get brand, model, year, color

### vehicle-search = "Find data inside"
**Source**: Your Directus database
**Use**: When you need to find existing vehicles
**Example**: Search "toyota" → Show all Toyotas you own

### vehicle-lookup-button = "UI button for vehicle-lookup"
**Source**: Same as vehicle-lookup
**Use**: Makes vehicle-lookup easy to use in forms
**Example**: Click button → Auto-fill fields

---

## Real-World Scenarios

### Scenario 1: New Car Arrives at Dealership

**Problem**: Seller needs to register new vehicle
**Solution**: Use **vehicle-lookup** + **vehicle-lookup-button**

**Workflow**:
1. Seller opens Cars → Create New
2. Enters VIN: `WVWZZZ1KZBW123456`
3. Clicks "Fetch Vehicle Data" button
4. System calls government API
5. Brand, model, year, color auto-fill
6. Seller adds customer info
7. Saves

**Time saved**: 2-3 minutes per vehicle

---

### Scenario 2: Mechanic Needs Cars for Today

**Problem**: Mechanic wants list of cars needing technical work
**Solution**: Use **vehicle-search**

**Workflow**:
1. Mechanic opens dashboard
2. Searches: `status=technical_prep`
3. Gets list of all cars ready for work
4. Starts working on first car

**Alternative**: Create custom panel that uses vehicle-search API

---

### Scenario 3: Customer Service Lookup

**Problem**: Customer calls asking about their car
**Solution**: Use **vehicle-search**

**Workflow**:
1. Rep searches by customer name or license plate
2. Finds vehicle in database
3. Shows current status
4. Provides ETA for delivery

---

## How They Work Together

```
New Vehicle Registration Flow:
┌─────────────────────────────────────────────────┐
│ 1. User enters VIN                              │
├─────────────────────────────────────────────────┤
│ 2. Clicks "Fetch Vehicle Data" button          │
│    (vehicle-lookup-button interface)            │
├─────────────────────────────────────────────────┤
│ 3. Button calls /vehicle-lookup/vin/{vin}      │
│    (vehicle-lookup endpoint)                    │
├─────────────────────────────────────────────────┤
│ 4. Endpoint calls Statens Vegvesen API         │
├─────────────────────────────────────────────────┤
│ 5. API returns: brand, model, year, color      │
├─────────────────────────────────────────────────┤
│ 6. Fields auto-populate in form                │
├─────────────────────────────────────────────────┤
│ 7. User completes & saves                      │
├─────────────────────────────────────────────────┤
│ 8. Now searchable via vehicle-search           │
└─────────────────────────────────────────────────┘
```

---

## Current Status

### ✅ vehicle-search
- **Status**: Fully working
- **Configuration**: None needed
- **Usage**: Already available at `/vehicle-search`
- **Test**: `curl http://localhost:8055/vehicle-search?query=toyota`

### ⚠️ vehicle-lookup
- **Status**: Loaded but not configured
- **Missing**: `STATENS_VEGVESEN_API_TOKEN` environment variable
- **Setup**: Add token to `.env`, restart Directus
- **Test**: `curl http://localhost:8055/vehicle-lookup/health`

### ⚠️ vehicle-lookup-button
- **Status**: Extension loaded but not added to collection
- **Missing**: Alias field in cars collection
- **Setup**: Add field via Settings → Data Model → cars
- **Test**: Open any car in Directus admin, look for button

---

## Quick Setup (2 Minutes)

### 1. Configure vehicle-lookup API
```bash
# Copy token from staging (staging already has it!)
echo "STATENS_VEGVESEN_TOKEN=token-from-staging" >> .env
docker compose -f docker-compose.dev.yml restart directus

# Verify it works
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health
# Expected: {"status":"healthy","configured":true}
```

**See `VEHICLE_EXTENSIONS_DEV_SETUP.md` for where to get the staging token.**

### 2. Add lookup button to form
```bash
# Via Directus admin:
Settings → Data Model → cars → Create Field
- Type: Alias
- Name: vehicle_lookup_action
- Interface: vehicle-lookup-button
- Options: (see VEHICLE_LOOKUP_BUTTON_SETUP.md)
```

### 3. Test
```bash
# Create new car, enter VIN, click "Fetch Vehicle Data"
```

---

## When to Use Each

| Need | Extension | Endpoint |
|------|-----------|----------|
| Auto-fill new vehicle data | vehicle-lookup | `/vehicle-lookup/vin/:vin` |
| Find cars by customer name | vehicle-search | `/vehicle-search?customer_name=John` |
| Find cars needing work | vehicle-search | `/vehicle-search?status=technical_prep` |
| Get vehicle statistics | vehicle-search | `/vehicle-search/stats` |
| Check if VIN exists | vehicle-search | `/vehicle-search?vin=WVWZZZ1K...` |
| Validate license plate | vehicle-lookup | `/vehicle-lookup/regnr/:regnr` |

---

## API Quick Reference

### vehicle-lookup Endpoints

```bash
# Health check
GET /vehicle-lookup/health

# Lookup by VIN
GET /vehicle-lookup/vin/WVWZZZ1KZBW123456

# Lookup by license plate
GET /vehicle-lookup/regnr/AB12345
```

### vehicle-search Endpoints

```bash
# Multi-field search
GET /vehicle-search?query=toyota&limit=10

# Search by VIN
GET /vehicle-search?vin=WVWZZZ1KZBW123456

# Search by status
GET /vehicle-search?status=technical_prep

# Get single car
GET /vehicle-search/:id

# Get statistics
GET /vehicle-search/stats
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| `VEHICLE_EXTENSIONS_INTEGRATION_GUIDE.md` | Complete guide (all features, examples) |
| `VEHICLE_LOOKUP_BUTTON_SETUP.md` | UI setup instructions |
| `VEHICLE_EXTENSIONS_SUMMARY.md` | This quick reference |
| `EXTENSIONS_VERIFICATION_REPORT.md` | All extensions status |
| `CUSTOM_EXTENSIONS_REVIEW.md` | Code quality analysis |

---

## Common Questions

**Q: Why do I need both vehicle-lookup AND vehicle-search?**
A: Different purposes. vehicle-lookup gets new data from government. vehicle-search finds existing data in your database.

**Q: Do I need vehicle-lookup-button?**
A: No, but it makes vehicle-lookup much easier to use. Without it, users would need to call API manually.

**Q: Can I use vehicle-search without vehicle-lookup?**
A: Yes! vehicle-search works independently. It searches your existing cars.

**Q: Can I use vehicle-lookup without vehicle-search?**
A: Yes! But you'd need to search cars manually in Directus.

**Q: How much does Statens Vegvesen API cost?**
A: Check their website. Some tiers are free for low volume.

**Q: What if API is down?**
A: Users enter data manually. vehicle-search still works (it's local).

**Q: Can I lookup vehicles from other countries?**
A: No, Statens Vegvesen is Norway-only. Would need different API.

---

## Next Steps

1. **Try vehicle-search now** (no setup needed):
   ```bash
   curl http://localhost:8055/directapp-endpoint-vehicle-search/stats
   ```

2. **Configure vehicle-lookup** (2 min):
   - Copy `STATENS_VEGVESEN_TOKEN` from staging
   - Add to dev `.env`
   - Restart Directus
   - See `VEHICLE_EXTENSIONS_DEV_SETUP.md`

3. **Add lookup button to form** (5 min):
   - Follow `VEHICLE_LOOKUP_BUTTON_SETUP.md`

4. **Train users** on new workflow

5. **Fix workflow-guard** (see `WORKFLOW_GUARD_FIX.md`)

---

## Summary Table

| Feature | vehicle-lookup | vehicle-search | vehicle-lookup-button |
|---------|---------------|----------------|----------------------|
| **Type** | Endpoint | Endpoint | Interface |
| **Purpose** | Get external data | Search internal data | UI for lookup |
| **Data Source** | Government API | Directus DB | Uses vehicle-lookup |
| **Setup Time** | 5 min | 0 min | 5 min |
| **Requires Token** | ✅ Yes | ❌ No | ✅ Yes (uses lookup) |
| **Working Now** | ⚠️ Needs token | ✅ Yes | ⚠️ Needs field added |
| **User Visible** | ❌ API only | ❌ API only | ✅ Yes (button) |

---

**Ready to activate?** Start with vehicle-search (works now), then add vehicle-lookup for auto-fill.
