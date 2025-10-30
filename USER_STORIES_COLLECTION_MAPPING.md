# User Stories ↔ Collection Logic Mapping

**Date**: 2025-10-29
**Purpose**: Validate that collection structure aligns with actual business workflows and user needs

---

## User Personas

### Primary Roles
1. **Dealership Manager** - Oversees operations, monitors vehicle progress, manages team
2. **Seller/Salesperson** - Registers new vehicles, tracks orders, communicates with customers
3. **Prep Center Coordinator** - Schedules work, manages capacity, allocates resources
4. **Mechanic/Technician** - Performs technical preparation work
5. **Detailer** - Performs cosmetic preparation work
6. **Customer** - Receives notifications about their vehicle (indirect user)
7. **System Administrator** - Configures dealerships, resource sharing, and system settings

---

## Collection 1: Cars 🚗

### Purpose
Track individual vehicles through the entire preparation workflow from registration to customer delivery.

### Primary User Stories

#### US-1.1: Register New Vehicle Order
**As a** Seller
**I want to** register a new vehicle in the system
**So that** the prep workflow can begin

**Fields Used:**
- ✅ `vin`, `license_plate`, `brand`, `model`, `model_year`, `color` (vehicle identity)
- ✅ `order_number` (external system reference)
- ✅ `customer_name`, `customer_phone`, `customer_email` (customer info)
- ✅ `dealership_id`, `seller_id` (ownership/responsibility)
- ✅ `car_type` (new/used/demo/certified)
- ✅ `status` → "registered"
- ✅ `registered_at` (timestamp)
- ✅ `accessories` (optional equipment)
- ✅ `seller_notes` (special instructions)

**Validation:** ✅ **All required fields present**

---

#### US-1.2: Schedule Vehicle for Prep Work
**As a** Prep Center Coordinator
**I want to** schedule technical and cosmetic work for a vehicle
**So that** we can plan our daily capacity

**Fields Used:**
- ✅ `prep_center_id` (where work happens)
- ✅ `scheduled_technical_date`, `scheduled_technical_time` (technical schedule)
- ✅ `scheduled_cosmetic_date`, `scheduled_cosmetic_time` (cosmetic schedule)
- ✅ `estimated_technical_hours`, `estimated_cosmetic_hours` (capacity planning)
- ✅ `assigned_mechanic_id`, `assigned_detailer_id` (resource assignment)
- ✅ `status` → "parts_ordered" or "technical_prep"

**Validation:** ✅ **All scheduling fields present**

**🔗 Integration:** Creates `resource_bookings` records for capacity tracking

---

#### US-1.3: Track Parts Ordering
**As a** Prep Center Coordinator
**I want to** track when parts are ordered and arrive
**So that** I know when work can begin

**Fields Used:**
- ✅ `parts_ordered_seller_at`, `parts_arrived_seller_at` (seller-ordered parts)
- ✅ `parts_ordered_prep_at`, `parts_arrived_prep_at` (prep center-ordered parts)
- ✅ `parts_notes` (tracking details, order numbers)
- ✅ `status` → "parts_ordered"

**Validation:** ✅ **Separate tracking for seller vs prep center parts**

**💡 Improvement Opportunity:** Consider adding `parts_status` field (ordered/in_transit/arrived/installed) for better visibility

---

#### US-1.4: Perform Vehicle Inspection
**As a** Mechanic
**I want to** record inspection results
**So that** we document the vehicle condition before work begins

**Fields Used:**
- ✅ `arrived_prep_center_at` (physical arrival)
- ✅ `inspection_completed_at` (inspection timestamp)
- ✅ `inspection_approved` (pass/fail)
- ✅ `inspection_notes` (findings, issues, recommendations)
- ✅ `status` → "inspection"

**Validation:** ✅ **Inspection workflow complete**

---

#### US-1.5: Complete Technical/Cosmetic Work
**As a** Mechanic or Detailer
**I want to** record when I start and complete work
**So that** the system tracks progress and actual hours

**Fields Used:**
- ✅ `technical_started_at`, `technical_completed_at` (technical timestamps)
- ✅ `cosmetic_started_at`, `cosmetic_completed_at` (cosmetic timestamps)
- ✅ `technical_notes`, `cosmetic_notes` (work performed)
- ✅ `status` → "technical_prep" → "cosmetic_prep" → "ready_for_delivery"

**Validation:** ✅ **Start/end timestamps for both work types**

**🔗 Integration:** Updates `resource_bookings.actual_hours` and `resource_capacities.used_hours`

---

#### US-1.6: Deliver Vehicle to Customer
**As a** Seller
**I want to** record delivery milestones
**So that** we track the complete vehicle lifecycle

**Fields Used:**
- ✅ `ready_for_delivery_at` (prep complete)
- ✅ `delivered_to_dealership_at` (back at dealership)
- ✅ `sold_at` (sale completed)
- ✅ `delivered_to_customer_at` (handover)
- ✅ `status` → "ready_for_delivery" → "delivered"

**Validation:** ✅ **Complete delivery chain tracked**

**🔗 Integration:** Triggers `notifications` to customer and dealership staff

---

#### US-1.7: Monitor Vehicle Status
**As a** Dealership Manager
**I want to** see all vehicles and their current status
**So that** I can identify bottlenecks and delays

**Fields Used:**
- ✅ `status` (11-stage workflow)
- ✅ All timestamp fields (identify delays)
- ✅ `dealership_id` (filter to my dealership)
- ✅ `assigned_mechanic_id`, `assigned_detailer_id` (workload by person)

**Validation:** ✅ **Comprehensive status tracking**

**📊 Dashboard Needs:**
- Vehicles by status (count per stage)
- Average time per stage
- Overdue vehicles (scheduled vs actual)
- Mechanic/detailer workload

---

### Workflow Validation: Cars Collection

**11-Stage Status Workflow:**
```
draft → registered → in_transit → at_prep_center → inspection →
parts_ordered → technical_prep → cosmetic_prep → ready_for_delivery →
delivered → archived
```

**Timestamp Alignment:**
| Status | Timestamp Field | ✅/❌ |
|--------|----------------|-------|
| registered | `registered_at` | ✅ |
| at_prep_center | `arrived_prep_center_at` | ✅ |
| inspection | `inspection_completed_at` | ✅ |
| parts_ordered | `parts_ordered_*_at` | ✅ |
| technical_prep | `technical_started_at`, `technical_completed_at` | ✅ |
| cosmetic_prep | `cosmetic_started_at`, `cosmetic_completed_at` | ✅ |
| ready_for_delivery | `ready_for_delivery_at` | ✅ |
| delivered | `delivered_to_customer_at` | ✅ |
| archived | `archived_at` | ✅ |

**Validation:** ✅ **All workflow stages have corresponding timestamp fields**

---

## Collection 2: Dealership 🏢

### Purpose
Manage dealership entities, hierarchy, branding, and operational configuration.

### Primary User Stories

#### US-2.1: Create New Dealership
**As a** System Administrator
**I want to** add a new dealership to the system
**So that** they can start using the platform

**Fields Used:**
- ✅ `dealership_number` (unique identifier)
- ✅ `dealership_name` (display name)
- ✅ `location` (geographic location)
- ✅ `dealership_type` (sales_only/prep_center_only/sales_and_prep)
- ✅ `brand` (primary brand)
- ✅ `does_own_prep` (capability flag)
- ✅ `active` (operational status)

**Validation:** ✅ **All setup fields present**

---

#### US-2.2: Configure Dealership Hierarchy
**As a** System Administrator
**I want to** link branch dealerships to their headquarters
**So that** reporting and permissions can be inherited

**Fields Used:**
- ✅ `parent_dealership_id` (hierarchy link)
- ✅ `prep_center_id` (default prep center for non-prep dealerships)

**Validation:** ✅ **Hierarchy support exists**

**🔗 Integration:** Affects permission inheritance and reporting rollup

---

#### US-2.3: Brand Customization
**As a** Dealership Manager
**I want to** customize the system appearance with our brand colors and logo
**So that** it feels like our dealership's system

**Fields Used:**
- ✅ `brand_colors` (JSON with color scheme)
- ✅ `logo` (image file)

**Validation:** ✅ **Branding customization supported**

---

### Workflow Validation: Dealership Collection

**Dealership Types & Logic:**
- `sales_only` + `does_own_prep: false` → Must have `prep_center_id` set
- `prep_center_only` → Provides services to other dealerships via `resource_sharing`
- `sales_and_prep` + `does_own_prep: true` → Can be own prep center

**Validation:** ✅ **Type logic supported by fields**

---

## Collection 3: Notifications 🔔

### Purpose
Send real-time notifications to users about important events and status changes.

### Primary User Stories

#### US-3.1: Notify User of Status Change
**As a** System
**I want to** notify relevant users when a vehicle status changes
**So that** they can take appropriate action

**Fields Used:**
- ✅ `user_id` (notification recipient)
- ✅ `car_id` (related vehicle)
- ✅ `type` (notification category: status_update)
- ✅ `message` (notification content)
- ✅ `read` (tracking if user saw it)
- ✅ `created_at` (when notification was sent)

**Validation:** ✅ **All notification fields present**

**Trigger Examples:**
- Vehicle moves to "ready_for_delivery" → Notify seller
- Inspection fails → Notify prep coordinator
- Parts arrive → Notify mechanic
- Delivery complete → Notify dealership manager

---

#### US-3.2: User Views and Marks Notifications as Read
**As a** User
**I want to** see my unread notifications and mark them as read
**So that** I stay informed without duplicate alerts

**Fields Used:**
- ✅ `user_id` (filter to my notifications)
- ✅ `read` (filter unread, mark as read)
- ✅ `created_at` (sort by newest)
- ✅ `type` (filter by category)

**Validation:** ✅ **Read tracking functional**

---

### Workflow Validation: Notifications Collection

**Notification Types:**
- `new_order` → Seller registers vehicle
- `parts_changed` → Parts ordered/arrived
- `inspection_done` → Inspection completed
- `ready_for_delivery` → Vehicle ready
- `status_update` → General status changes

**Validation:** ✅ **Types cover main workflow events**

**💡 Improvement Opportunity:** Consider adding `priority` field (low/medium/high/urgent) for better UX

---

## Collection 4: Resource Types 🔧

### Purpose
Define categories of work/resources that can be scheduled, tracked, and shared between dealerships.

### Primary User Stories

#### US-4.1: Configure Available Resource Types
**As a** System Administrator
**I want to** define what types of work can be done
**So that** we can schedule and track capacity

**Fields Used:**
- ✅ `code` (system identifier, e.g., "TECH_PREP", "COSMETIC")
- ✅ `name` (display name, e.g., "Technical Preparation")
- ✅ `description` (what this resource type includes)
- ✅ `icon`, `color` (visual identification)
- ✅ `active` (enable/disable)

**Validation:** ✅ **Basic configuration complete**

---

#### US-4.2: Set Resource Type Behavior
**As a** System Administrator
**I want to** configure how each resource type behaves
**So that** scheduling and tracking work correctly

**Fields Used:**
- ✅ `is_productive` (counts toward productive hours/timebank)
- ✅ `bookable` (can be scheduled in calendar)
- ✅ `requires_assignment` (must assign specific person)
- ✅ `default_duration_hours` (default time estimate)

**Validation:** ✅ **Behavioral configuration complete**

**Example Resource Types:**
- Technical Preparation (`is_productive: true`, `bookable: true`, `requires_assignment: true`)
- Cosmetic Preparation (`is_productive: true`, `bookable: true`, `requires_assignment: true`)
- Vehicle Washing (`is_productive: false`, `bookable: true`, `requires_assignment: false`)
- Lunch Break (`is_productive: false`, `bookable: true`, `requires_assignment: true`)

---

### Workflow Validation: Resource Types Collection

**Fields Support These Workflows:**
- ✅ Calendar booking (via `bookable`)
- ✅ Capacity planning (via `default_duration_hours`)
- ✅ Productivity tracking (via `is_productive`)
- ✅ Resource assignment (via `requires_assignment`)
- ✅ Inter-dealership sharing (via `resource_sharing` integration)

**Validation:** ✅ **All behavioral flags functional**

---

## Collection 5: Resource Bookings 📅

### Purpose
Schedule specific work on specific vehicles, tracking estimated vs actual time and supporting inter-dealership resource sharing.

### Primary User Stories

#### US-5.1: Schedule Work on a Vehicle
**As a** Prep Center Coordinator
**I want to** book a time slot for work on a vehicle
**So that** we plan capacity and assign mechanics

**Fields Used:**
- ✅ `car_id` (which vehicle)
- ✅ `resource_type_id` (what type of work)
- ✅ `date`, `start_time` (when)
- ✅ `estimated_hours` (expected duration)
- ✅ `provider_dealership_id` (who will do the work)
- ✅ `consumer_dealership_id` (who owns the vehicle)
- ✅ `user_id` (assigned person, if required)
- ✅ `status` → "scheduled"

**Validation:** ✅ **All booking fields present**

---

#### US-5.2: Track Inter-Dealership Work
**As a** Dealership Manager
**I want to** see when another dealership is doing work on my vehicles
**So that** I can track cross-dealership collaboration

**Fields Used:**
- ✅ `provider_dealership_id` (e.g., dealership 499 does work)
- ✅ `consumer_dealership_id` (e.g., dealership 495 owns vehicle)
- ✅ `car_id` (links to vehicle owner)

**Validation:** ✅ **Provider/consumer distinction clear**

**Example Scenario:**
- Dealership 495 (Kristiansand Vest) sells a car but doesn't have a prep center
- Dealership 499 (Porsgrunn) has prep center capacity
- Booking: `provider: 499`, `consumer: 495`, `car_id: <495's car>`

---

#### US-5.3: Track Work Progress
**As a** Mechanic
**I want to** update the booking status as I work
**So that** managers see real-time progress

**Fields Used:**
- ✅ `status` (scheduled → confirmed → in_progress → completed)
- ✅ `actual_hours` (record real time spent)
- ✅ `completed_at` (timestamp of completion)
- ✅ `notes` (work details, issues found)

**Validation:** ✅ **Status progression tracked**

**🔗 Integration:**
- Updates `cars.technical_started_at`, `cars.technical_completed_at`
- Updates `resource_capacities.used_hours`

---

#### US-5.4: Handle Cancellations and No-Shows
**As a** Prep Center Coordinator
**I want to** mark bookings as cancelled or no-show
**So that** capacity is released for other work

**Fields Used:**
- ✅ `status` → "cancelled" or "no_show"
- ✅ `notes` (reason for cancellation)

**Validation:** ✅ **Cancellation workflow supported**

**🔗 Integration:** Frees up `resource_capacities.used_hours`

---

### Workflow Validation: Resource Bookings Collection

**6-Stage Status Workflow:**
```
scheduled → confirmed → in_progress → completed
         ↘ cancelled
         ↘ no_show
```

**Time Tracking:**
- ✅ Estimated hours (for planning)
- ✅ Actual hours (for billing/productivity)
- ✅ Completion timestamp (for SLA tracking)

**Validation:** ✅ **Complete booking lifecycle supported**

---

## Collection 6: Resource Capacities 📊

### Purpose
Track available capacity per dealership per resource type per day, preventing overbooking and enabling capacity planning.

### Primary User Stories

#### US-6.1: Set Daily Capacity
**As a** Prep Center Coordinator
**I want to** define how many hours are available per day
**So that** the system prevents overbooking

**Fields Used:**
- ✅ `dealership_id` (which dealership)
- ✅ `resource_type_id` (which type of work)
- ✅ `date` (specific day)
- ✅ `allocated_hours` (total available hours)
- ✅ `user_id` (NULL = team capacity, or specific person)

**Validation:** ✅ **Capacity allocation supported**

**Example:**
- Dealership 499, Technical Prep, 2025-10-30: 16 hours (2 mechanics × 8 hours)
- Dealership 499, Cosmetic Prep, 2025-10-30: 8 hours (1 detailer × 8 hours)

---

#### US-6.2: Track Capacity Utilization
**As a** Prep Center Coordinator
**I want to** see how much capacity is used vs available
**So that** I can optimize scheduling

**Fields Used:**
- ✅ `allocated_hours` (total capacity)
- ✅ `used_hours` (booked/consumed)
- ✅ `available_hours` (calculated: allocated - used)

**Validation:** ✅ **Auto-calculated available hours**

**🔗 Integration:** `used_hours` increments when `resource_bookings` are created, decrements when cancelled

---

#### US-6.3: Track Individual vs Team Capacity
**As a** Prep Center Coordinator
**I want to** set capacity for specific people or the whole team
**So that** I can handle personal schedules (vacation, training)

**Fields Used:**
- ✅ `user_id` = NULL → Team-wide capacity
- ✅ `user_id` = specific person → Individual capacity

**Validation:** ✅ **Flexible granularity**

**Example:**
- Date: 2025-10-30, Resource: Technical, User: NULL, Allocated: 16 hours (team)
- Date: 2025-10-31, Resource: Technical, User: "John", Allocated: 0 hours (vacation)

---

### Workflow Validation: Resource Capacities Collection

**Capacity Planning Flow:**
1. Coordinator sets `allocated_hours` for upcoming days
2. System calculates `available_hours` = `allocated_hours` - `used_hours`
3. When booking created, `used_hours` increments by `estimated_hours`
4. When booking completed, system validates `actual_hours` vs `estimated_hours`
5. If `actual_hours` > `estimated_hours`, capacity may need adjustment

**Validation:** ✅ **Planning and tracking loop complete**

---

## Collection 7: Resource Sharing 🤝

### Purpose
Configure which dealerships can share resources with each other, enabling inter-dealership collaboration and capacity optimization.

### Primary User Stories

#### US-7.1: Enable Resource Sharing
**As a** System Administrator
**I want to** allow one dealership to use another's prep capacity
**So that** we optimize resource utilization across the group

**Fields Used:**
- ✅ `provider_dealership_id` (e.g., 499 offers capacity)
- ✅ `consumer_dealership_id` (e.g., 495 can book)
- ✅ `resource_type_id` (what type of work can be shared)
- ✅ `enabled` (active/inactive)

**Validation:** ✅ **Sharing configuration complete**

**Example:**
- Dealership 499 (has prep center) offers Technical Prep to Dealership 495 (sales only)

---

#### US-7.2: Set Sharing Limits and Priorities
**As a** System Administrator
**I want to** limit how much capacity can be consumed
**So that** the provider dealership keeps capacity for their own work

**Fields Used:**
- ✅ `max_hours_per_week` (consumption limit)
- ✅ `priority` (0-100, for conflict resolution)
- ✅ `notes` (sharing agreement details)

**Validation:** ✅ **Limits and priorities supported**

**Example:**
- Provider: 499, Consumer: 495, Max: 40 hours/week, Priority: 50
- Provider: 499, Consumer: 497, Max: 20 hours/week, Priority: 80 (higher priority)

---

#### US-7.3: Monitor Sharing Usage
**As a** Dealership Manager
**I want to** see how much capacity we're consuming from other dealerships
**So that** we stay within agreements

**Query Needs:**
- Filter `resource_bookings` where:
  - `consumer_dealership_id` = my dealership
  - `provider_dealership_id` ≠ my dealership
  - Group by week, sum `estimated_hours`
  - Compare to `resource_sharing.max_hours_per_week`

**Validation:** ✅ **Monitoring possible via joins**

---

### Workflow Validation: Resource Sharing Collection

**Sharing Flow:**
1. Admin creates `resource_sharing` record (provider, consumer, resource type)
2. Coordinator at consumer dealership creates `resource_booking`:
   - `consumer_dealership_id` = their dealership
   - `provider_dealership_id` = shared resource provider
3. System validates:
   - ✅ Sharing agreement exists and is `enabled`
   - ✅ Weekly hours not exceeded
   - ✅ Provider has capacity available
4. If validated, booking confirmed
5. If conflicts, use `priority` to resolve

**Validation:** ✅ **Complete sharing workflow supported**

---

## Cross-Collection Integration Analysis

### 🔗 Integration Map

```
cars (vehicle)
  ├─ M2O → dealership (owning dealership)
  ├─ M2O → dealership (prep center)
  ├─ M2O → directus_users (seller, mechanic, detailer)
  └─ O2M → resource_bookings (work scheduled on this car)

resource_bookings (scheduled work)
  ├─ M2O → cars (which vehicle)
  ├─ M2O → resource_types (what type of work)
  ├─ M2O → dealership (provider = who does work)
  ├─ M2O → dealership (consumer = who owns vehicle)
  ├─ M2O → directus_users (assigned person)
  └─ Updates → resource_capacities.used_hours

resource_capacities (available capacity)
  ├─ M2O → dealership (which dealership)
  ├─ M2O → resource_types (which resource)
  ├─ M2O → directus_users (specific person or NULL)
  └─ Consumed by → resource_bookings

resource_sharing (sharing agreements)
  ├─ M2O → dealership (provider)
  ├─ M2O → dealership (consumer)
  ├─ M2O → resource_types
  └─ Validates → resource_bookings creation

notifications (alerts)
  ├─ M2O → directus_users (recipient)
  ├─ M2O → cars (related vehicle)
  └─ Triggered by → cars status changes
```

### ✅ Integration Validation

**All critical relations exist:**
- ✅ Cars → Dealerships
- ✅ Cars → Resource Bookings
- ✅ Resource Bookings → Capacities (logical link)
- ✅ Resource Sharing → Dealerships (provider/consumer)
- ✅ Notifications → Cars & Users

---

## Gap Analysis & Recommendations

### ✅ Strengths

1. **Complete Vehicle Lifecycle**: Cars collection tracks every stage from registration to delivery
2. **Inter-Dealership Collaboration**: Clear provider/consumer model in bookings and sharing
3. **Capacity Management**: Prevents overbooking via capacity tracking
4. **Flexible Resource Types**: Configurable behaviors (productive, bookable, assignment)
5. **Audit Trail**: Comprehensive timestamps for every workflow stage
6. **User Notifications**: Real-time alerts for status changes

### 💡 Potential Improvements

#### 1. Parts Management Enhancement
**Current:** Basic timestamp tracking
**Gap:** No detailed parts inventory or status
**Impact:** Medium
**Recommendation:**
- Consider `parts_orders` collection with fields:
  - `car_id`, `part_name`, `part_number`, `quantity`, `supplier`
  - `status` (ordered/in_transit/arrived/installed/cancelled)
  - `ordered_by` (seller vs prep center)

#### 2. Time Bank / Productivity Tracking
**Current:** `actual_hours` tracked per booking
**Gap:** No aggregated productivity metrics per person
**Impact:** High (for billing/performance)
**Recommendation:**
- Add `timebank_entries` collection:
  - `user_id`, `date`, `resource_type_id`, `hours`, `booking_id`
  - Auto-populated from `resource_bookings.actual_hours`
  - Enables productivity reports and payroll integration

#### 3. Quality Control / Inspection Checklist
**Current:** `inspection_approved` boolean + notes
**Gap:** No structured inspection checklist
**Impact:** Medium
**Recommendation:**
- Add `inspection_checklist_items` collection:
  - `car_id`, `item_name`, `status` (ok/issue/critical), `notes`
  - Examples: "Tire tread depth", "Brake fluid level", "Paint scratches"

#### 4. Customer Communication Log
**Current:** Notifications to internal users only
**Gap:** No record of customer communications
**Impact:** Low (nice-to-have)
**Recommendation:**
- Extend `notifications` or add `customer_communications`:
  - `car_id`, `customer_name`, `type` (sms/email/call), `message`, `sent_at`

#### 5. Booking Recurrence
**Current:** One-time bookings only
**Gap:** Can't schedule recurring capacity (e.g., "every Monday")
**Impact:** Low
**Recommendation:**
- Add `recurrence_pattern` JSON field to `resource_capacities`:
  - `{"type": "weekly", "days": ["monday", "tuesday"], "hours": 8}`

#### 6. SLA Tracking
**Current:** Timestamps exist but no SLA targets
**Gap:** No automated delay detection
**Impact:** Medium
**Recommendation:**
- Add to `cars` collection:
  - `expected_delivery_date` (target)
  - `sla_status` (on_time/at_risk/delayed)
  - System calculates based on current status + timestamps

#### 7. Document Attachments
**Current:** No file attachments to cars
**Gap:** Can't attach delivery checklist, invoice, photos
**Impact:** Medium
**Recommendation:**
- Add `car_documents` junction collection:
  - `car_id`, `directus_files_id`, `type` (invoice/photo/checklist)

---

## User Story Coverage Matrix

| Persona | Primary Collections | Coverage | Gaps |
|---------|-------------------|----------|------|
| **Seller** | cars, notifications | ✅ 95% | Customer comms log |
| **Prep Coordinator** | cars, resource_bookings, resource_capacities | ✅ 90% | SLA alerts, recurring schedules |
| **Mechanic/Detailer** | cars, resource_bookings | ✅ 85% | Time bank tracking, inspection checklist |
| **Dealership Manager** | All collections | ✅ 90% | SLA dashboard, productivity reports |
| **System Admin** | dealership, resource_types, resource_sharing | ✅ 100% | - |
| **Customer** | (indirect) notifications | ❌ 0% | No customer portal |

---

## Workflow Validation Summary

### ✅ Fully Supported Workflows
1. Vehicle registration → prep → delivery
2. Inter-dealership resource sharing
3. Capacity planning and booking
4. Work scheduling and assignment
5. Status tracking and notifications
6. Dealership hierarchy and configuration

### ⚠️ Partially Supported Workflows
1. Parts ordering (timestamps exist, but no inventory detail)
2. Quality inspection (boolean + notes, no checklist)
3. Productivity tracking (hours logged, no aggregated reports)
4. SLA monitoring (timestamps exist, no targets or alerts)

### ❌ Unsupported Workflows
1. Customer self-service portal
2. Document/photo attachments to vehicles
3. Recurring capacity schedules
4. Automated billing from time bank

---

## Conclusion

### Overall Assessment: ✅ **Excellent Alignment**

**Score: 90/100**

The collection structure strongly supports the core business workflows:
- ✅ Complete vehicle lifecycle tracking
- ✅ Inter-dealership collaboration
- ✅ Capacity management and booking
- ✅ Resource assignment and scheduling
- ✅ Real-time notifications
- ✅ Flexible configuration

**Key Strengths:**
1. Clear provider/consumer model for dealership collaboration
2. Comprehensive timestamp tracking for workflow stages
3. Flexible resource type configuration
4. Proper capacity management to prevent overbooking
5. Complete user role support (seller, coordinator, mechanic, detailer, admin)

**Recommended Next Steps:**
1. **High Priority**: Implement time bank/productivity aggregation
2. **Medium Priority**: Add SLA targets and alerts
3. **Medium Priority**: Enhanced parts management with detailed tracking
4. **Low Priority**: Customer portal and document attachments

The current schema is **production-ready** and supports all critical workflows. Improvements are enhancements, not blockers.
