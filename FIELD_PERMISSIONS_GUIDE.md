# Field-Level Permissions & Visibility Guide

**Date**: 2025-10-29
**Purpose**: Configure role-based field visibility to show users only the fields relevant to their workflow

---

## Overview

Directus provides **multiple layers** of field visibility control:

1. ✅ **Role-Based Field Permissions** (granular read/write per field per role)
2. ✅ **Conditional Field Visibility** (show/hide based on data values)
3. ✅ **Field Groups** (organize and collapse related fields)
4. ✅ **Hidden Fields** (globally hidden from UI)
5. ✅ **Readonly Fields** (visible but not editable)

**Recommended Approach**: Combine role-based permissions + field groups + conditionals for optimal UX

---

## Method 1: Role-Based Field Permissions (RECOMMENDED)

### How It Works

Directus permissions system allows you to configure **per-field read/write access** for each role.

**Location**: Settings → Access Control → [Role] → [Collection] → Permissions

### Permission Levels

- **None** - Field completely hidden from this role
- **Read** - Field visible but readonly
- **Create** - Can set value when creating new items
- **Update** - Can edit value on existing items
- **Full** - Complete read/write access

### Example: Seller Role

**Seller should only see:**
- Vehicle identification (VIN, license plate, brand, model)
- Customer information (name, phone, email)
- Order details (order number, accessories)
- Seller notes
- Basic status (registered → delivered)

**Fields to HIDE from Seller:**
- Technical work timestamps (technical_started_at, technical_completed_at)
- Cosmetic work timestamps (cosmetic_started_at, cosmetic_completed_at)
- Mechanic assignments (assigned_mechanic_id, assigned_detailer_id)
- Prep center details (prep_center_id)
- Internal inspection notes

### Example: Mechanic Role

**Mechanic should only see:**
- Vehicle identification (to know which car)
- Technical work fields (scheduled dates, start/end times, notes)
- Parts tracking (parts_ordered_prep_at, parts_arrived_prep_at)
- Inspection results (inspection_approved, inspection_notes)
- Assigned mechanic (assigned_mechanic_id)

**Fields to HIDE from Mechanic:**
- Customer information (name, phone, email) - not relevant to work
- Seller information (seller_id, seller_notes)
- Financial details (if any existed)
- Cosmetic work details (not their job)

### Example: Prep Center Coordinator Role

**Coordinator should see:**
- ALL fields (needs full visibility for scheduling)
- But may have readonly on some fields:
  - `vin`, `license_plate` (set by seller, shouldn't change)
  - `customer_name`, `customer_email` (owned by seller)

### Recommended Role Structure

```
Admin
├─ Full access to all fields
│
Dealership Manager
├─ Read access to all fields
├─ Update access to status, assignments
│
Prep Center Coordinator
├─ Full access to workflow fields (scheduling, assignments)
├─ Readonly access to vehicle/customer info
│
Seller
├─ Full access to vehicle info, customer info, seller notes
├─ Readonly access to status
├─ No access to technical/cosmetic work details
│
Mechanic
├─ Full access to technical work fields
├─ Readonly access to vehicle identification
├─ No access to customer info, cosmetic work
│
Detailer
├─ Full access to cosmetic work fields
├─ Readonly access to vehicle identification
├─ No access to customer info, technical work
```

---

## Method 2: Conditional Field Visibility

### How It Works

Use the `conditions` property in field metadata to show/hide fields dynamically based on other field values.

**Use Case**: Show prep center fields only when dealership doesn't do own prep.

### Example 1: Conditional Prep Center Field

Show `prep_center_id` only when `dealership.does_own_prep === false`:

```json
{
  "field": "prep_center_id",
  "meta": {
    "conditions": [
      {
        "name": "Show when external prep needed",
        "rule": {
          "_and": [
            {
              "dealership_id": {
                "does_own_prep": {
                  "_eq": false
                }
              }
            }
          ]
        },
        "hidden": false
      }
    ]
  }
}
```

**Default**: If condition not met, field is hidden

### Example 2: Show Technical Fields Only in Technical Status

Show `technical_started_at`, `technical_completed_at` only when `status === "technical_prep"`:

```json
{
  "field": "technical_started_at",
  "meta": {
    "conditions": [
      {
        "name": "Show during technical prep",
        "rule": {
          "status": {
            "_in": ["technical_prep", "cosmetic_prep", "ready_for_delivery", "delivered"]
          }
        },
        "hidden": false
      }
    ],
    "hidden": true
  }
}
```

**Logic**: Field is `hidden: true` by default, but `conditions` can override to show it.

### Example 3: Require Inspection Approval Before Moving Forward

Make `scheduled_technical_date` required only if `inspection_approved === true`:

```json
{
  "field": "scheduled_technical_date",
  "meta": {
    "conditions": [
      {
        "name": "Require after inspection approval",
        "rule": {
          "inspection_approved": {
            "_eq": true
          }
        },
        "required": true
      }
    ]
  }
}
```

### Conditional Properties You Can Set

- `hidden` - Show/hide field
- `readonly` - Make field editable/readonly
- `required` - Make field required/optional
- `options` - Change interface options (e.g., dropdown choices)

---

## Method 3: Field Groups (Organization)

### How It Works

Use field groups to organize related fields into collapsible sections. Users can collapse sections they don't need.

### Current Groups in Cars Collection

1. **Vehicle Info Group** (9 fields)
   - VIN, license plate, brand, model, year, color, accessories, etc.

2. **Customer Group** (3 fields)
   - Customer name, phone, email

3. **Workflow Group** (28 fields)
   - All timestamps, assignments, scheduling, parts tracking

4. **Notes Group** (5 fields)
   - Inspection notes, seller notes, parts notes, technical notes, cosmetic notes

### Recommended Additional Groups

**For Mechanic-Focused View:**

```
Vehicle Identity (collapsed by default)
├─ vin, license_plate, brand, model

Technical Work (expanded by default)
├─ scheduled_technical_date, scheduled_technical_time
├─ technical_started_at, technical_completed_at
├─ estimated_technical_hours
├─ technical_notes
├─ assigned_mechanic_id

Parts Management (expanded by default)
├─ parts_ordered_prep_at, parts_arrived_prep_at
├─ parts_notes

Inspection (expanded by default)
├─ inspection_approved, inspection_completed_at, inspection_notes
```

**For Seller-Focused View:**

```
Vehicle Information (expanded by default)
├─ vin, license_plate, brand, model, year, color, accessories

Customer Information (expanded by default)
├─ customer_name, customer_phone, customer_email

Order Details (expanded by default)
├─ order_number, car_type, dealership_id, seller_id

Status & Notes (expanded by default)
├─ status, registered_at, seller_notes
```

### How to Create Groups

**Via MCP Tools:**

```json
// 1. Create group field (alias type)
{
  "action": "create",
  "collection": "cars",
  "data": [{
    "field": "technical_work_group",
    "type": "alias",
    "meta": {
      "interface": "group-detail",
      "special": ["alias", "no-data", "group"],
      "options": {
        "start": "open"  // or "closed" to collapse by default
      },
      "translations": [
        {"language": "no-NO", "translation": "Teknisk arbeid"},
        {"language": "en-US", "translation": "Technical Work"}
      ]
    },
    "schema": null
  }]
}

// 2. Assign fields to group
{
  "action": "update",
  "collection": "cars",
  "data": [{
    "field": "technical_started_at",
    "type": "dateTime",
    "meta": {
      "group": "technical_work_group"  // Link to group
    }
  }]
}
```

---

## Method 4: Hidden vs Readonly Fields

### Hidden Fields

**Purpose**: Completely hide from UI but still accessible via API

**Use Cases**:
- System fields (id, sort, user_created, date_created)
- Internal tracking fields not relevant to users
- Deprecated fields (keep data, hide UI)

**Example**:
```json
{
  "field": "internal_tracking_code",
  "meta": {
    "hidden": true
  }
}
```

### Readonly Fields

**Purpose**: Show field value but prevent editing

**Use Cases**:
- System-generated timestamps (date_created, date_updated)
- Auto-calculated fields (available_hours in capacities)
- Fields owned by other roles (seller sets VIN, mechanic shouldn't change)

**Example**:
```json
{
  "field": "vin",
  "meta": {
    "readonly": true  // For mechanics, make this readonly via role permissions
  }
}
```

---

## Implementation Strategy

### Step 1: Define User Roles & Responsibilities

| Role | Primary Tasks | Key Collections |
|------|--------------|-----------------|
| **Seller** | Register vehicles, track orders, communicate with customers | cars (limited), notifications |
| **Prep Coordinator** | Schedule work, assign mechanics, monitor capacity | cars (full), resource_bookings, resource_capacities |
| **Mechanic** | Perform technical work, update timestamps, log notes | cars (technical fields), resource_bookings |
| **Detailer** | Perform cosmetic work, update timestamps, log notes | cars (cosmetic fields), resource_bookings |
| **Dealership Manager** | Monitor progress, review reports, manage team | All collections (readonly) |
| **System Admin** | Configure system, manage users, set permissions | All collections (full) |

### Step 2: Configure Field Permissions Per Role

**In Directus Admin UI:**

1. Navigate to **Settings → Access Control → Roles**
2. Select role (e.g., "Mechanic")
3. Click on collection (e.g., "cars")
4. Configure permissions:
   - **Collection-level**: Read, Create, Update permissions
   - **Field-level**: Select which fields this role can access
5. Save permissions

**Example Mechanic Permissions on Cars:**

```
Collection: cars
├─ Action: Read ✅, Create ❌, Update ✅, Delete ❌
│
Field Permissions:
├─ id: Read ✅
├─ vin: Read ✅
├─ license_plate: Read ✅
├─ brand: Read ✅
├─ model: Read ✅
├─ status: Read ✅, Update ❌ (only coordinator changes status)
├─ technical_started_at: Read ✅, Update ✅
├─ technical_completed_at: Read ✅, Update ✅
├─ technical_notes: Read ✅, Update ✅
├─ assigned_mechanic_id: Read ✅, Update ❌
├─ customer_name: None ❌ (hidden)
├─ customer_phone: None ❌ (hidden)
├─ customer_email: None ❌ (hidden)
├─ seller_notes: None ❌ (hidden)
├─ cosmetic_started_at: None ❌ (hidden)
├─ cosmetic_completed_at: None ❌ (hidden)
```

### Step 3: Add Conditional Visibility (Optional)

For fields that should show/hide based on workflow stage:

**Example**: Show parts fields only after inspection approval

```json
{
  "field": "parts_ordered_prep_at",
  "meta": {
    "conditions": [
      {
        "name": "Show after inspection approved",
        "rule": {
          "inspection_approved": {
            "_eq": true
          }
        },
        "hidden": false
      }
    ],
    "hidden": true  // Hidden by default
  }
}
```

### Step 4: Organize with Field Groups

Create role-specific field groups that auto-expand relevant sections:

**For Mechanics:**
- Technical Work Group → Expanded by default
- Parts Management Group → Expanded by default
- Vehicle Info Group → Collapsed by default
- Customer Group → Hidden via permissions

**For Sellers:**
- Vehicle Info Group → Expanded by default
- Customer Group → Expanded by default
- Order Details Group → Expanded by default
- Technical Work Group → Hidden via permissions

---

## Best Practices

### 1. Principle of Least Privilege

Only grant access to fields users **actually need** for their job.

- ❌ Don't: Give everyone read access "just in case"
- ✅ Do: Hide fields that aren't relevant to their workflow

### 2. Progressive Disclosure

Use conditionals to show advanced fields only when needed:

```
Basic fields → Always visible
Advanced fields → Show based on status/conditions
System fields → Hidden from all non-admin users
```

### 3. Consistent Field Grouping

Keep field groups consistent across similar collections:

```
All collections should have:
├─ Identity/Core Info (top)
├─ Workflow/Status (middle)
├─ Metadata/System (bottom, collapsed)
├─ Notes/Comments (bottom, expanded)
```

### 4. Role-Based Layouts (Future Enhancement)

Currently not possible in Directus, but you could:
- Create separate collections with views optimized per role
- Use custom extensions to provide role-specific layouts
- Build custom dashboards per role using panels

### 5. Test with Real Users

Create test accounts for each role and validate:
- ✅ Can they see the fields they need?
- ✅ Are irrelevant fields hidden?
- ✅ Is the form scannable and intuitive?
- ✅ Can they complete their workflow without confusion?

---

## Quick Implementation Checklist

### For Your Current Collections

**Cars Collection:**

```
[ ] Configure Seller role permissions
    [ ] Show: vehicle info, customer info, seller notes, basic status
    [ ] Hide: technical work, cosmetic work, prep assignments

[ ] Configure Mechanic role permissions
    [ ] Show: vehicle ID, technical work fields, parts tracking, inspection
    [ ] Hide: customer info, seller info, cosmetic work

[ ] Configure Detailer role permissions
    [ ] Show: vehicle ID, cosmetic work fields
    [ ] Hide: customer info, seller info, technical work

[ ] Configure Prep Coordinator role permissions
    [ ] Show: all fields (full visibility for scheduling)
    [ ] Readonly: vehicle info, customer info (owned by seller)

[ ] Create field groups
    [ ] Technical Work Group (for mechanics)
    [ ] Cosmetic Work Group (for detailers)
    [ ] Customer Info Group (for sellers)

[ ] Add conditional visibility
    [ ] Show technical fields only after inspection approved
    [ ] Show cosmetic fields only after technical completed
    [ ] Show delivery fields only when status = ready_for_delivery
```

**Resource Bookings Collection:**

```
[ ] Configure Coordinator role permissions
    [ ] Full access to create/edit bookings

[ ] Configure Mechanic/Detailer role permissions
    [ ] Update: status, actual_hours, notes, completed_at
    [ ] Readonly: all other fields
```

---

## Advanced: Custom Field Layouts Per Role

### Using Directus Presets

Directus allows saving **presets** per role that can include:
- Field visibility
- Sort order
- Filters
- Default values

**How to Create:**

1. Log in as a user with the target role
2. Configure the layout view (hide/show columns, set filters)
3. Save as preset
4. Set as default for this role

**Limitations:**
- Presets control **collection view** (table layout), not **item detail form**
- For item forms, use field permissions + groups + conditionals

---

## Example Implementation: Mechanic Role

### Permissions Configuration

```json
{
  "role": "mechanic",
  "collection": "cars",
  "permissions": {
    "read": {
      "filter": {
        "assigned_mechanic_id": {
          "_eq": "$CURRENT_USER"
        }
      }
    },
    "update": {
      "filter": {
        "assigned_mechanic_id": {
          "_eq": "$CURRENT_USER"
        }
      },
      "fields": [
        "status",
        "technical_started_at",
        "technical_completed_at",
        "technical_notes",
        "parts_notes"
      ]
    }
  }
}
```

**Result**: Mechanic can only see/edit cars assigned to them, and only technical work fields.

### Field Groups for Mechanic View

```
Form Layout When Mechanic Opens a Car:

╔══════════════════════════════════════════════════════╗
║ Vehicle Identification (collapsed)                   ║
║  • VIN: 1HGBH41JXMN109186                           ║
║  • License Plate: AB12345                           ║
║  • Brand: Audi | Model: A6 | Year: 2024            ║
╠══════════════════════════════════════════════════════╣
║ Technical Work (expanded) ⭐                         ║
║  • Scheduled Date: 2025-10-30                       ║
║  • Scheduled Time: 09:00                            ║
║  • Started: [Set timestamp]                         ║
║  • Completed: [Set timestamp]                       ║
║  • Estimated Hours: 2.5                             ║
║  • Technical Notes: [Rich text editor]              ║
╠══════════════════════════════════════════════════════╣
║ Parts Management (expanded) ⭐                       ║
║  • Parts Ordered: 2025-10-28 10:00                 ║
║  • Parts Arrived: 2025-10-29 14:30                 ║
║  • Parts Notes: [Rich text editor]                  ║
╠══════════════════════════════════════════════════════╣
║ Inspection (collapsed)                              ║
║  • Approved: ✓ Yes                                  ║
║  • Completed: 2025-10-29 08:00                     ║
║  • Notes: "Minor paint scratch on door"            ║
╚══════════════════════════════════════════════════════╝

[Hidden Sections - Not Visible to Mechanic]
- Customer Information
- Seller Notes
- Cosmetic Work
- Delivery Details
```

---

## Summary & Recommendations

### ✅ What You Should Do

1. **Start with Role-Based Field Permissions** (highest impact)
   - Define 5-6 core roles (Seller, Coordinator, Mechanic, Detailer, Manager, Admin)
   - Configure field-level read/write per role
   - Test with real users

2. **Add Field Groups** (medium impact)
   - Create role-specific groups (Technical Work, Cosmetic Work, etc.)
   - Set default expand/collapse per group
   - Keep related fields together

3. **Use Conditional Visibility Sparingly** (low-medium impact)
   - Show advanced fields only when workflow stage requires them
   - Require fields based on approval gates (e.g., inspection approved)

4. **Document Role Responsibilities** (high impact on training)
   - Create one-page guide per role showing which fields they use
   - Include screenshots of their optimized view
   - Train users on their specific workflow

### ✅ Implementation Priority

**Phase 1 (High Impact, Low Effort):**
- Configure basic role permissions (show/hide fields per role)
- Hide system fields from non-admin users
- Test with 2-3 real users per role

**Phase 2 (Medium Impact, Medium Effort):**
- Create field groups for logical organization
- Add conditional visibility for workflow gates
- Create role-specific presets for collection views

**Phase 3 (Low Impact, High Effort):**
- Custom interfaces/extensions for specialized workflows
- Role-based dashboard panels
- Automated field updates based on status changes

### Quick Answer to Your Question

**Yes**, Directus has **excellent built-in field-level permissions** per role:

1. Go to **Settings → Access Control → [Role Name]**
2. Click on the collection (e.g., "cars")
3. Configure field permissions:
   - Select which fields this role can **read**
   - Select which fields this role can **create/update**
   - Fields not selected are **completely hidden** from that role

**Combine with:**
- Field groups (organize related fields)
- Conditional visibility (show fields based on data)
- Presets (save custom views per role)

This gives you **complete control** over showing users only the fields relevant to their workflow. 🎯
