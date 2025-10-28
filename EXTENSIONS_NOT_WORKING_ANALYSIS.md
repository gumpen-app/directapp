# Extensions Not Working - Root Cause Analysis

**Date:** 2025-01-27
**Status:** 🔴 CRITICAL - Extensions installed but not functional
**Container Status:** UNHEALTHY

---

## Symptoms

1. ✅ Extensions show as "installed" in Directus admin UI
2. ❌ Extensions are NOT functional (no endpoints work, no UI components appear)
3. 🔴 Container status: **UNHEALTHY**
4. 🔴 Multiple extension loading errors in logs

---

## Root Causes Identified

### 1. Missing @directus/extensions-sdk at Runtime

**Error in logs:**
```
[12:59:12.447] WARN: Cannot find module '@directus/extensions-sdk'
- /directus/extensions/directus-extension-parse-order-pdf/dist/index.js
- /directus/extensions/directus-extension-vehicle-search/dist/index.js
- /directus/extensions/directus-extension-workflow-guard/dist/index.js
```

**Problem:**
- `@directus/extensions-sdk` is in `devDependencies` (correct for build time)
- BUT the built `dist/index.js` files are trying to import it at runtime
- The SDK should be compiled away during build, NOT imported at runtime

**Why this happens:**
Extensions are importing from `@directus/extensions-sdk` but the build process is NOT properly bundling/tree-shaking these imports. The SDK provides helper functions like `defineEndpoint()` that should be inlined during compilation.

---

### 2. External Dependencies Not Bundled

**Errors in logs:**
```
"@fullcalendar/vue3" is imported by "extensions/directus-extension-workshop-calendar/dist/index.js",
but could not be resolved – treating it as an external dependency.

"vue-chartjs" is imported by "extensions/directus-extension-vehicle-stats/dist/index.js",
but could not be resolved – treating it as an external dependency.

"chart.js" is imported by "extensions/directus-extension-vehicle-stats/dist/index.js",
but could not be resolved – treating it as an external dependency.
```

**Problem:**
- App extensions (panels, interfaces) are importing external libraries
- These libraries are NOT being bundled into dist/index.js
- Directus can't resolve them at runtime

**Affected extensions:**
- `directus-extension-workshop-calendar` - FullCalendar dependencies
- `directus-extension-vehicle-stats` - Chart.js dependencies

---

### 3. Container Health Check Failing

**Status:**
```bash
directapp-dev    Up 4 days (unhealthy)
```

**Likely cause:**
Extension loading errors are causing Directus to be in degraded state, failing health checks.

---

## Extension Build Configuration Issues

### Current package.json Pattern (vehicle-lookup)

```json
{
  "type": "module",
  "directus:extension": {
    "type": "endpoint",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "dependencies": {
    "axios": "^1.6.5"  // ✅ Runtime dependency
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2"  // ✅ Build-time only
  }
}
```

**This is CORRECT** - axios is a dependency, SDK is devDependency.

---

## Fix Required: Rebuild Extensions with Proper Bundling

### Option 1: Rebuild All Extensions (Recommended)

```bash
cd extensions

# Clean all dist folders
pnpm run clean

# Rebuild all extensions
pnpm run build
```

**This should:**
1. Properly bundle all external dependencies
2. Inline SDK helper functions
3. Generate CommonJS-compatible output for Directus

---

### Option 2: Fix Individual Extension Configs

Some extensions may need bundler configuration updates:

**For App Extensions with external deps:**

`extensions/directus-extension-workshop-calendar/package.json`:
```json
{
  "dependencies": {
    "@fullcalendar/vue3": "^6.1.0",
    "@fullcalendar/daygrid": "^6.1.0",
    "@fullcalendar/timegrid": "^6.1.0",
    "@fullcalendar/interaction": "^6.1.0",
    "date-fns": "^2.30.0"
  }
}
```

These should be **dependencies** (bundled), NOT **devDependencies**.

---

## Verification Steps

### 1. Check if extensions are properly built

```bash
# Should show NO imports from '@directus/extensions-sdk'
grep -r "extensions-sdk" extensions/*/dist/

# Should show bundled code, not external imports
head -50 extensions/directus-extension-vehicle-lookup/dist/index.js
```

### 2. Check container health

```bash
docker ps | grep directapp-dev
# Should show: Up X days (healthy)

docker logs directapp-dev 2>&1 | grep -i error | tail -20
# Should show NO extension loading errors
```

### 3. Test endpoint functionality

```bash
# Health check endpoint should work
curl http://localhost:8055/vehicle-lookup/health

# Should return:
# {"status":"healthy","configured":true}
```

---

## Build Process Analysis

### Expected Build Flow

```
src/index.ts
   ↓
[TypeScript Compilation]
   ↓
[Rollup Bundling]
   ↓
dist/index.js (self-contained, no external imports)
```

### Current Build Flow (BROKEN)

```
src/index.ts
   ↓
[TypeScript Compilation]
   ↓
[Rollup Bundling - INCOMPLETE]
   ↓
dist/index.js (still has external imports! ❌)
```

---

## Root Cause: Extensions SDK Build Configuration

The `@directus/extensions-sdk` CLI tool (`directus-extension build`) should:
1. ✅ Compile TypeScript to JavaScript
2. ✅ Bundle all dependencies
3. ✅ Inline SDK helper functions
4. ❌ **BUT IT'S NOT WORKING PROPERLY**

**Possible reasons:**
1. Extensions SDK version mismatch (using 16.0.2, Directus is 11.12.0)
2. Build cache from old builds
3. Incorrect bundler configuration
4. ESM/CommonJS module format mismatch

---

## Immediate Actions Required

### 1. Clean rebuild (5 minutes)

```bash
cd extensions

# Clean all build artifacts
find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null
find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null

# Fresh install
pnpm install

# Rebuild all
pnpm build

# Check for errors
echo "Extensions built. Checking for SDK imports..."
grep -r "extensions-sdk" */dist/ || echo "✅ No SDK imports in dist files"
```

### 2. Restart Directus

```bash
docker restart directapp-dev

# Wait 30 seconds
sleep 30

# Check health
docker ps | grep directapp-dev
# Should show: (healthy)

# Check logs for extension errors
docker logs directapp-dev 2>&1 | grep -i "extension" | tail -20
# Should show: "Extensions loaded" with no errors
```

### 3. Verify extensions work

```bash
# Test API endpoint
curl http://localhost:8055/vehicle-lookup/health

# Check admin UI
open http://localhost:8055/admin
# Navigate to Settings → Extensions
# All extensions should show as "enabled" AND functional
```

---

## Long-Term Fixes

### 1. Update Extensions SDK

Check if using latest compatible version:

```bash
cd extensions
pnpm list @directus/extensions-sdk
# Current: 16.0.2

# Check latest
pnpm info @directus/extensions-sdk versions

# Update if needed
pnpm add -D @directus/extensions-sdk@latest
```

### 2. Add Build Validation to CI/CD

Update `.github/workflows/directus-ci.yml`:

```yaml
- name: Validate extension builds
  working-directory: ./extensions
  run: |
    # Check no SDK imports in dist
    if grep -r "@directus/extensions-sdk" */dist/; then
      echo "❌ Extensions still importing SDK at runtime!"
      exit 1
    fi

    # Check dist files exist
    for ext in directus-extension-*; do
      if [ ! -f "$ext/dist/index.js" ]; then
        echo "❌ Missing dist/index.js in $ext"
        exit 1
      fi
    done

    echo "✅ All extensions properly built"
```

### 3. Document Build Requirements

Create `extensions/README.md`:

```markdown
# DirectApp Extensions

## Building Extensions

**IMPORTANT:** All extensions must be rebuilt after:
- Modifying source code
- Updating dependencies
- Pulling changes from git

### Build Commands

```bash
# Build all extensions
pnpm build

# Build specific extension
cd directus-extension-vehicle-lookup
pnpm build

# Watch mode (development)
pnpm dev
```

### Verification

After building, verify:
1. `dist/index.js` exists for each extension
2. No imports from `@directus/extensions-sdk` in dist files
3. All dependencies are bundled
```

---

## Files to Check/Fix

### Priority 1: Rebuild Extensions
- `extensions/*/dist/` - ALL need clean rebuild

### Priority 2: Fix Dependencies
- `extensions/directus-extension-workshop-calendar/package.json`
- `extensions/directus-extension-vehicle-stats/package.json`

### Priority 3: Add Validation
- `.github/workflows/directus-ci.yml` - Add build validation step

---

## Expected Outcome After Fix

### Container Status
```bash
$ docker ps | grep directapp-dev
directapp-dev    Up X hours (healthy)  # ✅ Was: (unhealthy)
```

### Extension Logs
```bash
$ docker logs directapp-dev 2>&1 | grep -i extension | tail -5
[INFO] Extensions loaded
[INFO] Extensions reloaded
# ✅ No errors
```

### Endpoint Test
```bash
$ curl http://localhost:8055/vehicle-lookup/health
{"status":"healthy","configured":true}
# ✅ Works!
```

### Admin UI
- All panels appear in dashboards
- Interface components render in forms
- Extensions page shows all as "enabled" AND functional

---

## Summary

**Problem:** Extensions built incorrectly, importing SDK at runtime
**Solution:** Clean rebuild with proper dependency bundling
**Time to fix:** ~10 minutes
**Impact:** 🔴 CRITICAL - All custom functionality is currently broken

Next step: Execute clean rebuild and restart container.
