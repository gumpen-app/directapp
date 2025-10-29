# Vehicle Extensions - Environment Configuration

**Date**: 2025-10-29
**Status**: ✅ Staging environment correctly configured - NO CHANGES NEEDED

---

## Environment Variable Status

### Verification Complete ✅

**Extension code uses**: `STATENS_VEGVESEN_TOKEN` (verified in source code)
**Staging config has**: `STATENS_VEGVESEN_TOKEN` (docker-compose.staging.yml line 103)

**These match perfectly!** ✅ No code changes required.

---

## Current Configuration

### Staging Environment (docker-compose.staging.yml)
```yaml
# Line 103
STATENS_VEGVESEN_TOKEN: ${STATENS_VEGVESEN_TOKEN}
```

**Status**: ✅ Variable exists in staging config
**Port**: 8056 (not 8055)
**URL**: https://staging-gapp.coms.no

### Development Environment (docker-compose.dev.yml)
```yaml
# NOT CONFIGURED - Missing environment variable
```

**Status**: ❌ Variable not configured
**Port**: 8055
**URL**: http://localhost:8055

---

## Source Code Verification

**File**: `extensions/directus-extension-vehicle-lookup/src/index.ts`

**Line 61**:
```typescript
const apiToken = env.STATENS_VEGVESEN_TOKEN;
```

**Lines 64-68** (warning message):
```typescript
if (!apiToken) {
  logger.warn('STATENS_VEGVESEN_TOKEN not configured');
  return res.status(503).json({
    error: 'Service not configured',
    message: 'STATENS_VEGVESEN_TOKEN environment variable is required',
  });
}
```

**Used in**: Lines 61, 64, 151, 154, 229

✅ **Extension already uses the correct variable name throughout the codebase.**

---

## Why This Matters

### Previous Confusion
- Documentation (VEHICLE_EXTENSIONS_INTEGRATION_GUIDE.md) mentioned `STATENS_VEGVESEN_API_TOKEN`
- This was based on assumption, not source code verification
- Led to belief that code changes were needed

### Actual Reality
- Source code verification shows extension uses `STATENS_VEGVESEN_TOKEN`
- Staging config has `STATENS_VEGVESEN_TOKEN`
- **They already match - no changes needed**

### Impact
- ✅ Staging should work immediately with existing configuration
- ✅ No extension rebuild required
- ✅ No docker-compose changes needed
- ✅ Just verify token value is set in staging environment

---

## For Development Environment

### Quick Setup (Use Staging Token)

Since staging already has all environment variables, just copy the token value:

```bash
# 1. Get token from staging (Dokploy or staging server)
# Example: STATENS_VEGVESEN_TOKEN=abc123xyz...

# 2. Add to dev .env
echo "STATENS_VEGVESEN_TOKEN=your-token-from-staging" >> .env

# 3. Restart
docker compose -f docker-compose.dev.yml restart directus

# 4. Verify
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health
# Expected: {"status":"healthy","configured":true}
```

**See `VEHICLE_EXTENSIONS_DEV_SETUP.md` for complete instructions.**

---

## Testing Instructions

### Test Staging (Should Work Now)

**Public URL**: `https://staging-gapp.coms.no` (HTTPS)

```bash
# Health check (no auth required)
curl https://staging-gapp.coms.no/directapp-endpoint-vehicle-lookup/health

# Expected: {"status":"healthy","configured":true}
```

If `configured: true`, the token is set correctly. If `false`, token is missing from staging environment.

**Authenticated Tests** (requires Directus admin token):
```bash
# Get token from staging Directus admin panel first
TOKEN="your-staging-admin-token"

# Test VIN lookup
curl -X GET "https://staging-gapp.coms.no/directapp-endpoint-vehicle-lookup/vin/WVWZZZ1KZBW123456" \
  -H "Authorization: Bearer $TOKEN"

# Test license plate lookup
curl -X GET "https://staging-gapp.coms.no/directapp-endpoint-vehicle-lookup/regnr/AB12345" \
  -H "Authorization: Bearer $TOKEN"
```

### Test Development (After Adding Token)

**Local URL**: `http://localhost:8055` (HTTP)

```bash
# 1. Add token to .env
echo "STATENS_VEGVESEN_TOKEN=your-token-here" >> .env

# 2. Restart dev environment
docker compose -f docker-compose.dev.yml restart directus

# 3. Test health check
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health

# Expected: {"status":"healthy","configured":true}

# 4. Test lookup (with auth token)
TOKEN="your-dev-admin-token"
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-lookup/vin/WVWZZZ1KZBW123456" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Summary

| Environment | Variable Name | Extension Uses | Config Has | Status |
|-------------|--------------|----------------|------------|--------|
| **Staging** | `STATENS_VEGVESEN_TOKEN` | ✅ Yes | ✅ Yes | ✅ Match - Works |
| **Development** | `STATENS_VEGVESEN_TOKEN` | ✅ Yes | ❌ Not set | ⚠️ Add to .env |
| **Production** | Unknown | ✅ Yes | ❓ Unknown | ⏳ Check config |

**Key Finding**: Extension already uses `STATENS_VEGVESEN_TOKEN` everywhere. No code changes needed.

---

## What This Means

### For Staging ✅
- Extension code uses: `STATENS_VEGVESEN_TOKEN`
- Staging config has: `STATENS_VEGVESEN_TOKEN`
- **Status**: Should work immediately (if token value is set)
- **Action**: Test health endpoint to verify

### For Development ⚠️
- Extension code uses: `STATENS_VEGVESEN_TOKEN`
- Dev environment: Variable not configured
- **Status**: Extension loaded but not configured
- **Action**: Add `STATENS_VEGVESEN_TOKEN` to `.env` file

### For Production ❓
- Extension code uses: `STATENS_VEGVESEN_TOKEN`
- Production config: Not verified
- **Status**: Unknown
- **Action**: Check `docker-compose.production.yml` for variable name

---

## Next Steps

1. ✅ Verified extension uses `STATENS_VEGVESEN_TOKEN` (source code checked)
2. ✅ Confirmed staging has `STATENS_VEGVESEN_TOKEN` (docker-compose.staging.yml)
3. ✅ Documented correct variable name
4. ⏳ **User to test**: Run staging health check
5. ⏳ **Optional**: Add token to development environment
6. ⏳ **Optional**: Check production environment config
