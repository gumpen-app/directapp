# Critical Permissions Fixes Required

**Date:** 2025-10-29
**Status:** 🔴 CRITICAL - Manual fixes required
**Based on:** SCHEMA_ANALYSIS.md security audit

---

## ⚠️ WARNING: PRODUCTION SECURITY RISKS

Your current permission setup has **5 critical security vulnerabilities** that must be fixed before production use.

---

## Current Roles Overview

### Roles Identified
1. **Administrator** - Full admin access ✅
2. **Nybil** (New Car Sales) - No policies assigned ⚠️
3. **Bruktbil** (Used Car Sales) - No policies assigned ⚠️
4. **Klargjoring** (Preparation Work) - No policies assigned ⚠️
5. **Booking** (Workshop Planning) - Has policy 🔴
6. **Mottakskontroll.499** (Reception Check) - Dealership-specific ⚠️
7. **demo** - Demo role ⚠️

### Policies Identified
1. **Administrator** - admin_access: true, 2FA enforced ✅
2. **Nybilselger** (New Car Seller) - 2FA enforced
3. **Bruktbilselger** (Used Car Seller) - 2FA enforced
4. **Booking** (Workshop Planner) - 2FA enforced 🔴

---

## 🔴 Critical Security Issues

### Issue #1: No Dealership Data Isolation

**Current State:**
```json
{
  "collection": "cars",
  "action": "read",
  "permissions": null  // ← Users can see ALL dealerships!
}
```

**Impact:** Users at Dealership 490 can see/modify cars at Dealership 495, 499, etc.

**Fix Required:**
For ALL non-admin policies, add dealership filter:

```json
{
  "collection": "cars",
  "action": "read",
  "permissions": {
    "dealership_id": {
      "_eq": "$CURRENT_USER.dealership_id"
    }
  }
}
```

**Steps:**
1. Go to Settings → Access Control → Policies
2. For each policy (Nybilselger, Bruktbilselger, Booking)
3. Edit the `cars` collection permissions
4. Add the filter above to the "Permissions" field
5. Apply same filter to: create, update, delete actions

**Collections Affected:**
- ✅ `cars` - MUST have dealership filter
- ✅ `dealership` - Users should only see their own dealership

---

### Issue #2: Booking Role Can Delete Without Restrictions

**Current State:**
```json
{
  "collection": "cars",
  "action": "delete",
  "permissions": null,  // ← Can delete ANY car!
  "policy": "Booking"
}
```

**Impact:** Workshop planners can delete sold vehicles, causing data loss and audit trail issues.

**Fix Required:**

**Option A (Recommended): Remove DELETE permission entirely**
- Booking role should NOT be able to delete cars
- Only administrators should delete
- Use "archive" status instead

**Option B: Restrict DELETE with filters**
```json
{
  "collection": "cars",
  "action": "delete",
  "permissions": {
    "_and": [
      {
        "dealership_id": {
          "_eq": "$CURRENT_USER.dealership_id"
        }
      },
      {
        "status": {
          "_in": ["draft", "registered"]
        }
      },
      {
        "sold_at": {
          "_null": true
        }
      }
    ]
  }
}
```

**Steps:**
1. Settings → Access Control → Policies → Booking
2. Find `cars` collection DELETE permission
3. Either:
   - **Remove it entirely** (recommended)
   - Or add the filter above

---

### Issue #3: Users Can Update Their Own Passwords (Good) But...

**Current State:**
```json
{
  "collection": "directus_users",
  "action": "update",
  "permissions": {
    "id": {
      "_eq": "$CURRENT_USER.id"
    }
  },
  "fields": [
    "first_name",
    "last_name",
    "avatar"
  ]
}
```

**Status:** ✅ This is actually GOOD - users can only update their own profile
**Verification Needed:** Ensure NO policy allows updating other users' passwords

**Check For:**
```json
{
  "collection": "directus_users",
  "action": "update",
  "fields": ["password", "email", "role", ...]  // ← DANGEROUS if not restricted to own user
}
```

---

### Issue #4: Missing Validation Rules

**Current State:**
```json
{
  "collection": "cars",
  "action": "update",
  "validation": null  // ← No server-side validation!
}
```

**Impact:** Users can:
- Skip workflow steps (mark as "Delivered" without technical prep)
- Change VIN after registration
- Change dealership_id after sale

**Fix Required:**

**Add validation rules per action:**

**For UPDATE action:**
```json
{
  "collection": "cars",
  "action": "update",
  "validation": {
    "_and": [
      {
        "_or": [
          {
            "sold_at": {
              "_null": true
            }
          },
          {
            "status": {
              "_neq": "delivered"
            }
          }
        ]
      }
    ]
  }
}
```

This prevents editing sold/delivered cars.

**Better approach:** Use Directus Flows with hooks to validate state transitions.

---

### Issue #5: Overlapping and Missing Field Permissions

**Current State:**
Multiple policies have inconsistent field access:
- Some can update `status`
- Some can't update `vin`
- No clear field boundaries per role

**Fix Required:**

### Recommended Field Access Matrix

#### **Sales Roles (Nybilselger, Bruktbilselger)**

**CREATE:** Full access to new cars
```json
"fields": [
  "vin", "license_plate", "brand", "model", "model_year", "color",
  "car_type", "order_number", "customer_name", "customer_phone",
  "customer_email", "dealership_id", "seller_id", "registered_at",
  "parts_ordered_seller_at", "parts_arrived_seller_at", "seller_notes"
]
```

**READ:** All fields
```json
"fields": ["*"]
```

**UPDATE:** Limited fields (cannot change VIN, dealership after registration)
```json
"fields": [
  "customer_name", "customer_phone", "customer_email",
  "seller_notes", "parts_ordered_seller_at", "parts_arrived_seller_at"
]
```

**DELETE:** None (use archive)

---

#### **Booking Role (Workshop Planner)**

**CREATE:** None (cars come from sales)

**READ:** All fields
```json
"fields": ["*"]
```

**UPDATE:** Scheduling and assignment fields only
```json
"fields": [
  "assigned_mechanic_id", "assigned_detailer_id",
  "scheduled_technical_date", "scheduled_technical_time",
  "scheduled_cosmetic_date", "scheduled_cosmetic_time",
  "status"  // Can change workflow status
]
```

**DELETE:** None

---

#### **Klargjoring Role (Prep Workers)**

**CREATE:** None

**READ:** All fields
```json
"fields": ["*"]
```

**UPDATE:** Work completion and notes only
```json
"fields": [
  "technical_started_at", "technical_completed_at", "technical_notes",
  "cosmetic_started_at", "cosmetic_completed_at", "cosmetic_notes",
  "inspection_completed_at", "inspection_approved", "inspection_notes",
  "status",  // Can update workflow status
  "ready_for_delivery_at"
]
```

**DELETE:** None

---

#### **Mottakskontroll Role (Reception Check)**

**CREATE:** None

**READ:** Limited fields (inspection-relevant only)
```json
"fields": [
  "vin", "license_plate", "brand", "model", "model_year",
  "arrived_prep_center_at", "inspection_approved", "inspection_notes"
]
```

**UPDATE:** Inspection fields only
```json
"fields": [
  "inspection_completed_at", "inspection_approved", "inspection_notes"
]
```

**DELETE:** None

---

## 🔧 Implementation Steps

### Phase 1: Dealership Isolation (CRITICAL - Do First)

1. **Add dealership_id to directus_users table**
   ```sql
   ALTER TABLE directus_users ADD COLUMN dealership_id UUID REFERENCES dealership(id);
   ```

2. **Assign users to their dealerships**
   - Update each user with their dealership_id

3. **Update ALL non-admin policies**
   - Add `dealership_id` filter to cars.read, cars.create, cars.update
   - Add `id._eq.$CURRENT_USER.dealership_id` filter to dealership.read

### Phase 2: Remove Dangerous Permissions

1. **Booking Policy → Remove DELETE permission for cars**
2. **All Policies → Verify no password/email update for other users**
3. **All Policies → Verify no role field update**

### Phase 3: Field-Level Permissions

1. **Nybilselger Policy:**
   - CREATE: Full new car fields
   - UPDATE: Customer fields + seller notes only
   - DELETE: None

2. **Bruktbilselger Policy:**
   - CREATE: Full used car fields
   - UPDATE: Customer fields + seller notes only
   - DELETE: None

3. **Booking Policy:**
   - CREATE: None
   - UPDATE: Scheduling + assignment only
   - DELETE: None

4. **Klargjoring Policy:**
   - CREATE: None
   - UPDATE: Work completion + notes only
   - DELETE: None

### Phase 4: Validation Rules

**Option A: Add validation to permissions (limited)**
```json
{
  "collection": "cars",
  "action": "update",
  "validation": {
    "_and": [
      {"sold_at": {"_null": true}},
      {"status": {"_neq": "delivered"}}
    ]
  }
}
```

**Option B: Create Directus Flow with hooks (recommended)**
Create flow with:
- Trigger: `event` (filter type)
- Scope: `items.update` on `cars`
- Operation: Validate state transitions with conditions

---

## 🧪 Testing Checklist

After applying fixes:

### Test Dealership Isolation
- [ ] User at Dealership 490 cannot see cars from Dealership 495
- [ ] User at Dealership 490 cannot create car with dealership_id=495
- [ ] User at Dealership 490 cannot update car from Dealership 495

### Test Delete Restrictions
- [ ] Booking user cannot delete cars
- [ ] Admin can delete cars (if needed)
- [ ] Users use "archived" status instead of delete

### Test Field Permissions
- [ ] Sales cannot change VIN after creation
- [ ] Sales cannot change dealership_id
- [ ] Booking cannot update customer info
- [ ] Prep workers cannot update sale price

### Test Password Security
- [ ] Users can only update their OWN profile
- [ ] Users cannot change other users' passwords
- [ ] Users cannot change other users' roles

---

## 📊 Permission Matrix Summary

| Role | Create Cars | Read Cars | Update Cars | Delete Cars | Fields Editable |
|------|-------------|-----------|-------------|-------------|-----------------|
| **Admin** | ✅ All | ✅ All | ✅ All | ✅ Yes | All fields |
| **Nybilselger** | ✅ Yes | ✅ Own dealership | ⚠️ Limited | ❌ No | Customer, seller notes |
| **Bruktbilselger** | ✅ Yes | ✅ Own dealership | ⚠️ Limited | ❌ No | Customer, seller notes |
| **Booking** | ❌ No | ✅ Own dealership | ⚠️ Limited | ❌ No | Scheduling, assignments |
| **Klargjoring** | ❌ No | ✅ Own dealership | ⚠️ Limited | ❌ No | Work completion, notes |
| **Mottakskontroll** | ❌ No | ⚠️ Limited | ⚠️ Inspection only | ❌ No | Inspection fields only |

---

## 🚨 Before Production Checklist

- [ ] All policies have dealership_id filter on cars collection
- [ ] No policy allows DELETE on cars (except Admin)
- [ ] No policy allows password update for other users
- [ ] Field permissions match role responsibilities
- [ ] Each role tested with real user accounts
- [ ] Audit logging enabled (`accountability: "all"` on collections)
- [ ] 2FA enforced for all non-admin roles
- [ ] Users assigned to correct dealerships
- [ ] Test user cannot see other dealership data
- [ ] Validation rules prevent invalid state transitions

---

## Next Steps

1. **Immediate:** Add dealership_id to users table + assign users
2. **Immediate:** Add dealership filters to all car permissions
3. **Immediate:** Remove Booking DELETE permission
4. **High Priority:** Implement field-level restrictions
5. **Medium Priority:** Add workflow validation hooks
6. **Low Priority:** Consider row-level security in PostgreSQL

---

## Additional Security Recommendations

### Database-Level Constraints
```sql
-- Prevent VIN updates after initial creation
CREATE TRIGGER prevent_vin_update
BEFORE UPDATE ON cars
FOR EACH ROW
WHEN (OLD.vin IS NOT NULL AND NEW.vin != OLD.vin)
EXECUTE FUNCTION raise_exception('Cannot change VIN after creation');

-- Prevent dealership changes after sale
CREATE TRIGGER prevent_dealership_change_after_sale
BEFORE UPDATE ON cars
FOR EACH ROW
WHEN (OLD.sold_at IS NOT NULL AND NEW.dealership_id != OLD.dealership_id)
EXECUTE FUNCTION raise_exception('Cannot change dealership after sale');
```

### Directus Flow Hooks
Create flows for:
1. **VIN Validation** - Validate format on create/update
2. **Status Transition Validation** - Ensure proper workflow progression
3. **Audit Logging** - Log all critical field changes
4. **Notification Triggers** - Notify on status changes

---

**Status:** 📝 Documentation complete, manual implementation required
**Priority:** 🔴 CRITICAL - Fix before production
**Estimated Time:** 2-4 hours for proper implementation
