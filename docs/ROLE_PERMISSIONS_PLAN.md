# DirectApp - Role-Based Field Permissions Plan

**Generated:** 2025-10-20
**Purpose:** Define comprehensive field-level access control for all 10 Norwegian user roles

## Role Hierarchy

### 1. Salgsroller (Sales Roles)
- **Nybilselger** - New car sales
- **Bruktbilselger** - Used car sales (cross-dealership search)

### 2. Produktive Roller (Production Roles with Time Banking)
- **Delelager** - Parts warehouse
- **Mottakskontrollør** - Inspection control
- **Booking** - Workshop scheduling
- **Mekaniker** - Mechanic (technical prep)
- **Bilpleiespesialist** - Detailer (cosmetic prep)

### 3. Lederroller (Management Roles)
- **Daglig leder** - Daily manager (read-only access to all)
- **Økonomiansvarlig** - Finance manager (pricing access)

### 4. Teknisk Rolle
- **Admin** - Full system access

---

## Field-Level Permission Matrix

### Legend:
- ✏️ **Edit** - Can create/modify
- 👁️ **View** - Read-only access
- ❌ **Hidden** - Field not visible
- 🔒 **Auto** - Auto-filled, read-only

---

## Permission by Workflow Group

### Gruppe: Grunnleggende Informasjon (Always Visible)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **car_type** | ✏️ (create) | ✏️ (create) | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **vin** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **license_plate** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **brand** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **model** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **model_year** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **color** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **order_number** | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Kundeinformasjon (Nybil Only)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **customer_name** | ✏️ | ❌ Hidden | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **customer_phone** | ✏️ | ❌ Hidden | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **customer_email** | ✏️ | ❌ Hidden | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Registrering (Auto-filled Fields)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **dealership_id** | 🔒 Auto | 🔒 Auto | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **seller_id** | 🔒 Auto | 🔒 Auto | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **registered_at** | 🔒 Auto | 🔒 Auto | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **status** | ✏️ (limited) | ✏️ (limited) | ✏️ (limited) | ✏️ (limited) | ✏️ (limited) | ✏️ (limited) | ✏️ (limited) | 👁️ | 👁️ | ✏️ |

*Note: Status changes are validated by workflow-guard hook based on current status and user role*

---

### Gruppe: Tilbehør Selger (Nybil - Seller Accessories)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **accessories** | ✏️ (content) | ❌ Hidden | ✏️ (status) | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **parts_ordered_seller_at** | 👁️ | ❌ Hidden | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **parts_arrived_seller_at** | 👁️ | ❌ Hidden | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **parts_notes** | 👁️ | ❌ Hidden | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

*Note: Nybilselger can edit accessories content (add/remove items), Delelager updates ordered/received status*

---

### Gruppe: Tilbehør Prep (Nybil - Prep Center Accessories)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **parts_ordered_prep_at** | 👁️ | ❌ Hidden | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **parts_arrived_prep_at** | 👁️ | ❌ Hidden | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Transport (Delivery to Prep Center)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **prep_center_id** | ✏️ (select) | ✏️ (select) | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **arrived_prep_center_at** | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Mottakskontroll (Inspection)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **inspection_completed_at** | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **inspection_approved** | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **inspection_notes** | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Planlegging (Workshop Scheduling)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **scheduled_technical_date** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **scheduled_technical_time** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **assigned_mechanic_id** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **estimated_technical_hours** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **scheduled_cosmetic_date** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **scheduled_cosmetic_time** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **assigned_detailer_id** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **estimated_cosmetic_hours** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Teknisk (Technical Prep)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **technical_started_at** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **technical_completed_at** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **technical_notes** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Kosmetisk (Cosmetic Prep)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **cosmetic_started_at** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | ✏️ |
| **cosmetic_completed_at** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | ✏️ |
| **cosmetic_notes** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Levering (Delivery)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **ready_for_delivery_at** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **delivered_to_dealership_at** | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Salg (Sales/Pricing)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **purchase_price** | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | 👁️ | ✏️ | ✏️ |
| **sale_price** | ✏️ | ✏️ | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | 👁️ | ✏️ | ✏️ |
| **prep_cost** | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | ❌ Hidden | 👁️ | ✏️ | ✏️ |
| **sold_at** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **delivered_to_customer_at** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

### Gruppe: Dokumenter (Notes/Archive)

| Field | Nybilselger | Bruktbilselger | Delelager | Mottakskontroll | Booking | Mekaniker | Bilpleier | Daglig Leder | Økonomiansvarlig | Admin |
|-------|-------------|----------------|-----------|-----------------|---------|-----------|-----------|--------------|------------------|-------|
| **seller_notes** | ✏️ | ✏️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |
| **archived_at** | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | 👁️ | ✏️ |

---

## Collection-Level Permissions

### CREATE Access (Who can create new cars)

| Role | Nybil | Bruktbil | Presets | Notes |
|------|-------|----------|---------|-------|
| **Nybilselger** | ✅ Yes | ❌ No | car_type: "nybil" | Auto-fill dealership_id, seller_id |
| **Bruktbilselger** | ❌ No | ✅ Yes | car_type: "bruktbil" | Auto-fill dealership_id, seller_id |
| **Delelager** | ❌ No | ❌ No | - | - |
| **Mottakskontrollør** | ❌ No | ❌ No | - | - |
| **Booking** | ❌ No | ❌ No | - | - |
| **Mekaniker** | ❌ No | ❌ No | - | - |
| **Bilpleiespesialist** | ❌ No | ❌ No | - | - |
| **Daglig leder** | ❌ No | ❌ No | - | Read-only role |
| **Økonomiansvarlig** | ❌ No | ❌ No | - | Read-only role |
| **Admin** | ✅ Yes | ✅ Yes | - | Full access |

---

### READ Access (Who can see cars)

| Role | Filter | Notes |
|------|--------|-------|
| **Nybilselger** | `car_type = "nybil" AND dealership_id = $CURRENT_USER.dealership_id` | Own dealership nybil only |
| **Bruktbilselger** | `car_type = "bruktbil"` | **Cross-dealership search** for used cars |
| **Delelager** | `dealership_id = $CURRENT_USER.dealership_id OR prep_center_id = $CURRENT_USER.dealership_id` | Own dealership OR prep center |
| **Mottakskontrollør** | `prep_center_id = $CURRENT_USER.dealership_id` | Only prep center cars |
| **Booking** | `prep_center_id = $CURRENT_USER.dealership_id` | Only prep center cars |
| **Mekaniker** | `prep_center_id = $CURRENT_USER.dealership_id` | Only prep center cars |
| **Bilpleiespesialist** | `prep_center_id = $CURRENT_USER.dealership_id` | Only prep center cars |
| **Daglig leder** | `dealership_id = $CURRENT_USER.dealership_id` | Own dealership all types |
| **Økonomiansvarlig** | `dealership_id = $CURRENT_USER.dealership_id` | Own dealership all types |
| **Admin** | No filter | All cars system-wide |

---

### UPDATE Access (Who can edit cars)

| Role | Filter | Editable Fields | Notes |
|------|--------|-----------------|-------|
| **Nybilselger** | `car_type = "nybil" AND dealership_id = $CURRENT_USER.dealership_id AND status != "arkivert"` | Grunnleggende, Kunde, Accessories content, Sale price, Seller notes | Cannot edit archived |
| **Bruktbilselger** | `car_type = "bruktbil" AND dealership_id = $CURRENT_USER.dealership_id AND status != "arkivert"` | Grunnleggende, Sale price, Seller notes | Cannot edit archived |
| **Delelager** | `(dealership_id = $CURRENT_USER.dealership_id OR prep_center_id = $CURRENT_USER.dealership_id) AND status != "arkivert"` | Parts timestamps, Accessories status, Parts notes | Both seller + prep center |
| **Mottakskontrollør** | `prep_center_id = $CURRENT_USER.dealership_id AND status IN ("ankommet_klargjoring", "mottakskontroll_pågår")` | Inspection fields | Only during inspection phase |
| **Booking** | `prep_center_id = $CURRENT_USER.dealership_id AND status != "arkivert"` | Scheduling, Assignment, Delivery timestamps | Cannot edit archived |
| **Mekaniker** | `prep_center_id = $CURRENT_USER.dealership_id AND assigned_mechanic_id = $CURRENT_USER.id AND status IN ("planlagt_teknisk", "teknisk_pågår")` | Technical timestamps, Technical notes | Only assigned cars |
| **Bilpleiespesialist** | `prep_center_id = $CURRENT_USER.dealership_id AND assigned_detailer_id = $CURRENT_USER.id AND status IN ("planlagt_kosmetisk", "kosmetisk_pågår")` | Cosmetic timestamps, Cosmetic notes | Only assigned cars |
| **Daglig leder** | No edit access | - | Read-only role |
| **Økonomiansvarlig** | `dealership_id = $CURRENT_USER.dealership_id AND status != "arkivert"` | Pricing fields (purchase, sale, prep cost) | Finance management |
| **Admin** | No filter | All fields | Full system access |

---

### DELETE Access (Who can delete cars)

| Role | Filter | Notes |
|------|--------|-------|
| **Nybilselger** | `car_type = "nybil" AND dealership_id = $CURRENT_USER.dealership_id AND status = "ny_ordre"` | Only initial state |
| **Bruktbilselger** | `car_type = "bruktbil" AND dealership_id = $CURRENT_USER.dealership_id AND status = "innbytte_registrert"` | Only initial state |
| **Others** | ❌ No delete access | Use archive instead |
| **Admin** | Workflow-guard validates | Hook prevents deletion beyond initial states |

---

## Status Transition Permissions

Each role can only transition to specific next states based on current workflow position:

### Nybilselger
- `ny_ordre` → `deler_bestilt_selgerforhandler` (after parts ordered)
- `levert_til_selgerforhandler` → `solgt_til_kunde` (mark as sold)
- `solgt_til_kunde` → `levert_til_kunde` (mark as delivered)

### Delelager
- `ny_ordre` → `deler_bestilt_selgerforhandler` (confirm parts ordered - seller side)
- `deler_bestilt_selgerforhandler` → `deler_ankommet_selgerforhandler` (parts arrived)
- `deler_ankommet_selgerforhandler` → `deler_bestilt_klargjoring` (prep center parts ordered)
- `deler_bestilt_klargjoring` → `deler_ankommet_klargjoring` (prep center parts arrived)

### Mottakskontrollør
- `ankommet_klargjoring` → `mottakskontroll_pågår` (start inspection)
- `mottakskontroll_pågår` → `mottakskontroll_godkjent` (approve)
- `mottakskontroll_pågår` → `mottakskontroll_avvik` (reject with issues)
- `mottakskontroll_godkjent` → `venter_booking` (auto-transition)

### Booking
- `venter_booking` → `planlagt_teknisk` (schedule technical)
- `teknisk_ferdig` → `planlagt_kosmetisk` (schedule cosmetic)
- `kosmetisk_ferdig` → `klar_for_levering` (mark ready)
- `klar_for_levering` → `levert_til_selgerforhandler` (mark delivered)

### Mekaniker
- `planlagt_teknisk` → `teknisk_pågår` (start work)
- `teknisk_pågår` → `teknisk_ferdig` (complete work)

### Bilpleiespesialist
- `planlagt_kosmetisk` → `kosmetisk_pågår` (start work)
- `kosmetisk_pågår` → `kosmetisk_ferdig` (complete work)

### Admin
- Can transition between any states (emergency/fix situations)

---

## Implementation Notes

1. **Dealership Isolation**: All roles (except Bruktbilselger and Admin) are restricted to their dealership via filters
2. **Workflow Guard Hook**: Validates all status transitions and enforces required fields
3. **Auto-fill Logic**: dealership_id and seller_id auto-filled on create from current user
4. **Prep Center Assignment**: Allows prep center users to work on cars from other dealerships
5. **Time Banking**: Mekaniker and Bilpleiespesialist time tracked via estimated vs actual hours
6. **Cross-Dealership Search**: Only Bruktbilselger can search across all dealerships for synergy sales

---

## Next Steps

1. Create/update Directus policies for each role
2. Create detailed field-level permissions for each policy
3. Update workflow-guard hook to validate role-based transitions
4. Add department-aware auto-fill logic to hook
5. Configure conditional field visibility in UI
6. Test with all 10 roles using test users from Issue #23

---

**Generated by:** Claude Code - DirectApp Team
**Last Updated:** 2025-10-20
