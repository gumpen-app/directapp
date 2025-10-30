# Workflow Guard Extension - Quick Fix Guide

**Issue**: Extension fails to register due to incorrect exception import
**Impact**: Workflow validation rules not enforced
**Fix Time**: 5 minutes
**Difficulty**: Easy

---

## The Problem

The extension tries to destructure exceptions from the hook context, but this is no longer supported in Directus SDK 16.x:

```typescript
// ❌ Line 35-36: INCORRECT (doesn't work in SDK 16.x)
export default defineHook(({ filter, action }, { services, logger, exceptions }) => {
  const { ForbiddenException, InvalidPayloadException } = exceptions;
```

**Error in logs**:
```
[10:55:05.506] WARN: Couldn't register hook "directapp-hook-workflow-guard"
[10:55:05.509] WARN: Cannot destructure property 'ForbiddenException' of 'i' as it is undefined.
```

---

## The Solution

Import exceptions directly from the Directus SDK instead of trying to get them from context.

### Option 1: Import from @directus/errors (Recommended)

```typescript
// At the top of src/index.ts (after line 1)
import { defineHook } from '@directus/extensions-sdk';
import { ForbiddenException, InvalidPayloadException } from '@directus/errors';  // ✅ ADD THIS
import {
  NYBIL_WORKFLOW,
  // ... rest of imports
```

Then modify line 35-36 to remove the exceptions destructuring:

```typescript
// ✅ CORRECT
export default defineHook(({ filter, action }, { services, logger }) => {
  // No need to destructure - already imported above
```

### Option 2: Import from SDK (Alternative)

```typescript
import {
  defineHook,
  ForbiddenException,
  InvalidPayloadException
} from '@directus/extensions-sdk';
```

---

## Step-by-Step Fix

### 1. Edit the Source File

```bash
# Navigate to extension directory
cd /home/claudecode/claudecode-system/projects/active/directapp/extensions/directus-extension-workflow-guard
```

Open `src/index.ts` and make these changes:

**Change 1: Add import at top (after line 1)**
```typescript
import { defineHook } from '@directus/extensions-sdk';
import { ForbiddenException, InvalidPayloadException } from '@directus/errors';  // ✅ ADD THIS LINE
```

**Change 2: Remove exceptions from context (line 35)**
```typescript
// ❌ OLD (line 35)
export default defineHook(({ filter, action }, { services, logger, exceptions }) => {
  const { ForbiddenException, InvalidPayloadException } = exceptions;

// ✅ NEW (line 35)
export default defineHook(({ filter, action }, { services, logger }) => {
  // ForbiddenException and InvalidPayloadException already imported above
```

### 2. Install Dependencies (if needed)

```bash
# Check if @directus/errors is installed
npm list @directus/errors

# If not installed, add it:
npm install @directus/errors --save

# Or if using the SDK import (Option 2), no additional install needed
```

### 3. Rebuild the Extension

```bash
# Clean previous build
npm run clean

# Rebuild
npm run build

# Verify dist/index.js was created
ls -la dist/
```

### 4. Restart Directus

```bash
# Navigate back to project root
cd ../../..

# Restart Directus to load the fixed extension
docker compose -f docker-compose.dev.yml restart directus
```

### 5. Verify the Fix

```bash
# Wait 15 seconds for startup, then check logs
sleep 15 && docker logs directapp-dev 2>&1 | grep -A 3 "Loaded extensions" | tail -6
```

**Expected output**:
```
[TIME] INFO: Loaded extensions: ..., directapp-hook-workflow-guard, ...
```

**No more error**: The "Cannot destructure property 'ForbiddenException'" error should be gone.

---

## Quick One-Liner Fix

If you prefer, here's a quick edit with sed:

```bash
cd extensions/directus-extension-workflow-guard

# Add import after line 1
sed -i '1a import { ForbiddenException, InvalidPayloadException } from '"'"'@directus/errors'"'"';' src/index.ts

# Remove exceptions from context (line 35)
sed -i 's/{ services, logger, exceptions }/{ services, logger }/g' src/index.ts

# Remove the destructuring line (line 36)
sed -i '/const { ForbiddenException, InvalidPayloadException } = exceptions;/d' src/index.ts

# Install dependencies
npm install @directus/errors --save

# Rebuild
npm run clean && npm run build

# Restart Directus
cd ../../.. && docker compose -f docker-compose.dev.yml restart directus
```

---

## Verification Checklist

After applying the fix:

- [ ] No error in logs about "Cannot destructure property 'ForbiddenException'"
- [ ] Extension appears in "Loaded extensions" log line
- [ ] Test workflow transition (try changing car status in admin)
- [ ] Verify validation works (try invalid status transition)
- [ ] Check logs for workflow transition messages

### Test Workflow Validation

1. Go to Directus admin → Cars collection
2. Open any car with status "ny_ordre"
3. Try to change status directly to "kosmetisk_ferdig" (skipping steps)
4. **Expected**: Error message "Invalid workflow transition"
5. **If no error**: Extension is still not working - check logs

---

## Troubleshooting

### Issue: "Cannot find module '@directus/errors'"

**Solution**: Install the package
```bash
npm install @directus/errors --save
```

### Issue: Extension still not loading

**Check**:
1. Syntax errors in src/index.ts:
   ```bash
   npm run type-check
   ```

2. Build errors:
   ```bash
   npm run build 2>&1 | grep -i error
   ```

3. Docker logs for other errors:
   ```bash
   docker logs directapp-dev 2>&1 | grep -i "workflow-guard"
   ```

### Issue: Build successful but extension not in logs

**Check Directus is actually restarted**:
```bash
docker ps | grep directapp-dev
# Should show "Up X seconds" (not "Up X hours")
```

**Force reload**:
```bash
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml up -d
```

---

## Alternative: Use SDK Import Only

If you don't want to add `@directus/errors` dependency:

```typescript
// Top of src/index.ts
import {
  defineHook,
  ForbiddenException,      // ✅ Import from SDK
  InvalidPayloadException  // ✅ Import from SDK
} from '@directus/extensions-sdk';

// Line 35 (remove exceptions from context)
export default defineHook(({ filter, action }, { services, logger }) => {
  // Exceptions already imported above
```

No additional `npm install` needed, just rebuild.

---

## Why This Happened

**SDK Version Change**: Directus SDK changed between versions. In older versions (< 16.x), exceptions were available in the hook context. In SDK 16.x, they must be imported directly.

**Migration Path**:
- Old way (SDK < 16): `const { ForbiddenException } = exceptions;`
- New way (SDK 16+): `import { ForbiddenException } from '@directus/errors';`

---

## After the Fix

Once fixed, the workflow-guard extension will:
- ✅ Validate all workflow state transitions
- ✅ Prevent skipping required workflow steps
- ✅ Auto-fill timestamp fields
- ✅ Enforce dealership isolation
- ✅ Prevent deletion of in-progress cars
- ✅ Create workflow notifications
- ✅ Log all transitions for audit trail

This is a **critical extension** for your multi-dealership workflow system, so fixing it is high priority.

---

## Estimated Time

- **Read this guide**: 2 minutes
- **Apply fix**: 2 minutes
- **Test**: 1 minute
- **Total**: 5 minutes

**Let's fix it!** 🚀
