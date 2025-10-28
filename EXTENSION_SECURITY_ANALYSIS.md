# Extension Security Analysis: vehicle-lookup

**Date:** 2025-01-27
**Extension:** `directus-extension-vehicle-lookup`
**Reference:** [Directus Official Tutorial - Proxy External API](https://directus.io/docs/tutorials/extensions/proxy-an-external-api-in-a-custom-endpoint-extension)

---

## Critical Security Gap Identified

### ❌ Missing User Authentication

**Current State:**
The `vehicle-lookup` endpoint has **NO authentication check**. Any request can access the Statens Vegvesen API through the proxy, whether authenticated or not.

**Risk Level:** 🔴 **HIGH**

**Current Code:**
```typescript
router.get('/regnr/:regnr', async (req, res) => {
  try {
    const { regnr } = req.params;

    // ❌ NO AUTHENTICATION CHECK HERE

    if (!regnr || regnr.length < 2) {
      return res.status(400).json({ error: 'Invalid registration number' });
    }

    // Proceeds to call external API...
  }
});
```

**Official Pattern from Directus Tutorial:**
```javascript
router.get('/*', async (req, res) => {
  const { schema } = req;
  const user = req.accountability?.user;

  // ✅ AUTHENTICATION CHECK
  if (!user) {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  const { ItemsService } = services;
  const users = new ItemsService("directus_users", { schema });

  try {
    await users.readOne(user);
    // User validated - proceed with API call
  } catch {
    return res.status(403).json({ error: 'Invalid user' });
  }
});
```

---

## Security Implications

### 1. Unauthorized API Access
- Any unauthenticated request can trigger Statens Vegvesen API calls
- API rate limits could be exhausted by non-users
- API token exposure risk if proxied requests leak information

### 2. Data Privacy
- Vehicle lookup data contains sensitive information:
  - Owner type
  - Registration history
  - Inspection records
- Norwegian data protection regulations (GDPR) require access control

### 3. Audit Trail Gap
- No user tracking for vehicle lookups
- Cannot identify who performed lookups
- Compliance risk for internal audit requirements

---

## Recommended Fix

### Implementation Pattern

```typescript
router.get('/regnr/:regnr', async (req, res) => {
  try {
    const { schema, accountability } = req;
    const { ItemsService } = services;

    // ✅ Step 1: Check authentication
    const user = accountability?.user;

    if (!user) {
      logger.warn('Unauthenticated vehicle lookup attempt');
      return res.status(403).json({
        error: 'Authentication required',
        message: 'You must be logged in to use vehicle lookup'
      });
    }

    // ✅ Step 2: Validate user exists in Directus
    const usersService = new ItemsService('directus_users', {
      schema,
      accountability
    });

    try {
      const authenticatedUser = await usersService.readOne(user);
      logger.info(`Vehicle lookup by user: ${authenticatedUser.email}`);
    } catch (error) {
      logger.error(`Invalid user attempting vehicle lookup: ${user}`);
      return res.status(403).json({
        error: 'Invalid user',
        message: 'User authentication failed'
      });
    }

    // ✅ Step 3: Optional - Check user role/permissions
    // Could restrict to specific roles (e.g., only sales staff)

    const { regnr } = req.params;

    if (!regnr || regnr.length < 2) {
      return res.status(400).json({
        error: 'Invalid registration number',
      });
    }

    // Proceed with API call...
  } catch (error) {
    // Error handling...
  }
});
```

---

## Additional Best Practices from Tutorial

### 1. Schema Access
**Current:** ❌ Not using `req.schema`
**Should be:**
```typescript
const { schema, accountability } = req;
const usersService = new ItemsService('directus_users', {
  schema,  // ✅ Include schema context
  accountability
});
```

### 2. Accountability Context
**Current:** ❌ Not passing accountability to services
**Should be:**
```typescript
const usersService = new ItemsService('directus_users', {
  schema,
  accountability  // ✅ Preserves user context for permissions
});
```

### 3. Audit Logging
**Current:** ✅ Has basic logging
**Enhancement:** Include user identity in all logs
```typescript
logger.info(`Vehicle lookup: ${regnr} by user ${authenticatedUser.email} (${authenticatedUser.role})`);
```

---

## Implementation Priority

### Phase 0 (Critical - Before Pilot)
1. **Add authentication check to all routes**
   - `/regnr/:regnr`
   - `/vin/:vin`
   - `/health` (can remain public)

2. **Validate user with ItemsService**
   - Confirm user exists
   - Log user identity for audit trail

3. **Update error responses**
   - 403 for unauthenticated
   - Clear messaging for users

### Phase 1 (Security Hardening)
1. **Role-based access control**
   - Only specific roles can use vehicle lookup
   - Example: `['Nybilselger', 'Bruktbilselger', 'Mottakskontroll']`

2. **Dealership scope validation**
   - Ensure user can only lookup vehicles for their dealership
   - Cross-dealership lookups require special role

3. **Rate limiting per user**
   - Track lookups per user
   - Prevent abuse of external API

### Phase 2 (Compliance)
1. **Lookup audit log collection**
   - Create `vehicle_lookups` collection
   - Store: user, timestamp, regnr/vin, result status

2. **GDPR compliance**
   - Document data retention policy
   - Implement lookup history retention limits

---

## Testing Requirements

### Before Deployment

```bash
# Test 1: Unauthenticated request should fail
curl http://localhost:8055/vehicle-lookup/regnr/AB12345
# Expected: 403 Unauthorized

# Test 2: Authenticated request should succeed
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8055/vehicle-lookup/regnr/AB12345
# Expected: 200 with vehicle data

# Test 3: Invalid token should fail
curl -H "Authorization: Bearer invalid_token" \
  http://localhost:8055/vehicle-lookup/regnr/AB12345
# Expected: 403 Invalid user
```

---

## Files to Update

1. **extensions/directus-extension-vehicle-lookup/src/index.ts**
   - Add authentication check (both routes)
   - Add user validation with ItemsService
   - Update logging to include user identity

2. **Integration test in CI/CD**
   - `.github/workflows/directus-ci.yml` line 226-232
   - Add authenticated test case
   - Add unauthenticated test case (expect 403)

3. **Documentation**
   - Update extension README with authentication requirements
   - Document required roles for vehicle lookup access

---

## Comparison: Current vs Tutorial Pattern

| Feature | Current Implementation | Tutorial Pattern | Status |
|---------|----------------------|-----------------|--------|
| **Endpoint registration** | ✅ `defineEndpoint` | ✅ `defineEndpoint` | ✅ Correct |
| **Error handling** | ✅ Try/catch blocks | ✅ Try/catch blocks | ✅ Correct |
| **Environment variables** | ✅ `env.STATENS_VEGVESEN_TOKEN` | ✅ `env.API_TOKEN` | ✅ Correct |
| **HTTP status codes** | ✅ 400, 404, 500, 503 | ✅ Standard codes | ✅ Correct |
| **Logging** | ✅ `logger.info/warn/error` | ✅ Logging present | ✅ Correct |
| **Authentication** | ❌ **MISSING** | ✅ `req.accountability?.user` | 🔴 **CRITICAL** |
| **User validation** | ❌ **MISSING** | ✅ `ItemsService` validation | 🔴 **CRITICAL** |
| **Schema context** | ❌ Not using `req.schema` | ✅ `req.schema` | 🟡 Should add |
| **Accountability context** | ❌ Not passed to services | ✅ Passed to services | 🟡 Should add |
| **Audit trail** | 🟡 Basic logging only | ✅ User-aware logging | 🟡 Should enhance |

---

## References

1. **Directus Tutorial:** [Proxy External API in Custom Endpoint](https://directus.io/docs/tutorials/extensions/proxy-an-external-api-in-a-custom-endpoint-extension)
2. **Extensions Overview:** [Directus Extensions Guide](https://directus.io/docs/guides/extensions/overview)
3. **Current Implementation:** `extensions/directus-extension-vehicle-lookup/src/index.ts`

---

## Next Steps

1. Create GitHub issue: "Add authentication to vehicle-lookup endpoint"
2. Implement authentication check following tutorial pattern
3. Add integration tests for authenticated/unauthenticated requests
4. Update documentation with security requirements
5. Deploy to pilot with authentication enabled
