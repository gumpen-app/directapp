# Cars Collection - Comprehensive Audit
**Date**: 2025-10-29
**Collection**: `cars` (Vehicle inventory tracking)
**Total Fields**: 57 fields (53 data fields + 4 group aliases)

---

## Executive Summary

The cars collection tracks vehicle preparation from arrival through delivery. Current implementation has good foundation but needs:
- **19 fields missing interfaces** (33% of fields)
- **17 fields missing translations**
- **4 financial fields to remove** (out of scope)
- **Inconsistent field grouping** (20+ ungrouped workflow fields)
- **Redundant timestamp fields** (created_at/date_created duplication)

---

## 1. Field Inventory by Category

### Core Identity (3 fields) ✅ Well configured
- `id` - UUID primary key (hidden, readonly) ✅
- `vin` - Vehicle ID (validated, translated, grouped) ✅
- `license_plate` - Norwegian plate (validated, translated, grouped) ✅

### Vehicle Information (6 fields) - Mixed quality
| Field | Status | Issues |
|-------|--------|--------|
| `brand` | ⚠️ Partial | No interface, basic setup |
| `model` | ⚠️ Partial | No interface, basic setup |
| `model_year` | ⚠️ Partial | No interface, basic setup |
| `color` | ⚠️ Partial | No interface, basic setup |
| `order_number` | ⚠️ Partial | No interface, has validation (unique) |
| `car_type` | ✅ Good | Select dropdown, translated, labeled |

### Customer Information (3 fields) ✅ Well configured
- `customer_name` - Basic text input ⚠️ (no interface)
- `customer_phone` - Validated Norwegian format ✅
- `customer_email` - Email validation ✅

### Workflow Status (1 field) ✅ Excellent
- `status` - 11-stage workflow with colors, translations, labels ✅

### System Fields (6 fields) - Needs attention
| Field | Current | Issue |
|-------|---------|-------|
| `sort` | Visible | Should be hidden |
| `user_created` | ❌ No interface | Needs user display |
| `date_created` | ❌ No interface | Needs datetime display |
| `user_updated` | ❌ No interface | Needs user display |
| `date_updated` | ❌ No interface | Needs datetime display |
| `created_at` | Visible | REDUNDANT with date_created |
| `updated_at` | Visible | REDUNDANT with date_updated |

### Relations (5 fields)
| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `dealership_id` | M2O dealership | ✅ Good | Required, templated display |
| `prep_center_id` | M2O dealership | ❌ Missing | No interface/display |
| `seller_id` | M2O users | ✅ Good | Templated, user display |
| `assigned_mechanic_id` | M2O users | ✅ Good | Templated, user display |
| `assigned_detailer_id` | M2O users | ✅ Good | Templated, user display |

### Timestamps - Workflow Milestones (17 fields) ❌ Major gaps
**All missing interfaces, displays, and most missing translations:**
- `registered_at` ⚠️ (has interface/display but ungrouped)
- `parts_ordered_seller_at` ❌
- `parts_arrived_seller_at` ❌
- `parts_ordered_prep_at` ❌
- `parts_arrived_prep_at` ❌
- `arrived_prep_center_at` ⚠️ (has interface/display)
- `inspection_completed_at` ⚠️ (has interface/display)
- `scheduled_technical_date` ⚠️ (has interface but wrong config)
- `scheduled_technical_time` ⚠️ (has interface but wrong config)
- `technical_started_at` ❌
- `technical_completed_at` ❌
- `scheduled_cosmetic_date` ❌
- `scheduled_cosmetic_time` ❌
- `cosmetic_started_at` ❌
- `cosmetic_completed_at` ❌
- `ready_for_delivery_at` ❌
- `delivered_to_dealership_at` ❌
- `sold_at` ❌
- `delivered_to_customer_at` ❌
- `archived_at` ❌

### Inspection Fields (2 fields)
- `inspection_approved` - Boolean ✅ (translated, labeled)
- `inspection_notes` - Rich text markdown ✅ (translated, grouped)

### Estimation Fields (2 fields) ⚠️ Questionable utility
- `estimated_technical_hours` - No interface, default 2.5
- `estimated_cosmetic_hours` - No interface, default 2.5

### 🚫 Financial Fields (3 fields) - TO REMOVE
- `purchase_price` - NUMERIC(12,2)
- `sale_price` - NUMERIC(12,2)
- `prep_cost` - NUMERIC(12,2)

### Notes Fields (4 fields) - Mixed quality
| Field | Interface | Translation | Grouped |
|-------|-----------|-------------|---------|
| `seller_notes` | ❌ | ❌ | ✅ |
| `parts_notes` | ❌ | ❌ | ✅ |
| `technical_notes` | ✅ Rich text | ✅ | ✅ |
| `cosmetic_notes` | ✅ Rich text | ✅ | ✅ |

### Accessories (1 field)
- `accessories` - JSON array, no interface ❌

---

## 2. Field Grouping Analysis

### Defined Groups (4 groups)
1. **vehicle_info_group** - 8 fields ✅
2. **customer_group** - 3 fields ✅
3. **workflow_group** - Defined but EMPTY ❌
4. **notes_group** - 4 fields ✅

### Ungrouped Fields (~25 fields)
**Should be in workflow_group:**
- All relation assignments (seller_id, assigned_mechanic_id, assigned_detailer_id)
- All 17+ timestamp fields
- Estimation hours fields
- registered_at field

**Should be organized elsewhere:**
- System fields (hidden group or default)
- Financial fields (remove entirely)

---

## 3. Missing Interfaces by Type

### No Interface Specified (19 fields)
| Field | Recommended Interface |
|-------|----------------------|
| `sort` | `input` (but hide) |
| `user_created` | `select-dropdown-m2o` + user display |
| `date_created` | `datetime` + relative display |
| `user_updated` | `select-dropdown-m2o` + user display |
| `date_updated` | `datetime` + relative display |
| `brand` | `input` with icon |
| `model` | `input` |
| `model_year` | `input` (numeric, 4 digits) |
| `color` | `select-color` or `input` |
| `order_number` | `input` (monospace) |
| `customer_name` | `input` with icon |
| `created_at` | REMOVE (redundant) |
| `updated_at` | REMOVE (redundant) |
| `prep_center_id` | `select-dropdown-m2o` (match dealership) |
| `parts_ordered_seller_at` | `datetime` |
| `parts_arrived_seller_at` | `datetime` |
| `parts_ordered_prep_at` | `datetime` |
| `parts_arrived_prep_at` | `datetime` |
| `technical_started_at` | `datetime` |
| `technical_completed_at` | `datetime` |
| `scheduled_cosmetic_date` | `datetime` (date only) |
| `scheduled_cosmetic_time` | `datetime` (time only) |
| `cosmetic_started_at` | `datetime` |
| `cosmetic_completed_at` | `datetime` |
| `ready_for_delivery_at` | `datetime` |
| `delivered_to_dealership_at` | `datetime` |
| `sold_at` | `datetime` |
| `delivered_to_customer_at` | `datetime` |
| `archived_at` | `datetime` |
| `accessories` | `list` or `tags` |
| `estimated_technical_hours` | `input` (decimal) |
| `estimated_cosmetic_hours` | `input` (decimal) |
| `seller_notes` | `input-rich-text-md` |
| `parts_notes` | `input-rich-text-md` |

---

## 4. Translation Gaps

### Fields Missing Norwegian (no-NO) + English (en-US) Translations (17 fields)
- `brand`
- `model`
- `model_year`
- `color`
- `order_number`
- `customer_name`
- `created_at`
- `updated_at`
- `prep_center_id`
- `parts_ordered_seller_at`
- `parts_arrived_seller_at`
- `parts_ordered_prep_at`
- `parts_arrived_prep_at`
- `scheduled_cosmetic_date`
- `scheduled_cosmetic_time`
- All remaining timestamp fields
- `accessories`
- `estimated_technical_hours`
- `estimated_cosmetic_hours`
- Financial fields (removing anyway)
- `seller_notes`
- `parts_notes`

---

## 5. Validation & Logic Review

### ✅ Good Validation Rules
- `vin` - Regex for 17-char VIN (no I, O, Q) ✅
- `license_plate` - Norwegian format (2 letters + 5 digits) ✅
- `customer_phone` - Norwegian phone format (+47 8 digits) ✅
- `customer_email` - Email regex ✅

### Missing Validation
- `model_year` - Should validate range (1900-2099)
- `order_number` - No format validation
- `brand` - No validation (could use enum of common brands)
- Timestamp fields - No logical sequence validation (e.g., started_at < completed_at)

### Field Dependencies (Conditions)
❌ **No conditional logic found** - Consider adding:
- Show `prep_center_id` only if different from `dealership_id`
- Show technical/cosmetic fields based on workflow status
- Require `inspection_approved` before moving past inspection status

---

## 6. Schema Quality Issues

### Redundancies
1. **created_at** vs **date_created** (DUPLICATE - remove created_at)
2. **updated_at** vs **date_updated** (DUPLICATE - remove updated_at)

### Index Analysis
**Indexed fields (good for queries):**
- `status` ✅
- `vin` (unique) ✅
- `license_plate` ✅
- `brand` ✅
- `order_number` (unique) ✅
- `dealership_id` ✅
- `prep_center_id` ✅
- `seller_id` ✅
- `car_type` ✅

**Should consider indexing:**
- `registered_at` (for date range queries)
- `status` + `dealership_id` (composite for dashboard)

---

## 7. Recommended Actions (Priority Order)

### Phase 1: Cleanup (Remove/Fix)
1. ✅ **Remove financial fields** (purchase_price, sale_price, prep_cost)
2. ✅ **Remove redundant timestamps** (created_at, updated_at)
3. ✅ **Hide system fields** (sort, user_created, date_created, user_updated, date_updated)

### Phase 2: Critical Interfaces (High Impact)
4. **Add interfaces to all timestamp fields** (17 fields) - Use `datetime` with relative display
5. **Configure prep_center_id** - Match dealership_id interface
6. **Add interfaces to vehicle info** (brand, model, model_year, color, order_number)
7. **Configure accessories field** - Use `list` or `tags` interface
8. **Add interfaces to notes** (seller_notes, parts_notes) - Rich text markdown

### Phase 3: Translations (User Experience)
9. **Translate all field names** - Norwegian + English for all 17+ missing fields
10. **Translate group names** - Ensure consistency

### Phase 4: Organization (Structure)
11. **Reorganize workflow_group** - Add all workflow-related fields:
    - All timestamp milestones
    - Assignment fields (seller, mechanic, detailer)
    - Estimation hours
    - registered_at
12. **Consider new groups:**
    - "Parts Management" (parts_* timestamps, parts_notes)
    - "Scheduling" (scheduled_* fields)
    - "Assignments" (seller_id, mechanic, detailer)

### Phase 5: Enhancement (Logic & UX)
13. **Add field conditions** - Show/hide based on workflow status
14. **Add validation** - Model year ranges, timestamp logic
15. **Review estimation fields** - Determine if manual input or auto-calculated

---

## 8. Field Width Review

### Current Width Distribution
- **half width**: 11 fields (good for compact layout)
- **full width**: 46 fields (may cause excessive scrolling)

### Recommendations
Many timestamp pairs could be half-width:
- `scheduled_technical_date` + `scheduled_technical_time` → both half
- `scheduled_cosmetic_date` + `scheduled_cosmetic_time` → both half
- `technical_started_at` + `technical_completed_at` → both half
- `cosmetic_started_at` + `cosmetic_completed_at` → both half

---

## 9. Summary Statistics

| Metric | Count | % |
|--------|-------|---|
| Total fields | 57 | 100% |
| Missing interface | 19 | 33% |
| Missing translations | 17 | 30% |
| Properly grouped | 15 | 26% |
| Ungrouped | 25 | 44% |
| Hidden (correctly) | 1 | 2% |
| Should be hidden | 6 | 11% |
| To remove | 5 | 9% |

**Health Score: 62/100** ⚠️
- Schema: 75/100 (good relations, some redundancy)
- UX: 45/100 (many missing interfaces)
- i18n: 60/100 (partial translations)
- Organization: 55/100 (inconsistent grouping)

---

## Next Steps

**Quick Win (30 min)**: Remove financial + redundant fields, hide system fields
**High Impact (2 hours)**: Add interfaces to all timestamps and core fields
**Polish (1 hour)**: Translations + field grouping reorganization
**Advanced (2 hours)**: Conditional logic + validation rules

**Estimated Total**: 5.5 hours to reach 90/100 health score
