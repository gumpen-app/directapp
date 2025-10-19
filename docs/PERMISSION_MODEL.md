# Permission Model Design

**DirectApp Multi-Tenant RBAC Architecture**

This document defines the complete role-based access control (RBAC) model for DirectApp's multi-dealership workflow system.

---

## 🎯 Design Principles

1. **NO DELETE Permissions** - All deletions use soft delete (status="archived")
2. **Dealership Isolation** - All data filtered by `dealership_id`
3. **Workflow-Based Access** - Permissions follow the car workflow stages
4. **Least Privilege** - Users only see/edit what their role needs
5. **Field-Level Security** - Sensitive fields restricted per role

---

## 📊 Current System State

**Retrieved from running Directus instance:**

- **Roles:** 1 (Administrator only)
- **Policies:** 2 (Public, Administrator)
- **Permissions:** 20 system permissions only, NO custom collection permissions
- **Collections:** 8 custom collections (cars, dealership, resource_bookings, etc.)

**Critical Finding:** No business roles exist yet. System is in Phase 0 foundation.

---

## 🏗️ Architecture Overview

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Roles     │────▶│   Access     │────▶│   Policies   │
│ (Business)  │     │  (Mapping)   │     │ (Security)   │
└─────────────┘     └──────────────┘     └──────────────┘
                                                │
                                                ▼
                                         ┌──────────────┐
                                         │ Permissions  │
                                         │ (Per Policy) │
                                         └──────────────┘
```

### Why This Design?

- **Policies** define security boundaries (what can be accessed)
- **Roles** define business functions (who users are)
- **Access** links roles to policies (many-to-many)
- **Multiple roles can share the same policy** (e.g., Nybilselger + Bruktbilselger)

---

## 👥 Roles Definition

### Sales Roles

**1. Nybilselger (New Car Sales)**
- Policy: `sales_policy`
- Focus: New cars (`car_type = "nybil"`)
- Workflow: Car registration → Parts ordering → Tracking progress
- Icon: `sell`

**2. Bruktbilselger (Used Car Sales)**
- Policy: `sales_policy`
- Focus: Used cars (`car_type = "bruktbil"`)
- Workflow: Car registration → Parts ordering → Tracking progress
- Icon: `sell`

### Operations Roles

**3. Mottakskontroll (Reception Inspector)**
- Policy: `reception_policy`
- Focus: Initial inspection and approval
- Workflow: Inspect arriving cars → Approve/reject → Schedule prep
- Icon: `verified`

**4. Klargjoring (Mechanic/Detailer)**
- Policy: `mechanics_policy`
- Focus: Technical and cosmetic prep work
- Workflow: View scheduled work → Update progress → Mark complete
- Icon: `build`

**5. Booking (Workshop Planner)**
- Policy: `workshop_planner_policy`
- Focus: Resource scheduling and capacity management
- Workflow: Schedule resources → Manage bookings → Coordinate workflow
- Icon: `calendar_month`

### Management Role

**6. Daglig leder (Dealership Manager)**
- Policy: `manager_policy`
- Focus: Complete dealership overview and control
- Workflow: Monitor all operations → Manage staff → Review reports
- Icon: `admin_panel_settings`

---

## 🛡️ Policies & Permissions

### Global Rules (All Policies)

**Multi-Tenant Isolation:**
```json
{
  "dealership_id": {
    "_eq": "$CURRENT_USER.dealership_id"
  }
}
```

**NO DELETE Permissions:**
- All policies: `delete` action FORBIDDEN
- Use soft delete: Update `status` to `"archived"`, set `archived_at` timestamp

**System Collections:**
- All roles get standard Directus system permissions (presets, notifications, activity)
- User profile: Can only update own profile (NOT password/email - admin only)

---

### 1. Sales Policy (`sales_policy`)

**Target Roles:** Nybilselger, Bruktbilselger

**Collection: `cars`**

**Permissions:**

| Action | Filter | Fields | Notes |
|--------|--------|--------|-------|
| `create` | None | All except system fields | Can register new cars |
| `read` | `dealership_id = $CURRENT_USER.dealership_id` | All fields | See all dealership cars |
| `update` | `_and: [dealership_id filter, status IN ["registered", "parts_ordered_seller"]]` | `seller_notes`, `parts_notes`, `parts_ordered_seller_at`, `parts_arrived_seller_at`, `customer_*`, `sale_price` | Only cars in sales workflow stages |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `dealership`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `id = $CURRENT_USER.dealership_id` | All fields except `brand_colors` |

**Collection: `resource_bookings`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `consumer_dealership_id = $CURRENT_USER.dealership_id` | All fields |

**Collection: `notifications`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | None | All fields |
| `read` | `recipient = $CURRENT_USER` | All fields |

---

### 2. Reception Policy (`reception_policy`)

**Target Role:** Mottakskontroll

**Collection: `cars`**

| Action | Filter | Fields | Notes |
|--------|--------|--------|-------|
| `read` | `_and: [dealership_id filter, status IN ["registered", "klar_for_planlegging"]]` | All fields except pricing (`purchase_price`, `sale_price`, `prep_cost`) | See cars needing inspection |
| `update` | `_and: [dealership_id filter, status = "registered"]` | `status`, `inspection_*`, `estimated_*_hours` | Can approve/reject, estimate hours |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `dealership`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `id = $CURRENT_USER.dealership_id` | All fields except `brand_colors` |

**Collection: `resource_types`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | None | All fields |

---

### 3. Mechanics Policy (`mechanics_policy`)

**Target Role:** Klargjoring

**Collection: `cars`**

| Action | Filter | Fields | Notes |
|--------|--------|--------|-------|
| `read` | `_and: [dealership_id filter, _or: [assigned_mechanic_id = $CURRENT_USER, assigned_detailer_id = $CURRENT_USER]]` | All except pricing and customer contact | Only see assigned cars |
| `update` | `_and: [dealership_id filter, assigned user filter, status IN ["planlagt", "behandles"]]` | `technical_*`, `cosmetic_*`, `status` | Update work progress only |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `resource_bookings`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `user_id = $CURRENT_USER` | All fields |
| `update` | `_and: [user_id = $CURRENT_USER, status IN ["planned", "in_progress"]]` | `status`, `actual_hours`, `notes`, `completed_at` |

**Collection: `resource_types`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | None | All fields |

---

### 4. Workshop Planner Policy (`workshop_planner_policy`)

**Target Role:** Booking

**Collection: `cars`**

| Action | Filter | Fields | Notes |
|--------|--------|--------|-------|
| `read` | `_and: [dealership_id filter, status IN ["klar_for_planlegging", "planlagt", "behandles"]]` | All except pricing and customer contact | See cars needing scheduling |
| `update` | `_and: [dealership_id filter, status IN ["klar_for_planlegging", "planlagt"]]` | `scheduled_*_date`, `scheduled_*_time`, `assigned_mechanic_id`, `assigned_detailer_id`, `status` | Schedule work |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `resource_bookings`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | `provider_dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `read` | `_or: [provider_dealership_id = $CURRENT_USER.dealership_id, consumer_dealership_id = $CURRENT_USER.dealership_id]` | All fields |
| `update` | `provider_dealership_id = $CURRENT_USER.dealership_id` | All fields except `provider_dealership_id`, `consumer_dealership_id` |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `resource_capacities`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `read` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `update` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |

**Collection: `resource_sharing`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `_or: [provider_dealership_id = $CURRENT_USER.dealership_id, consumer_dealership_id = $CURRENT_USER.dealership_id]` | All fields |

**Collection: `resource_types`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | None | All fields |

**Collection: `dealership`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `id = $CURRENT_USER.dealership_id` | All fields |

---

### 5. Manager Policy (`manager_policy`)

**Target Role:** Daglig leder

**Collection: `cars`**

| Action | Filter | Fields | Notes |
|--------|--------|--------|-------|
| `create` | None | All fields | Can register cars |
| `read` | `dealership_id = $CURRENT_USER.dealership_id` | All fields | Full dealership view |
| `update` | `dealership_id = $CURRENT_USER.dealership_id` | All fields except `id`, `date_created`, `user_created` | Can update any field |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `dealership`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `id = $CURRENT_USER.dealership_id` | All fields |
| `update` | `id = $CURRENT_USER.dealership_id` | All fields except `id`, `dealership_number` |

**Collection: `resource_bookings`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | `provider_dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `read` | `_or: [provider_dealership_id = $CURRENT_USER.dealership_id, consumer_dealership_id = $CURRENT_USER.dealership_id]` | All fields |
| `update` | `_or: [provider_dealership_id = $CURRENT_USER.dealership_id, consumer_dealership_id = $CURRENT_USER.dealership_id]` | All fields |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `resource_capacities`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `read` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `update` | `dealership_id = $CURRENT_USER.dealership_id` | All fields |
| `delete` | ❌ FORBIDDEN | - | Use soft delete |

**Collection: `resource_sharing`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | `_or: [provider_dealership_id = $CURRENT_USER.dealership_id, consumer_dealership_id = $CURRENT_USER.dealership_id]` | All fields |

**Collection: `resource_types`**

| Action | Filter | Fields |
|--------|--------|--------|
| `read` | None | All fields |

**Collection: `notifications`**

| Action | Filter | Fields |
|--------|--------|--------|
| `create` | None | All fields |
| `read` | `_or: [recipient = $CURRENT_USER, recipient._null]` | All fields |

---

### 6. Administrator Policy (`admin_policy`)

**Existing policy with modifications:**

**Current Settings:**
- `admin_access`: true
- `app_access`: true
- `enforce_tfa`: true ✅

**Permissions:** Full access to all collections (already configured)

**Required Change:** Ensure TFA is enforced (already set to true)

---

## 🔐 User Model Extensions

**Required fields on `directus_users`:**

```json
{
  "dealership_id": {
    "type": "uuid",
    "required": true,
    "interface": "select-dropdown-m2o",
    "relation": {
      "collection": "dealership"
    }
  }
}
```

**Note:** This field must be added to `directus_users` for multi-tenant filtering to work.

---

## 📋 Implementation Checklist

### Phase 1: User Model Extension
- [ ] Add `dealership_id` field to `directus_users` collection
- [ ] Create relation: `directus_users.dealership_id` → `dealership.id`
- [ ] Set field as required with validation

### Phase 2: Create Policies
- [ ] Create `sales_policy`
- [ ] Create `reception_policy`
- [ ] Create `mechanics_policy`
- [ ] Create `workshop_planner_policy`
- [ ] Create `manager_policy`
- [ ] Verify `admin_policy` has TFA enforced

### Phase 3: Create Permissions (Per Policy)
- [ ] Sales: cars (create, read, update), dealership (read), resource_bookings (read), notifications (create, read)
- [ ] Reception: cars (read, update), dealership (read), resource_types (read)
- [ ] Mechanics: cars (read, update), resource_bookings (read, update), resource_types (read)
- [ ] Workshop Planner: cars (read, update), resource_bookings (CRUD), resource_capacities (CRUD), resource_sharing (read), resource_types (read), dealership (read)
- [ ] Manager: cars (create, read, update), dealership (read, update), all resource collections (CRUD), notifications (create, read)
- [ ] **Verify NO DELETE permissions on any policy**

### Phase 4: Create Roles
- [ ] Create `Nybilselger` role → Link to `sales_policy`
- [ ] Create `Bruktbilselger` role → Link to `sales_policy`
- [ ] Create `Mottakskontroll` role → Link to `reception_policy`
- [ ] Create `Klargjoring` role → Link to `mechanics_policy`
- [ ] Create `Booking` role → Link to `workshop_planner_policy`
- [ ] Create `Daglig leder` role → Link to `manager_policy`

### Phase 5: System Permissions (All Policies)
- [ ] Add standard Directus system permissions
- [ ] User profile update (own profile only)
- [ ] Presets, notifications, activity access
- [ ] **Block password/email updates** (admin only)

### Phase 6: Testing
- [ ] Create test users for each role
- [ ] Verify dealership isolation works
- [ ] Verify field-level restrictions work
- [ ] Verify NO DELETE operations possible
- [ ] Test cross-dealership resource sharing
- [ ] Run permission linter

### Phase 7: Documentation
- [ ] Update README.md with role descriptions
- [ ] Create user role guide
- [ ] Document soft delete pattern
- [ ] Add security policy documentation

---

## 🧪 Test Scenarios

### Multi-Tenant Isolation
```
Given: User A (Dealership 1), User B (Dealership 2)
When: User A queries cars
Then: Only cars with dealership_id = 1 returned
```

### Role-Based Field Access
```
Given: Mechanic user assigned to car X
When: Mechanic queries car X
Then: Pricing fields are NOT returned
And: Only assigned cars are visible
```

### Soft Delete Enforcement
```
Given: Any non-admin user
When: User attempts DELETE on cars
Then: Operation is FORBIDDEN
And: Must update status to "archived" instead
```

### Workflow Stage Restrictions
```
Given: Sales user, car in status "behandles"
When: Sales user tries to update car
Then: Update is FORBIDDEN (car past sales workflow)
```

---

## 🚨 Security Considerations

### Critical Security Rules

1. **NO DELETE Permissions**
   - All policies MUST NOT have `delete` action
   - Use soft delete pattern only
   - Archive field: `status = "archived"`
   - Timestamp: `archived_at`

2. **Dealership Isolation**
   - All queries MUST filter by `dealership_id`
   - User must belong to dealership (via `directus_users.dealership_id`)
   - Exception: Cross-dealership resource sharing (via provider/consumer fields)

3. **Password/Email Updates**
   - Only Administrator can update user passwords
   - Only Administrator can update user emails
   - Users can update profile fields only

4. **Two-Factor Authentication**
   - Administrator policy MUST have `enforce_tfa: true`
   - All other policies: optional (can be enabled per dealership preference)

5. **Sensitive Data Protection**
   - Pricing fields restricted (purchase_price, sale_price, prep_cost)
   - Customer contact info restricted based on role
   - Brand colors (dealership branding) admin-only

---

## 📊 Permission Matrix Summary

| Role | Cars (Create) | Cars (Read) | Cars (Update) | Cars (Delete) | Pricing View | Resource Booking |
|------|---------------|-------------|---------------|---------------|--------------|------------------|
| **Sales** | ✅ | ✅ All | ✅ Early stages | ❌ | ✅ | Read only |
| **Reception** | ❌ | ✅ Pending | ✅ Inspection | ❌ | ❌ | ❌ |
| **Mechanic** | ❌ | ✅ Assigned | ✅ Work fields | ❌ | ❌ | Update own |
| **Planner** | ❌ | ✅ Active | ✅ Schedule | ❌ | ❌ | Full CRUD |
| **Manager** | ✅ | ✅ All | ✅ All fields | ❌ | ✅ | Full CRUD |
| **Admin** | ✅ | ✅ | ✅ | ❌* | ✅ | ✅ |

*Admin can soft delete (update status to archived)

---

## 🔄 Migration from Prototype

**Current Prototype Issues** (schema-exported/roles.json):

1. ❌ Has unscoped DELETE permission on cars
2. ❌ Complex filter logic that's "weird" (user feedback)
3. ❌ Doesn't integrate with extended system (issues #20-23)

**This Design Fixes:**

1. ✅ NO DELETE permissions at all
2. ✅ Clean, simple filters based on workflow stages
3. ✅ Integrates with Phase 0 setup tasks:
   - Issue #20: Migrations support this schema
   - Issue #21: Seed data creates these roles
   - Issue #22: UI config matches these permissions
   - Issue #23: Test users for each role

---

## 📝 Next Steps

1. **Review this design** with stakeholders
2. **Implement Phase 1-4** using Directus MCP or API
3. **Export final schema** for version control
4. **Update KANBAN.md** - Mark Issue #1 complete
5. **Create PR** with this documentation

---

**Document Version:** 1.0
**Author:** Claude Code
**Date:** 2025-10-19
**Related Issues:** #1, #20, #21, #22, #23
**Related Docs:** CRITICAL_SCHEMA_FIXES.md, SOFT_DELETE_IMPLEMENTATION.md, README.md
