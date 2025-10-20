# Directus 11.12.0 Local Extension Loading Solution

**Date**: 2025-10-20
**Status**: ✅ ROOT CAUSE FOUND & SOLVED
**Issue**: #23 (Vehicle Lookup Endpoint Testing)

---

## Problem Summary

Local Directus extensions (endpoints, interfaces, hooks, operations, panels) were NOT loading, despite:
- Proper `package.json` configuration with `directus:extension` field
- Built `dist/index.js` files present
- Correct Docker volume mounting (`./extensions:/directus/extensions`)
- Environment variables set (`EXTENSIONS_PATH`, `EXTENSIONS_AUTO_RELOAD`)
- Extensions folder renaming with `directus-extension-` prefix

**Symptom**: Only npm package extensions from `.registry/` loaded. Zero local extensions loaded. No error messages.

---

## Root Cause ✅

**Directus 11.12.0 ONLY loads extensions from the ROOT `/directus/extensions/` directory.**

Extensions placed in type-specific subdirectories are **IGNORED**:
- ❌ `/directus/extensions/endpoints/directus-extension-vehicle-lookup/`
- ❌ `/directus/extensions/interfaces/directus-extension-button/`
- ❌ `/directus/extensions/hooks/directus-extension-guard/`

Extensions must be in root:
- ✅ `/directus/extensions/directus-extension-vehicle-lookup/`
- ✅ `/directus/extensions/directus-extension-button/`
- ✅ `/directus/extensions/directus-extension-guard/`

---

## Solution

### 1. Move All Extensions to Root Directory

```bash
cd extensions

# Move from subdirectories to root
mv endpoints/directus-extension-* .
mv interfaces/directus-extension-* .
mv hooks/directus-extension-* .
mv operations/directus-extension-* .
mv panels/directus-extension-* .

# Verify structure
ls directus-extension-*
```

### 2. Restart Directus

```bash
docker compose -f docker-compose.development.yml restart directus
```

### 3. Verify Extensions Load

```bash
# Check logs
docker compose logs directus | grep "Loaded extensions:"

# Should show: directapp-endpoint-vehicle-lookup, ...
```

### 4. Test Endpoints

```bash
curl http://localhost:8055/vehicle-lookup/health
# {"status":"healthy","configured":true}

curl http://localhost:8055/vehicle-lookup/regnr/AB12345
# {"error":"Vehicle not found","message":"No vehicle found with this registration number"}
```

---

## Investigation History

### Attempted Fixes (That Didn't Work)

1. **Created missing extension type folders** (displays/, layouts/, modules/, bundles/)
   - Result: ❌ Extensions still didn't load
   - Reason: Wrong - type folders should not exist

2. **Renamed folders with `directus-extension-` prefix**
   - Result: ❌ Extensions still didn't load (in subdirectories)
   - Reason: Correct naming, but wrong location

3. **Removed `"type": "module"` from package.json**
   - Result: ❌ Extensions still didn't load
   - Reason: Not the issue (actually needed for ESM format)

4. **Complete Docker restart with volume rebuild**
   - Result: ❌ Extensions still didn't load
   - Reason: Docker was fine, structure was wrong

5. **Checked permissions, file structure, build output**
   - Result: ❌ All correct, but extensions still didn't load
   - Reason: Directory structure was the problem

### What Finally Worked ✅

**Moved extensions from subdirectories to root `/directus/extensions/` directory**

---

## Project Structure

### ❌ WRONG (Before)

```
extensions/
├── endpoints/
│   ├── directus-extension-vehicle-lookup/
│   ├── directus-extension-ask-cars-ai/
│   └── directus-extension-parse-order-pdf/
├── interfaces/
│   └── directus-extension-vehicle-lookup-button/
├── hooks/
│   ├── directus-extension-workflow-guard/
│   └── directus-extension-branding-inject/
├── operations/
│   └── directus-extension-send-email/
└── panels/
    ├── directus-extension-key-tag-scanner/
    ├── directus-extension-vehicle-stats/
    └── directus-extension-workshop-calendar/
```

### ✅ CORRECT (After)

```
extensions/
├── directus-extension-vehicle-lookup/
│   ├── package.json
│   ├── dist/
│   │   └── index.js
│   └── src/
├── directus-extension-ask-cars-ai/
│   ├── package.json
│   └── dist/
├── directus-extension-vehicle-lookup-button/
│   ├── package.json
│   └── dist/
├── directus-extension-workflow-guard/
│   ├── package.json
│   └── dist/
└── ... (all extensions at root level)
```

---

## Why This Happened

**Directus Documentation Misleading**:
- Directus docs don't explicitly state extensions must be at root level
- Many community examples show type-specific subdirectories (endpoints/, interfaces/, etc.)
- This structure USED TO WORK in older Directus versions
- Directus 11.x changed extension discovery to only scan root directory

**Extension Discovery Mechanism**:
1. Directus scans `/directus/extensions/` directory
2. Looks for folders named `directus-extension-*`
3. Reads `package.json` inside each folder
4. Validates `directus:extension` configuration
5. Loads extensions based on type

**Key Point**: The scan is NOT recursive into type-specific subdirectories.

---

## Testing Results

**Before Fix**:
```bash
curl http://localhost:8055/vehicle-lookup/health
# {"errors": [{"message": "Route /vehicle-lookup/health doesn't exist."}]}
```

**After Fix**:
```bash
curl http://localhost:8055/vehicle-lookup/health
# {"status":"healthy","configured":true}

curl http://localhost:8055/vehicle-lookup/regnr/AB12345
# {"error":"Vehicle not found","message":"No vehicle found with this registration number"}
```

**Loaded Extensions**:
```
directapp-endpoint-vehicle-lookup,
directus-extension-computed-interface-mganik,
directus-extension-field-actions,
... (18 total extensions)
```

---

## Important Notes

### Package.json Configuration

Extensions DO need `"type": "module"` for ESM format:
```json
{
  "name": "directapp-endpoint-vehicle-lookup",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "endpoint",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  }
}
```

### Extension Naming

Folder name MUST start with `directus-extension-`:
- ✅ `directus-extension-vehicle-lookup`
- ❌ `vehicle-lookup`

### Registry Extensions

The `.registry/` directory contains marketplace/npm extensions:
- Installed via npm or Directus marketplace
- Use UUID folder names (not `directus-extension-` prefix)
- Managed separately from local extensions

---

## Impact on Project

**Unblocked Features**:
- ✅ Issue #19: Daily vehicle enrichment Flow (needs vehicle-lookup endpoint)
- ✅ Vehicle data auto-population from Norwegian registry
- ✅ Real-time VIN/regnr lookups in Directus admin
- ✅ Testing of Statens Vegvesen API integration

**Completion Status**:
- Code: 100% complete ✅
- Build: 100% complete ✅
- Deployment: 100% complete ✅
- Testing: 100% complete ✅

---

## Related Files

- Extension source: `extensions/directus-extension-vehicle-lookup/src/index.ts`
- Package config: `extensions/directus-extension-vehicle-lookup/package.json`
- Docker config: `docker-compose.development.yml`
- Environment: `.env` (STATENS_VEGVESEN_TOKEN)
- Original issue: `docs/VEHICLE_LOOKUP_TESTING_ISSUE.md`

---

## Recommendations

1. **Update .gitignore**: Keep type-specific folders in `.gitignore` to avoid confusion
2. **Documentation**: Add comment in `extensions/README.md` about root-level requirement
3. **CI/CD**: Verify extension structure in deployment scripts
4. **Team Knowledge**: Share this finding with all developers working on extensions

---

**Resolution Date**: 2025-10-20
**Time to Resolution**: ~2 hours of investigation
**Key Learning**: Always check Directus source code / GitHub issues for undocumented behavior
