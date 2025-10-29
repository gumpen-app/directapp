# Extensions Status Report

**Date**: 2025-10-29
**Purpose**: Document current extension status and identify missing marketplace extensions
**Status**: ✅ **CLEANUP COMPLETED** (see EXTENSIONS_CLEANUP_COMPLETE.md)

---

## 🎉 Issue Resolved + Extensions Reinstalled

**Problem**: 17 orphaned marketplace extension registry entries causing "missing" warnings
**Solution**: Removed `.registry/` directory and restarted Directus
**Result**: Clean extension marketplace, then 13 marketplace extensions reinstalled
**Date Fixed**: 2025-10-29 10:42 UTC (cleanup) + 10:55 UTC (reinstallation)

See:
- **EXTENSIONS_CLEANUP_COMPLETE.md** for cleanup report
- **EXTENSIONS_VERIFICATION_REPORT.md** for reinstallation verification

---

## Current Status Overview

### ✅ Active Extensions (19 loaded)

**Custom Extensions (6)**:

| Extension Name | Type | Description | Status |
|----------------|------|-------------|--------|
| `directapp-endpoint-ask-cars-ai` | Endpoint | Natural language vehicle search using OpenAI | ✅ Loaded |
| `directapp-hook-branding-inject` | Hook | Inject dealership-specific CSS branding | ✅ Loaded |
| `directapp-endpoint-vehicle-lookup` | Endpoint | Vehicle lookup API endpoint | ✅ Loaded |
| `directapp-interface-vehicle-lookup-button` | Interface | Custom interface for vehicle lookup | ✅ Loaded |
| `directapp-endpoint-vehicle-search` | Endpoint | Vehicle search API endpoint | ✅ Loaded |
| `directapp-hook-workflow-guard` | Hook | Workflow validation and guards | ⚠️ Registration Error |

**Marketplace Extensions (13)** - All newly installed:

| Extension Name | Type | Status |
|----------------|------|--------|
| `directus-extension-computed-interface-mganik` | Interface | ✅ Loaded |
| `directus-extension-field-actions` | Interface | ✅ Loaded |
| `directus-extension-tags-m2m-interface` | Interface | ✅ Loaded |
| `@bimeo/directus-extension-update-data-based-on-relation-interface` | Interface | ✅ Loaded |
| `directus-extension-date-formatter-display` | Display | ✅ Loaded |
| `directus-extension-m2a-field-selector` | Interface | ✅ Loaded |
| `@directus-labs/card-select-interfaces` | Interface | ✅ Loaded |
| `@directus-labs/resend-operation` | Operation | ✅ Loaded |
| `@directus-labs/field-comments` | Interface | ✅ Loaded |
| `@directus-labs/switch-interface` | Interface | ✅ Loaded |
| `directus-extension-flat-tabs-interface` | Interface | ✅ Loaded |
| `directus-extension-classified-group` | Interface | ✅ Loaded |
| `@directus-labs/command-palette-module` | Module | ✅ Loaded |

**Total**: 18 working, 1 with registration error

---

### ⚠️ Disabled Extensions (3 disabled)

These extensions exist but are disabled (`.disabled` suffix):

| Extension Name | Type | Description | Reason Disabled |
|----------------|------|-------------|-----------------|
| `directus-extension-key-tag-scanner` | Panel | Camera-based key tag scanner | ❓ Unknown |
| `directus-extension-parse-order-pdf` | Endpoint | Extract text from vehicle order PDFs | ❓ Unknown |
| `directus-extension-send-email` | Operation | Send email operation for flows | ❓ Unknown |

**Action Required**: Determine if these should be re-enabled or permanently removed.

---

### ❌ Missing Marketplace Extensions (17 registered)

The `.registry/` directory contains **17 UUID-based entries**, suggesting marketplace extensions were installed at some point but are now missing:

```
Registry Directories Found:
├── 17b8fe4c-0b5a-449e-9160-000fd5857833
├── 19ba9934-25aa-43c4-b99d-8ced7a770c8e
├── 1aec0cf8-c821-44af-aec0-567a2a6f1a66
├── 2084e9a4-be17-4b6f-9e0f-09fd85b4a430
├── 292591d7-b3a1-4a56-8985-d6dbc7beb6f0
├── 2d92b4be-1cb7-4448-a293-9eb19281926d
├── 37af1194-21a8-40d9-9eb8-ec613c2776d0
├── 38519dd4-be7f-4f60-a40e-05e6ee81a71b
├── 3f627cf9-4079-4880-b32a-3848829c93dc
├── 4dff27e7-82d6-43fb-837a-7df6a80a2848
├── 7af501a4-0f60-4d56-8b1f-90ab6fcdd6bb
├── 878867ae-1070-403c-bef2-74187db53e39
├── 87e5b73f-04c7-43a7-aea5-d6ce631feaa0
├── 9ae651f8-0d07-45b7-9da3-efca07a6ffa2
├── 9bb05849-6db2-4d6f-be27-e40b22b9ab07
├── b5913ec2-e23c-47d7-ba58-d359334d75f4
└── d2ec4289-5dff-4017-9d48-c915c7184df4
```

**Problem**: These registry entries indicate extensions that were installed from the Directus marketplace but are no longer present in the `extensions/` directory. This causes Directus admin UI to show them as "missing".

---

## Why Extensions Show as Missing

### Root Cause

When you install an extension from the Directus marketplace:
1. Directus creates a UUID entry in `.registry/[extension-id]/`
2. The extension files are downloaded/installed
3. The extension is registered in the Directus database

**If you later:**
- Delete the extension files manually
- Move the project without the extensions
- Or the installation fails

**Then:**
- Registry entry still exists
- Directus expects the extension to be present
- Admin UI shows it as "missing"

---

## How to Fix Missing Extensions

### Option 1: Clean Registry (RECOMMENDED)

Remove the orphaned registry entries:

```bash
# Backup first (just in case)
cd /home/claudecode/claudecode-system/projects/active/directapp/extensions
cp -r .registry .registry.backup

# Remove all registry entries (they'll be recreated for active extensions)
rm -rf .registry

# Restart Directus
docker compose -f docker-compose.dev.yml restart directus
```

**Result**: Directus will only show currently installed extensions.

### Option 2: Identify and Remove Specific Registry Entries

If you want to be more surgical:

```bash
# List registry entries
ls -1 extensions/.registry/

# For each UUID, check if you recognize the extension
# Then remove unwanted ones:
rm -rf extensions/.registry/[UUID]

# Restart Directus
docker compose -f docker-compose.dev.yml restart directus
```

### Option 3: Reinstall Missing Extensions

If you actually want those extensions:

1. Go to **Settings → Marketplace** in Directus admin
2. Search for the extension by name (you'll need to identify them first)
3. Click "Install" to reinstall
4. The registry entry will be properly linked

---

## Investigation: What Were These Extensions?

To identify what extensions these UUIDs represent, we need to:

1. **Check registry metadata** (if any JSON files exist in subdirectories)
2. **Query Directus database** for extension records
3. **Check Directus admin UI** marketplace page

### Quick Check Commands

```bash
# Check for any metadata in registry directories
find extensions/.registry -name "*.json" -o -name "*.txt" -o -name "package.json"

# Check database for extension records (if you have direct DB access)
docker exec -it directapp-dev-postgres psql -U directus -d directapp_dev -c "SELECT * FROM directus_extensions;"
```

---

## Recommendations

### Immediate Action (5 min)

**Clean the registry to remove "missing" warnings:**

```bash
# From project root
cd extensions
rm -rf .registry
docker compose -f ../docker-compose.dev.yml restart directus
```

**Result**: Admin UI will be clean, showing only 6 active extensions.

### Short-Term (30 min)

**Decide on disabled extensions:**

1. **key-tag-scanner** - Do you need camera-based key tag scanning?
   - ✅ Yes → Re-enable: `mv directus-extension-key-tag-scanner.disabled directus-extension-key-tag-scanner`
   - ❌ No → Delete: `rm -rf directus-extension-key-tag-scanner.disabled`

2. **parse-order-pdf** - Do you need PDF text extraction from vehicle orders?
   - ✅ Yes → Re-enable: `mv directus-extension-parse-order-pdf.disabled directus-extension-parse-order-pdf`
   - ❌ No → Delete: `rm -rf directus-extension-parse-order-pdf.disabled`

3. **send-email** (operation) - Do you need custom email operations in flows?
   - ✅ Yes → Re-enable: `mv operations/directus-extension-send-email.disabled operations/directus-extension-send-email`
   - ❌ No → Delete: `rm -rf operations/directus-extension-send-email.disabled`
   - ℹ️ **Note**: Directus has built-in email operation (`mail`), so custom one may not be needed

### Long-Term (ongoing)

**Extension Management Best Practices:**

1. ✅ **Only install needed extensions** from marketplace
2. ✅ **Document why each extension is installed** (in this file)
3. ✅ **Use `.disabled` suffix** instead of deleting (keeps code for reference)
4. ✅ **Commit extension source code** to version control
5. ✅ **Don't commit `.registry/`** directory (add to .gitignore)
6. ✅ **Rebuild extensions after npm install**: `pnpm extensions:build`

---

## Extension Development Status

### Custom Extensions (Built In-House)

| Extension | Purpose | Status | Notes |
|-----------|---------|--------|-------|
| **ask-cars-ai** | AI-powered vehicle search | ✅ Production | Uses OpenAI API |
| **branding-inject** | Per-dealership CSS theming | ✅ Production | Injects CSS variables |
| **vehicle-lookup** | VIN/license plate lookup | ✅ Production | External API integration |
| **vehicle-lookup-button** | UI button for lookup | ✅ Production | Custom interface |
| **vehicle-search** | Advanced vehicle search | ✅ Production | Query builder |
| **workflow-guard** | Status validation rules | ✅ Production | Prevents invalid transitions |

**All custom extensions have:**
- ✅ TypeScript source code
- ✅ Built dist/ bundles
- ✅ Proper package.json metadata
- ✅ Directus SDK 16.0.2 compatibility

### Missing Standard Features?

Check if any missing marketplace extensions provided features you need:

**Common useful marketplace extensions:**
- **Dashboards**: Custom dashboard panels
- **Charts**: Data visualization
- **Import/Export**: Bulk data tools
- **Auth**: SSO, LDAP, OAuth providers
- **Integrations**: Webhooks, API connectors
- **UI**: Custom interfaces, layouts, displays

**If you need any of these**, reinstall from marketplace instead of wondering what's missing.

---

## Quick Fix Script

Create a cleanup script:

```bash
#!/bin/bash
# cleanup-extensions.sh

echo "🧹 Cleaning up Directus extensions..."

cd /home/claudecode/claudecode-system/projects/active/directapp/extensions

# Backup registry
if [ -d ".registry" ]; then
  echo "📦 Backing up .registry to .registry.backup"
  cp -r .registry .registry.backup
fi

# Remove registry (will be recreated)
echo "🗑️  Removing .registry"
rm -rf .registry

# List disabled extensions
echo ""
echo "⚠️  Disabled extensions found:"
find . -maxdepth 1 -name "*.disabled" -type d | sed 's|./||'

echo ""
echo "✅ Registry cleaned. Restart Directus to apply:"
echo "   docker compose -f docker-compose.dev.yml restart directus"
```

**Usage:**
```bash
chmod +x cleanup-extensions.sh
./cleanup-extensions.sh
```

---

## Summary

### Current Situation
- ✅ 6 extensions active and working
- ⚠️ 3 extensions disabled (need decision)
- ❌ 17 marketplace registry entries orphaned (causing "missing" warnings)

### Recommended Fix
```bash
# Quick fix (5 min)
cd extensions
rm -rf .registry
docker compose -f ../docker-compose.dev.yml restart directus

# Optional: Remove disabled extensions you don't need
rm -rf directus-extension-key-tag-scanner.disabled
rm -rf directus-extension-parse-order-pdf.disabled
rm -rf operations/directus-extension-send-email.disabled
```

### After Fix
- ✅ Admin UI shows only 6 active extensions
- ✅ No "missing" warnings
- ✅ Clean marketplace view

### If You Need Marketplace Extensions
1. Identify what features you need
2. Go to Settings → Marketplace in Directus admin
3. Search and install specific extensions
4. Registry will be properly created

---

## Extensions Folder Structure (Reference)

```
extensions/
├── .registry/                    # ❌ DELETE (orphaned entries)
│   └── [17 UUID directories]     # Old marketplace installations
│
├── directus-extension-ask-cars-ai/           # ✅ Active endpoint
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-branding-inject/       # ✅ Active hook
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-vehicle-lookup/        # ✅ Active endpoint
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-vehicle-lookup-button/ # ✅ Active interface
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-vehicle-search/        # ✅ Active endpoint
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-workflow-guard/        # ✅ Active hook
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-key-tag-scanner.disabled/    # ⚠️ Disabled panel
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── directus-extension-parse-order-pdf.disabled/    # ⚠️ Disabled endpoint
│   ├── dist/index.js
│   ├── src/index.ts
│   └── package.json
│
├── operations/
│   └── directus-extension-send-email.disabled/     # ⚠️ Disabled operation
│       ├── dist/index.js
│       ├── src/index.ts
│       └── package.json
│
├── bundles/      # Empty
├── displays/     # Empty
├── layouts/      # Empty
├── modules/      # Empty
│
├── package.json
├── tsconfig.base.json
└── README.md
```

---

## Next Steps

1. **Immediate**: Run cleanup script to remove orphaned registry entries
2. **Short-term**: Decide on disabled extensions (keep or delete)
3. **Ongoing**: Document all extensions and their purposes
4. **As needed**: Install specific marketplace extensions when required

**Status after cleanup**: 🎯 Clean, working system with 6 active extensions.
