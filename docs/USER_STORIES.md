# User Stories - DirectApp

**Version:** 1.0.0
**Date:** 2025-10-28
**Status:** Active

---

## Overview

This document contains user stories for all roles in the DirectApp system. User stories follow the format:

> **As a** [role]
> **I want to** [action]
> **So that** [benefit]

Each story includes acceptance criteria and relates to specific workflow states.

---

## Table of Contents

1. [Nybilselger (New Car Sales)](#nybilselger-new-car-sales)
2. [Bruktbilselger (Used Car Sales)](#bruktbilselger-used-car-sales)
3. [Mottakskontrollør (Reception Inspector)](#mottakskontrollør-reception-inspector)
4. [Kundemottaker / Booking (Workshop Planner)](#kundemottaker--booking-workshop-planner)
5. [Mekaniker (Mechanic - Technical Prep)](#mekaniker-mechanic---technical-prep)
6. [Bilpleiespesialist (Cosmetic Specialist)](#bilpleiespesialist-cosmetic-specialist)
7. [Delelager (Parts Department)](#delelager-parts-department)
8. [Daglig Leder (Manager)](#daglig-leder-manager)
9. [Salgsjef (Sales Manager)](#salgsjef-sales-manager)

---

## Nybilselger (New Car Sales)

### US-NS-001: Register New Car Order Manually

**As a** Nybilselger
**I want to** manually register a new car order with all required fields, without seeing the fields for used cars
**So that** the vehicle enters the preparation workflow

**Acceptance Criteria:**
- Can fill in all required fields: VIN, order number, customer name, make/model, delivery date estimate
- System auto-fills seller name and dealership from logged-in user
- Can add accessories/equipment list
- Can save draft before submitting
- System validates VIN format before accepting
- Order is immediately visible to parts department
- Status is set to `ny_ordre` after submission

**Related Collections:** `cars`
**Priority:** High
**Workflow State:** Creates `ny_ordre`

---

### US-NS-002: Upload and Parse Order PDF

**As a** Nybilselger
**I want to** upload an order confirmation PDF and have it automatically parsed
**So that** I don't have to manually enter all order details

**Acceptance Criteria:**
- Can upload PDF file via drag-and-drop or file picker
- System extracts: VIN, order number, customer info, vehicle specs, accessories
- Shows preview of parsed data before confirming
- Can edit any parsed field before submission
- Handles common VW/Audi/Skoda PDF formats
- Shows clear error if PDF cannot be parsed
- Falls back to manual entry if parsing fails

**Related Collections:** `cars`, `cars_files`
**Related Extensions:** `directus-extension-parse-order-pdf`
**Priority:** High
**Workflow State:** Creates `ny_ordre`

---

### US-NS-003: View Only My Dealership's New Cars

**As a** Nybilselger
**I want to** see only new cars belonging to my dealership
**So that** I don't get confused by other dealerships' inventory

**Acceptance Criteria:**
- Default view shows only `type: 'ny'` (new) AND my `dealership_id`
- Cannot see other dealerships' cars in standard views
- Search and filters respect dealership boundary
- Dashboard counts only my dealership's vehicles
- Clear indication of dealership in all list views

**Related Collections:** `cars`, `dealership`
**Priority:** High
**Security:** Critical - data isolation

---

### US-NS-004: Edit Sales-Related Fields Only

**As a** Nybilselger
**I want to** edit customer info, price, accessories, and delivery date
**So that** I can keep order details current without interfering with workshop processes

**Acceptance Criteria:**
- Can edit: customer name/contact, sales price, accessories, delivery date estimate, sales comments
- Cannot edit: workshop fields, booking dates, parts status, mechanical/cosmetic completion
- System prevents saving if attempting to edit restricted fields
- Changes trigger notification to parts department if accessories changed
- Edit history is logged with timestamp and user

**Related Collections:** `cars`
**Priority:** Medium
**Workflow State:** Any state where car belongs to seller

---

### US-NS-005: Receive Notifications on Vehicle Status Changes

**As a** Nybilselger
**I want to** receive notifications when my vehicles reach key milestones
**So that** I can keep customers informed about delivery progress

**Acceptance Criteria:**
- Notification when accessories list is modified by others
- Notification when reception inspection is completed (approved/rejected)
- Notification when vehicle is ready for delivery (`klar_for_levering`)
- Notification includes: VIN, customer name, status, relevant notes/photos
- Can view notification history
- Can configure notification preferences (email, in-app, both)

**Related Collections:** `cars`, `directus_notifications`
**Related Extensions:** `directus-extension-send-email`
**Priority:** High
**Workflow States:** `mottakskontroll_godkjent`, `klar_for_levering`

---

### US-NS-006: View Vehicle Preparation Progress

**As a** Nybilselger
**I want to** see the current status and progress of each vehicle
**So that** I can answer customer questions about delivery timing

**Acceptance Criteria:**
- Dashboard shows vehicles grouped by status
- Timeline view shows: order date, parts ordered, reception check, workshop dates, completion
- Can see photos uploaded during reception and preparation
- Can see mechanic/specialist comments
- Shows estimated completion date based on scheduled work
- Visual progress indicator (e.g., 60% complete)

**Related Collections:** `cars`, `cars_files`
**Priority:** Medium
**Workflow States:** All states

---

### US-NS-007: Mark Vehicle as Delivered to Customer

**As a** Nybilselger
**I want to** mark a vehicle as delivered to the end customer
**So that** the order can be completed and archived

**Acceptance Criteria:**
- Can only mark as delivered if status is `levert_til_selgerforhandler` (returned to selling dealership)
- Must enter delivery date
- Can add delivery notes
- Status changes to `solgt_og_levert`
- Vehicle automatically archives after configured period (e.g., 30 days)
- Cannot edit archived vehicles

**Related Collections:** `cars`
**Priority:** Medium
**Workflow State:** `levert_til_selgerforhandler` → `solgt_og_levert`

---

## Bruktbilselger (Used Car Sales)

### US-BS-001: Register Used Car Manually

**As a** Bruktbilselger
**I want to** manually register a used car acquisition
**So that** it enters the preparation workflow

**Acceptance Criteria:**
- Can fill in: VIN or license plate, purchase price, customer name (if applicable), vehicle details
- System auto-fills seller name and dealership
- Can specify if trade-in or direct purchase
- Can add condition notes
- Status set to `ny_ordre` after submission

**Related Collections:** `cars`
**Priority:** High
**Workflow State:** Creates `ny_ordre`

---

### US-BS-002: Look Up Vehicle from Statens Vegvesen

**As a** Bruktbilselger
**I want to** enter a VIN or license plate and automatically fetch vehicle details from Statens Vegvesen
**So that** I don't have to manually enter make, model, year, specifications

**Acceptance Criteria:**
- Can enter VIN (17 characters) or Norwegian license plate
- System queries Statens Vegvesen API
- Auto-fills: make, model, year, color, first registration date, technical specs
- Shows vehicle history if available
- Allows manual override of any field
- Clear error message if vehicle not found or API unavailable

**Related Collections:** `cars`
**Related Extensions:** `directus-extension-vehicle-lookup`, `directus-extension-vehicle-lookup-button`
**Priority:** High
**External API:** Statens Vegvesen

---

### US-BS-003: Search Across All Dealerships

**As a** Bruktbilselger
**I want to** search for used cars across all dealerships in the organization
**So that** I can find vehicles for customers even if not at my location

**Acceptance Criteria:**
- Search panel accessible from dashboard
- Can filter by: make, model, year, price range, location/dealership, status
- Results show all matching used cars regardless of dealership
- Results clearly indicate which dealership has each vehicle
- Can view details but cannot edit vehicles from other dealerships
- Can contact other dealership (link to user/phone)

**Related Collections:** `cars`, `dealership`, `directus_users`
**Related Extensions:** `directus-extension-vehicle-search`
**Priority:** High
**Security:** Exception to standard data isolation

---

### US-BS-004: View My Dealership's Used Cars by Default

**As a** Bruktbilselger
**I want to** see my dealership's used cars in my main view
**So that** I focus on vehicles I'm responsible for selling

**Acceptance Criteria:**
- Default view filters `type: 'brukt'` (used) AND my `dealership_id`
- Cross-dealership search is a separate feature, not default
- Dashboard counts only my dealership's used cars
- Clear visual distinction between default view and cross-dealership search results

**Related Collections:** `cars`, `dealership`
**Priority:** High

---

### US-BS-005: Edit Used Car Sales Fields

**As a** Bruktbilselger
**I want to** edit purchase price, sales price, accessories, and customer info
**So that** I can manage the used car sales process

**Acceptance Criteria:**
- Can edit: customer info, purchase/trade-in price, sales price, accessories, delivery date, sales comments
- Cannot edit: workshop fields, booking, parts status, mechanical/cosmetic completion
- Changes to accessories trigger notification to parts department
- Edit history logged

**Related Collections:** `cars`
**Priority:** Medium

---

### US-BS-006: Receive Status Notifications

**As a** Bruktbilselger
**I want to** receive notifications when used cars reach milestones
**So that** I can coordinate sales and delivery

**Acceptance Criteria:**
- Same notification triggers as Nybilselger (accessories changed, reception done, ready for delivery)
- Notifications clearly identify vehicle by VIN/license plate
- Can view and configure notifications

**Related Collections:** `cars`, `directus_notifications`
**Priority:** High

---

## Mottakskontrollør (Reception Inspector)

### US-REC-001: View All Newly Arrived Vehicles

**As a** Mottakskontrollør
**I want to** see all vehicles that have physically arrived at the preparation center
**So that** I can prioritize my inspection workload

**Acceptance Criteria:**
- Dashboard shows vehicles with status `deler_ankommet_klargjoring` (parts arrived, awaiting inspection)
- List shows: VIN, make/model, selling dealership, arrival date (if known)
- Can sort by arrival date, dealership, vehicle type
- Count of pending inspections prominently displayed

**Related Collections:** `cars`, `dealership`
**Priority:** High
**Workflow State:** `deler_ankommet_klargjoring`

---

### US-REC-002: Scan Key Tag to Find Vehicle

**As a** Mottakskontrollør
**I want to** scan or photograph a key tag and have the system find the matching vehicle
**So that** I can quickly identify vehicles without manually searching by VIN

**Acceptance Criteria:**
- Can activate camera from mobile or tablet
- System performs OCR on key tag image
- Extracts VIN or order number
- Automatically opens matching vehicle record
- If vehicle not found, offers to create "orphan" entry with extracted info
- Shows clear error if OCR fails with option to retry

**Related Collections:** `cars`
**Related Extensions:** `directus-extension-key-tag-scanner`
**Priority:** High
**Technology:** OCR

---

### US-REC-003: Perform Reception Inspection

**As a** Mottakskontrollør
**I want to** perform a structured inspection and document condition
**So that** the workshop knows what work is required

**Acceptance Criteria:**
- Inspection form includes: overall condition, damages/defects checklist, cleanliness, missing items
- Three outcomes:
  - ✅ Approved without remarks
  - ⚠️ Approved with remarks (requires notes + photos)
  - ❌ Not approved (blocks further processing, requires notes + photos)
- Must provide photos if any defects/remarks
- Can add free-text comments
- Estimated inspection time: 0.5 hours (reference only)

**Related Collections:** `cars`, `cars_files`
**Priority:** High
**Workflow State:** `deler_ankommet_klargjoring` → `mottakskontroll_godkjent` or `mottakskontroll_avvik`

---

### US-REC-004: Upload Inspection Photos

**As a** Mottakskontrollør
**I want to** upload multiple photos documenting vehicle condition
**So that** workshop staff and sellers have visual reference

**Acceptance Criteria:**
- Can upload multiple photos (JPG, PNG) via drag-and-drop or camera
- Can add caption/description per photo
- Photos are tagged with inspection date and user
- Photos linked to vehicle record
- Can view all photos in gallery view
- Mobile-optimized for tablet use

**Related Collections:** `cars_files`
**Priority:** High

---

### US-REC-005: Notify Seller of Inspection Results

**As a** Mottakskontrollør
**I want to** the seller to be automatically notified when I complete inspection
**So that** they know the vehicle status without me manually contacting them

**Acceptance Criteria:**
- Notification sent immediately upon marking inspection complete
- Notification content depends on outcome:
  - Approved: "Vehicle [VIN] received and approved without remarks"
  - Approved with remarks: "Vehicle [VIN] received with following remarks: [list]"
  - Not approved: "Vehicle [VIN] failed inspection: [issues]"
- Notification includes link to vehicle record
- Photos automatically attached/linked

**Related Collections:** `cars`, `directus_notifications`
**Related Extensions:** `directus-extension-send-email`
**Priority:** High
**Workflow State:** `mottakskontroll_godkjent`

---

## Kundemottaker / Booking (Workshop Planner)

### US-BOOK-001: View Vehicles Ready for Planning

**As a** Kundemottaker
**I want to** see all vehicles that passed inspection and need workshop scheduling
**So that** I can plan technical and cosmetic preparation

**Acceptance Criteria:**
- Dashboard shows vehicles with status `mottakskontroll_godkjent`
- List displays: VIN, make/model, inspection notes, parts availability, priority/delivery date
- Can filter by dealership, urgency, vehicle type
- Count of unscheduled vehicles displayed

**Related Collections:** `cars`
**Priority:** High
**Workflow State:** `mottakskontroll_godkjent`

---

### US-BOOK-002: Schedule Technical Preparation

**As a** Kundemottaker
**I want to** assign a date and optionally a mechanic for technical preparation
**So that** workshop resources are allocated efficiently

**Acceptance Criteria:**
- Calendar view shows available time slots
- Can select date for technical work
- Can optionally assign specific mechanic or leave unassigned
- System calculates time required:
  - New car: 2.5 hours
  - Used car: 1.5 hours (default, can adjust)
- Warns if time bank (daily capacity) is full
- Status changes to `planlagt_teknisk` when saved

**Related Collections:** `cars`, `directus_users` (mechanics)
**Priority:** High
**Workflow State:** `mottakskontroll_godkjent` → `planlagt_teknisk`

---

### US-BOOK-003: Schedule Cosmetic Preparation

**As a** Kundemottaker
**I want to** assign a date and optionally a specialist for cosmetic preparation
**So that** detailing work is planned

**Acceptance Criteria:**
- Calendar view shows available time slots (can be different from technical calendar)
- Can select date for cosmetic work
- Can optionally assign specific specialist or leave unassigned
- System calculates time required:
  - New car: 2.5 hours
  - Used car: 1.5 hours (default, can adjust)
- Warns if time bank is full
- Status changes to `planlagt_kosmetisk` when saved
- Can schedule technical and cosmetic on same or different days

**Related Collections:** `cars`, `directus_users` (specialists)
**Priority:** High
**Workflow State:** `mottakskontroll_godkjent` → `planlagt_kosmetisk`

---

### US-BOOK-004: View Workshop Calendar

**As a** Kundemottaker
**I want to** see a calendar view of all scheduled work
**So that** I can visualize capacity and avoid overbooking

**Acceptance Criteria:**
- Calendar shows day/week/month views
- Each booking shows: vehicle (make/model/VIN), assigned mechanic/specialist, estimated hours
- Color-coded by: technical vs cosmetic, dealership, urgency
- Shows available capacity per day (time bank remaining)
- Can drag-and-drop to reschedule
- Can filter by mechanic/specialist to see individual workloads

**Related Collections:** `cars`, `directus_users`
**Related Extensions:** `directus-extension-workshop-calendar`
**Priority:** High

---

### US-BOOK-005: Receive Inspection Completion Notifications

**As a** Kundemottaker
**I want to** be notified when vehicles complete reception inspection
**So that** I can promptly schedule them

**Acceptance Criteria:**
- Notification when vehicle status changes to `mottakskontroll_godkjent`
- Notification includes: VIN, make/model, inspection notes, priority
- Can click to immediately schedule
- Can configure notification timing (immediate, daily digest)

**Related Collections:** `cars`, `directus_notifications`
**Priority:** Medium

---

## Mekaniker (Mechanic - Technical Prep)

### US-MECH-001: View My Daily Schedule

**As a** Mekaniker
**I want to** see my assigned vehicles for today and upcoming days
**So that** I know what work is planned for me

**Acceptance Criteria:**
- Calendar shows day/week views
- Shows only vehicles assigned to me
- Each entry displays: time slot, vehicle (make/model/VIN), estimated hours, special notes
- Can mark work as started/in-progress
- Clear indication of current day and current time
- Mobile-friendly for tablet use in workshop

**Related Collections:** `cars`, `directus_users`
**Priority:** High

---

### US-MECH-002: Mark Technical Work Complete

**As a** Mekaniker
**I want to** mark technical preparation as complete with notes
**So that** the vehicle can proceed to cosmetic preparation or delivery

**Acceptance Criteria:**
- Can mark vehicle as "Teknisk ferdig" (technical complete)
- Must add completion notes (what was done)
- Can upload before/after photos
- Can log actual hours worked vs estimated
- Status changes to `teknisk_ferdig`
- Timestamp and user logged

**Related Collections:** `cars`, `cars_files`
**Priority:** High
**Workflow State:** `planlagt_teknisk` → `teknisk_ferdig`

---

### US-MECH-003: Upload Work Photos

**As a** Mekaniker
**I want to** upload photos during or after technical work
**So that** there's documentation of work completed

**Acceptance Criteria:**
- Can upload photos from mobile/tablet camera
- Can add caption per photo
- Photos tagged as "technical preparation"
- Linked to vehicle record and visible to seller

**Related Collections:** `cars_files`
**Priority:** Medium

---

### US-MECH-004: Add Work Notes and Comments

**As a** Mekaniker
**I want to** add notes about work performed and any issues discovered
**So that** sellers and other staff are informed

**Acceptance Criteria:**
- Free-text comment field
- Can add multiple comments over time
- Each comment timestamped and attributed to user
- Comments visible to seller and workshop planner

**Related Collections:** `cars`
**Priority:** Medium

---

### US-MECH-005: View Vehicle Order Details

**As a** Mekaniker
**I want to** see the order details and accessories list
**So that** I know what equipment to install

**Acceptance Criteria:**
- Can view (read-only): VIN, make/model, customer name, accessories list, delivery date
- Can see photos from reception inspection
- Can see any special instructions from seller
- Cannot edit order information

**Related Collections:** `cars`
**Priority:** Medium

---

## Bilpleiespesialist (Cosmetic Specialist)

### US-COS-001: View My Daily Schedule

**As a** Bilpleiespesialist
**I want to** see my assigned vehicles for today and upcoming days
**So that** I know what cosmetic work is planned for me

**Acceptance Criteria:**
- Calendar shows day/week views
- Shows only vehicles assigned to me
- Each entry displays: time slot, vehicle (make/model/VIN), estimated hours, special notes
- Can mark work as started
- Mobile-friendly for tablet

**Related Collections:** `cars`, `directus_users`
**Priority:** High

---

### US-COS-002: Mark Cosmetic Work Complete

**As a** Bilpleiespesialist
**I want to** mark cosmetic preparation as complete with notes
**So that** the vehicle can proceed to delivery

**Acceptance Criteria:**
- Can mark vehicle as "Kosmetisk ferdig" (cosmetic complete)
- Must add completion notes (what was done: wash, polish, interior clean, etc.)
- Can upload before/after photos
- Can log actual hours worked
- Status changes to `kosmetisk_ferdig`
- Timestamp and user logged

**Related Collections:** `cars`, `cars_files`
**Priority:** High
**Workflow State:** `planlagt_kosmetisk` → `kosmetisk_ferdig`

---

### US-COS-003: Upload Work Photos

**As a** Bilpleiespesialist
**I want to** upload photos showing cosmetic work results
**So that** sellers can show customers the vehicle condition

**Acceptance Criteria:**
- Can upload photos from camera
- Can add captions
- Photos tagged as "cosmetic preparation"
- High-quality photo viewing for customer presentation

**Related Collections:** `cars_files`
**Priority:** High

---

### US-COS-004: Add Work Notes

**As a** Bilpleiespesialist
**I want to** document work performed and any issues
**So that** there's a record of cosmetic preparation

**Acceptance Criteria:**
- Free-text comment field
- Can note: condition before work, what was done, products used, time taken
- Comments timestamped and attributed

**Related Collections:** `cars`
**Priority:** Medium

---

### US-COS-005: View Vehicle Details

**As a** Bilpleiespesialist
**I want to** see order details and reception notes
**So that** I know if there are special considerations (e.g., existing damage)

**Acceptance Criteria:**
- Can view (read-only): VIN, make/model, reception inspection notes and photos
- Can see any damage documented during inspection
- Cannot edit order information

**Related Collections:** `cars`
**Priority:** Medium

---

## Delelager (Parts Department)

### US-PARTS-001: View New Orders Requiring Parts

**As a** Delelager
**I want to** see all new orders with accessories lists
**So that** I can order required parts

**Acceptance Criteria:**
- Dashboard shows vehicles with status `ny_ordre`
- Filtered to show only vehicles for my dealership
- List displays: VIN, make/model, seller, accessories list, delivery date
- Highlights urgent orders (near delivery date)
- Count of pending parts orders

**Related Collections:** `cars`, `dealership`
**Priority:** High
**Workflow State:** `ny_ordre`

---

### US-PARTS-002: Order Parts and Upload Confirmation

**As a** Delelager
**I want to** mark parts as ordered and upload order confirmation documents
**So that** there's a record of what was ordered and when

**Acceptance Criteria:**
- Can mark "Deler bestilt" (parts ordered) with date
- Can upload PDF order confirmations via drag-and-drop
- Can upload photos of parts
- Can add notes about expected delivery
- Status changes to `deler_bestilt_selgerforhandler`

**Related Collections:** `cars`, `cars_files`
**Priority:** High
**Workflow State:** `ny_ordre` → `deler_bestilt_selgerforhandler`

---

### US-PARTS-003: Confirm Parts Arrival

**As a** Delelager at preparation center
**I want to** mark when parts physically arrive
**So that** workshop planning can begin

**Acceptance Criteria:**
- Can mark "Deler ankommet" (parts arrived) with date
- Can note any missing or incorrect parts
- Status changes to `deler_ankommet_klargjoring`
- Notification sent to workshop planner

**Related Collections:** `cars`
**Priority:** High
**Workflow State:** `deler_bestilt_selgerforhandler` → `deler_ankommet_klargjoring`

---

### US-PARTS-004: Receive Notifications on Accessory Changes

**As a** Delelager
**I want to** be notified when sellers modify accessories lists
**So that** I can adjust parts orders

**Acceptance Criteria:**
- Notification when accessories field is edited on existing order
- Shows what changed (added/removed items)
- Can compare old vs new accessories list
- Can click to view vehicle and update parts order

**Related Collections:** `cars`, `directus_notifications`
**Priority:** High

---

### US-PARTS-005: Edit Parts-Related Fields Only

**As a** Delelager
**I want to** edit parts ordering info without affecting sales or workshop data
**So that** I maintain data integrity

**Acceptance Criteria:**
- Can edit: parts ordered (yes/no, date), parts arrived (yes/no, date), parts notes
- Can upload/delete parts-related files
- Cannot edit: customer info, pricing, workshop scheduling, status (except parts-related status changes)
- Edit history logged

**Related Collections:** `cars`, `cars_files`
**Priority:** Medium

---

## Daglig Leder (Manager)

### US-MGR-001: View Dealership Dashboard

**As a** Daglig Leder
**I want to** see an overview of all vehicles and metrics for my dealership
**So that** I can monitor operations and performance

**Acceptance Criteria:**
- Dashboard shows:
  - Count of vehicles by status
  - Average time in each workflow stage
  - Vehicles nearing delivery date
  - Bottlenecks (e.g., stuck in one status too long)
- Can filter by date range, vehicle type, seller
- Visual charts for key metrics
- Comparison to previous period

**Related Collections:** `cars`, `dealership`, `directus_users`
**Related Extensions:** `directus-extension-vehicle-stats`
**Priority:** High

---

### US-MGR-002: View Per-Seller Performance

**As a** Daglig Leder
**I want to** see metrics broken down by individual sellers
**So that** I can identify top performers and provide coaching

**Acceptance Criteria:**
- Report shows per seller: number of orders, average time to delivery, customer issues
- Can filter by time period
- Sortable by various metrics
- Can drill down to see individual seller's vehicles
- Export to CSV/Excel

**Related Collections:** `cars`, `directus_users`
**Priority:** Medium

---

### US-MGR-003: Manage Users

**As a** Daglig Leder
**I want to** add, edit, and deactivate users at my dealership
**So that** I control who has access

**Acceptance Criteria:**
- Can create new users with role assignment
- Can assign users to my dealership only
- Can edit user info (name, email, role)
- Can deactivate (not delete) users
- Cannot access users from other dealerships (unless special permission)
- Audit log of user management actions

**Related Collections:** `directus_users`, `dealership`
**Priority:** High
**Security:** Critical

---

### US-MGR-004: Manage Custom Fields and Accessories

**As a** Daglig Leder
**I want to** add or remove accessory options available to my dealers
**So that** sellers have current product offerings

**Acceptance Criteria:**
- Can add new accessory items with description and price
- Can edit existing accessories
- Can deactivate obsolete accessories (not delete to preserve historical data)
- Changes apply only to my dealership
- Sellers see updated options immediately

**Related Collections:** Configuration (accessories list)
**Priority:** Medium

---

### US-MGR-005: Export Reports

**As a** Daglig Leder
**I want to** export data and reports to Excel/CSV
**So that** I can perform further analysis or share with management

**Acceptance Criteria:**
- Can export: vehicle lists, status reports, seller performance, time metrics
- CSV and Excel formats supported
- Can choose which columns to include
- Export respects current filters
- Includes metadata (export date, filter criteria)

**Related Collections:** `cars`, `directus_users`
**Priority:** Medium

---

### US-MGR-006: View All Objects Under My Dealership

**As a** Daglig Leder
**I want to** see all vehicles, users, and data for my dealership
**So that** I have complete visibility

**Acceptance Criteria:**
- Can access all collections filtered by my `dealership_id`
- Can view details but respect role-based edit restrictions
- Cannot see other dealerships' data unless granted special cross-dealership permission
- Clear indication of which dealership is currently selected if multi-dealership access granted

**Related Collections:** All collections with `dealership_id`
**Priority:** High
**Security:** Critical - data isolation

---

## Salgsjef (Sales Manager)

### US-SMGR-001: View Dealership Dashboard (Same as Daglig Leder)

**As a** Salgsjef
**I want to** see dealership overview and metrics
**So that** I can monitor sales operations

**Acceptance Criteria:**
- Same as US-MGR-001 (Daglig Leder dashboard)

**Priority:** High

---

### US-SMGR-002: View Per-Seller Performance (Same as Daglig Leder)

**As a** Salgsjef
**I want to** monitor individual seller performance
**So that** I can coach and manage the sales team

**Acceptance Criteria:**
- Same as US-MGR-002

**Priority:** High

---

### US-SMGR-003: Manage Users (Limited)

**As a** Salgsjef
**I want to** create and edit users but not delete them
**So that** I can onboard new sellers while maintaining accountability

**Acceptance Criteria:**
- Can create new users with role assignment
- Can edit user info (name, email, role)
- **Cannot** delete or permanently deactivate users
- Can request user deactivation from Daglig Leder
- Audit log of actions

**Related Collections:** `directus_users`, `dealership`
**Priority:** Medium

---

### US-SMGR-004: View and Filter All Vehicles

**As a** Salgsjef
**I want to** see all vehicles for my dealership with advanced filtering
**So that** I can identify issues and opportunities

**Acceptance Criteria:**
- Can filter by: status, seller, date range, vehicle type, delivery date
- Can save filter presets
- Can see vehicles that are delayed or stuck
- Can drill into vehicle details

**Related Collections:** `cars`
**Priority:** High

---

## Cross-Role Stories

### US-ALL-001: AI Assistant for Common Questions

**As a** any user
**I want to** ask an AI assistant questions about vehicles, processes, or data
**So that** I can quickly find information without navigating multiple screens

**Acceptance Criteria:**
- AI assistant accessible from any screen
- Can answer: "What's the status of VIN xxx?", "How many cars are pending inspection?", "Show me vehicles for customer [name]"
- Provides links to relevant records
- Learns from dealership-specific data
- Respects user permissions (only shows data user can access)

**Related Extensions:** `directus-extension-ask-cars-ai`
**Priority:** Medium
**Technology:** AI/LLM integration

---

### US-ALL-002: View Personal Notification Center

**As a** any user
**I want to** see all my notifications in one place
**So that** I don't miss important updates

**Acceptance Criteria:**
- Notification center shows all notifications for logged-in user
- Can filter by: read/unread, type, date
- Can mark as read/unread
- Can delete notifications
- Shows notification count badge
- Can configure which notifications to receive

**Related Collections:** `directus_notifications`
**Priority:** High

---

### US-ALL-003: Mobile-Responsive Interface

**As a** any user
**I want to** access the system from mobile/tablet
**So that** I can work from the workshop floor or sales area

**Acceptance Criteria:**
- All key functions work on mobile/tablet (iOS/Android)
- Touch-optimized controls
- Camera access for photos and key tag scanning
- Responsive layouts for different screen sizes
- Performance optimized for mobile networks

**Priority:** High
**Technology:** Responsive design, PWA

---

## Appendix: Workflow State Map

| Status | Norwegian | Roles Involved | Next State |
|--------|-----------|----------------|------------|
| `ny_ordre` | Ny ordre | Nybilselger/Bruktbilselger | `deler_bestilt_selgerforhandler` |
| `deler_bestilt_selgerforhandler` | Deler bestilt (selger) | Delelager (selling dealership) | `deler_ankommet_klargjoring` |
| `deler_ankommet_klargjoring` | Deler ankommet | Delelager (prep center) | `mottakskontroll_godkjent` |
| `mottakskontroll_godkjent` | Mottakskontroll godkjent | Mottakskontrollør | `planlagt_teknisk` / `planlagt_kosmetisk` |
| `mottakskontroll_avvik` | Mottakskontroll avvik | Mottakskontrollør | (Block, requires resolution) |
| `planlagt_teknisk` | Planlagt (teknisk) | Kundemottaker/Booking | `teknisk_ferdig` |
| `planlagt_kosmetisk` | Planlagt (kosmetisk) | Kundemottaker/Booking | `kosmetisk_ferdig` |
| `teknisk_ferdig` | Teknisk ferdig | Mekaniker | `klar_for_levering` (if cosmetic also done) |
| `kosmetisk_ferdig` | Kosmetisk ferdig | Bilpleiespesialist | `klar_for_levering` (if technical also done) |
| `klar_for_levering` | Klar for levering | System (automatic) | `levert_til_selgerforhandler` |
| `levert_til_selgerforhandler` | Levert til forhandler | Workshop staff | `solgt_og_levert` |
| `solgt_og_levert` | Solgt og levert | Seller | `arkivert` (after X days) |
| `arkivert` | Arkivert | System (automatic) | (Read-only, end state) |

---

## Notes

- This document will evolve as requirements are refined
- Each story should be estimated (story points) before sprint planning
- Acceptance criteria may need technical refinement during implementation
- Security and data isolation are critical for all stories involving data access
- All stories must respect the dealership multi-tenancy model

---

**Document maintained by:** Product Team
**Last review:** 2025-10-28
**Next review:** As needed during sprint planning
