# Sample Workflow: Monday, November 4, 2025

This document demonstrates a typical day using the DirectApp Task Tracker during Phase 1 implementation.

## Morning: 09:00 - Starting the Day

### Check Project Status

```bash
$ ./track-tasks.sh status

DirectApp Implementation Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tasks:     20
Completed:       0 (0.0%)
In Progress:     0
Pending:         20

Current Phase:   Phase 1: Critical Fixes & Quick Wins
Status:          PENDING
Target End:      2025-11-15

Progress Bar:
[--------------------------------------------------] 0.0%

Next Available Tasks:
IMP-001-T1: Analyze existing permission rules and data isolation gaps (Dev 1)
IMP-002-T1: Review ROLE_PERMISSIONS_PLAN.md for DELETE rules (Dev 1)
IMP-003-T1: Fix workflow-guard exception import (Dev 1)
IMP-004-T1: Add vehicle_lookup_action alias field to cars collection (Dev 1)
IMP-005-T1: Grant mekaniker role UPDATE permission on tech_completed_date (Dev 1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Key Observations:**
- Fresh start - 0% complete
- 5 tasks available to start (no dependencies)
- IMP-001-T1 is critical and blocks many other tasks

### Review First Task

```bash
$ ./track-tasks.sh show IMP-001-T1

Task Details: IMP-001-T1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title:           Analyze existing permission rules and data isolation gaps
Status:          PENDING
Priority:        CRITICAL
Assigned To:     Dev 1
Estimated:       2h
Actual:          N/A

Description:
  Read all collection permissions for 7 collections (cars, resource_bookings,
  resource_capacities, dealership, notifications, workshop_tasks, directus_users).
  Identify which collections lack dealership_id filter. Document current permission
  JSON. Create impact analysis document listing all roles that will be affected by
  changes.

Dependencies:    None
Blocks:          IMP-001-T2

Entry Criteria: (4 items)
  • Access to Directus admin panel (dev environment)
  • Access to mcp__directapp-dev__schema tool
  • Copy of ROLE_PERMISSIONS_PLAN.md available
  • List of all collections from schema tool

Exit Criteria: (5 items)
  • Document created: DATA_ISOLATION_IMPACT_ANALYSIS.md
  • List of 7 collections requiring updates
  • Current permission JSON documented for all 10 roles
  • Impact analysis includes: which roles affected, which queries will change
  • Admin role exception documented

Validation Checklist: (7 items)
  • Verify all non-system collections analyzed
  • Check for collections with permissions: null
  • Document Admin role exception
  • Verify dealership_id field exists in all target collections
  • Confirm $CURRENT_USER.dealership_id available
  • Document which roles currently have unrestricted access
  • Create test plan: 10 roles × 4 CRUD operations = 40 test cases
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decision:** Start IMP-001-T1 (critical, blocks other tasks)

### Start First Task

```bash
$ ./track-tasks.sh start IMP-001-T1

[2025-11-04 09:00:00] Starting task: IMP-001-T1

Entry Criteria Validation: IMP-001-T1

[1/4] Access to Directus admin panel (dev environment)
  Validated? (y/n): y
✓ Criterion validated

[2/4] Access to mcp__directapp-dev__schema tool
  Validated? (y/n): y
✓ Criterion validated

[3/4] Copy of ROLE_PERMISSIONS_PLAN.md available
  Validated? (y/n): y
✓ Criterion validated

[4/4] List of all collections from schema tool
  Validated? (y/n): y
✓ Criterion validated

✓ All entry criteria validated! Task can be started.

✓ Task started: IMP-001-T1
ℹ Started at: Mon Nov  4 09:00:00 CET 2025

ℹ Next available tasks:
IMP-002-T1
IMP-003-T1
IMP-004-T1
```

## Mid-Morning: 09:00-11:30 - Working on IMP-001-T1

**Activities:**
1. Access Directus admin panel at http://localhost:8055
2. Log in as Admin user
3. Navigate to Settings → Data Model
4. Document schema for 7 collections:
   - cars
   - resource_bookings
   - resource_capacities
   - dealership
   - notifications
   - workshop_tasks
   - directus_users
5. For each collection, export permissions JSON for all 10 roles
6. Create `DATA_ISOLATION_IMPACT_ANALYSIS.md` document
7. Identify gaps:
   - Cars: No dealership_id filter on READ (all roles see all cars)
   - Resource bookings: No provider_dealership_id filter
   - Notifications: No dealership_id filter
8. Document Admin role exception (Admin should see ALL dealerships)
9. Create test plan: 10 roles × 4 CRUD = 40 test cases

**Time elapsed:** 2.5 hours (30 minutes over estimate)

## Late Morning: 11:30 - Completing First Task

```bash
$ ./track-tasks.sh complete IMP-001-T1

[2025-11-04 11:30:00] Completing task: IMP-001-T1

Exit Criteria Validation: IMP-001-T1

[1/5] Document created: DATA_ISOLATION_IMPACT_ANALYSIS.md
  Validated? (y/n): y
✓ Criterion validated

[2/5] List of 7 collections requiring updates
  Validated? (y/n): y
✓ Criterion validated

[3/5] Current permission JSON documented for all 10 roles
  Validated? (y/n): y
✓ Criterion validated

[4/5] Impact analysis includes: which roles affected, which queries will change
  Validated? (y/n): y
✓ Criterion validated

[5/5] Admin role exception documented
  Validated? (y/n): y
✓ Criterion validated

✓ All exit criteria validated!

Actual effort (e.g., 2h, 30m) [2h]: 2.5h

✓ Task completed: IMP-001-T1
ℹ Completed at: Mon Nov  4 11:30:00 CET 2025
ℹ Actual effort: 2.5h (estimated: 2h)

✓ Tasks now available:
IMP-001-T2
```

**Deliverable Created:**
- `DATA_ISOLATION_IMPACT_ANALYSIS.md` (detailed permission analysis)

### Check Updated Status

```bash
$ ./track-tasks.sh status

DirectApp Implementation Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tasks:     20
Completed:       1 (5.0%)
In Progress:     0
Pending:         19

Current Phase:   Phase 1: Critical Fixes & Quick Wins
Status:          IN_PROGRESS
Target End:      2025-11-15

Progress Bar:
[==------------------------------------------------] 5.0%

Next Available Tasks:
IMP-001-T2: Create data isolation permission rules (JSON) (Dev 1)
IMP-002-T1: Review ROLE_PERMISSIONS_PLAN.md for DELETE rules (Dev 1)
IMP-003-T1: Fix workflow-guard exception import (Dev 1)
IMP-004-T1: Add vehicle_lookup_action alias field to cars collection (Dev 1)
IMP-005-T1: Grant mekaniker role UPDATE permission on tech_completed_date (Dev 1)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Progress:** 5% complete, IMP-001-T2 now unblocked

## Lunch Break: 11:30-12:30

Take a break! ☕

## Afternoon: 12:30 - Start Second Task

### Start IMP-001-T2

```bash
$ ./track-tasks.sh start IMP-001-T2

[2025-11-04 12:30:00] Starting task: IMP-001-T2

Entry Criteria Validation: IMP-001-T2

[1/4] IMP-001-T1 completed (impact analysis document ready)
  Validated? (y/n): y
✓ Criterion validated

[2/4] Access to ROLE_PERMISSIONS_PLAN.md
  Validated? (y/n): y
✓ Criterion validated

[3/4] Copy of current permissions backed up to /backups/permissions-backup-20251104.json
  Validated? (y/n): y
✓ Criterion validated

[4/4] Test Directus instance available (dev environment)
  Validated? (y/n): y
✓ Criterion validated

✓ All entry criteria validated! Task can be started.

✓ Task started: IMP-001-T2
ℹ Started at: Mon Nov  4 12:30:00 CET 2025
```

## Mid-Afternoon: 12:30-15:30 - Working on IMP-001-T2

**Activities:**
1. Open `DATA_ISOLATION_IMPACT_ANALYSIS.md` from IMP-001-T1
2. Reference `ROLE_PERMISSIONS_PLAN.md` for permission structure
3. Create permission JSON files for 7 collections × 9 non-admin roles:
   - `permissions/cars-nybilselger.json`
   - `permissions/cars-bruktbilselger.json`
   - `permissions/cars-mekaniker.json`
   - ... (63 total permission rules)
4. For each role, add dealership_id filter:
   ```json
   {
     "collection": "cars",
     "role": "nybilselger",
     "action": "read",
     "fields": ["*"],
     "permissions": {
       "dealership_id": {
         "_eq": "$CURRENT_USER.dealership_id"
       }
     }
   }
   ```
5. Special case for resource_bookings (provider OR consumer):
   ```json
   {
     "permissions": {
       "_or": [
         {"provider_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}},
         {"consumer_dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}
       ]
     }
   }
   ```
6. Admin role: Keep `permissions: null` (unrestricted)
7. Create `PERMISSION_TEST_PLAN.md` (40 test cases)

**Time elapsed:** 3 hours

## Late Afternoon: 15:30 - Complete Second Task

```bash
$ ./track-tasks.sh complete IMP-001-T2

[2025-11-04 15:30:00] Completing task: IMP-001-T2

Exit Criteria Validation: IMP-001-T2

[1/7] Permission JSON files created for 7 collections × 9 roles = 63 permission rules
  Validated? (y/n): y
✓ Criterion validated

[2/7] Admin role documented as exception (sees all dealerships, permissions: null)
  Validated? (y/n): y
✓ Criterion validated

[3/7] Filter syntax validated: {dealership_id: {_eq: $CURRENT_USER.dealership_id}}
  Validated? (y/n): y
✓ Criterion validated

[4/7] Special case for resource_bookings: {_or: [...]} filter applied
  Validated? (y/n): y
✓ Criterion validated

[5/7] Code reviewed by Dev 2 (pull request approved)
  Validated? (y/n): y
✓ Criterion validated

[6/7] JSON validates against Directus schema
  Validated? (y/n): y
✓ Criterion validated

[7/7] Test plan document created: PERMISSION_TEST_PLAN.md
  Validated? (y/n): y
✓ Criterion validated

✓ All exit criteria validated!

Actual effort (e.g., 2h, 30m) [3h]: 3h

✓ Task completed: IMP-001-T2
ℹ Completed at: Mon Nov  4 15:30:00 CET 2025
ℹ Actual effort: 3h (estimated: 3h)

✓ Tasks now available:
IMP-001-T3
```

**Deliverables Created:**
- 63 permission JSON files in `permissions/` directory
- `PERMISSION_TEST_PLAN.md` (40 test cases)

### Daily Summary

```bash
$ ./track-tasks.sh phase-report 1

Phase 1 Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:            Phase 1: Critical Fixes & Quick Wins
Status:          IN_PROGRESS
Target End:      2025-11-15

Total Tasks:     20
Completed:       2
In Progress:     0
Pending:         18
Progress:        10.0%

Tasks by Status:
COMPLETED: IMP-001-T1 - Analyze existing permission rules and data isolation gaps
COMPLETED: IMP-001-T2 - Create data isolation permission rules (JSON)
PENDING: IMP-001-T3 - Apply permission rules to dev environment
PENDING: IMP-001-T4 - Test data isolation with all 10 roles
PENDING: IMP-001-T5 - Document data isolation implementation and deploy to staging
PENDING: IMP-002-T1 - Review ROLE_PERMISSIONS_PLAN.md for DELETE rules
PENDING: IMP-002-T2 - Update booking role DELETE permissions
PENDING: IMP-002-T3 - Test DELETE restrictions with all roles
PENDING: IMP-003-T1 - Fix workflow-guard exception import
PENDING: IMP-003-T2 - Build and deploy workflow-guard extension
PENDING: IMP-003-T3 - Test workflow-guard validation logic
PENDING: IMP-004-T1 - Add vehicle_lookup_action alias field
PENDING: IMP-004-T2 - Test vehicle lookup with real VIN
PENDING: IMP-004-T3 - Document setup and deploy
PENDING: IMP-005-T1 - Grant mekaniker UPDATE permission
PENDING: IMP-005-T2 - Test mechanic completion workflow
PENDING: IMP-006-T1 - Create SQL migration for 5 critical indices
PENDING: IMP-006-T2 - Benchmark queries before index creation
PENDING: IMP-006-T3 - Apply indices and benchmark improvements
PENDING: IMP-006-T4 - Deploy indices to staging and production
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Day 1 Summary:**
- ✓ 2 tasks completed (10% of Phase 1)
- ✓ 5.5 hours actual effort (5h estimated)
- ✓ IMP-001-T3 ready to start tomorrow
- ✓ On track for 2-week Phase 1 target

## End of Day: 15:30 - Wrap Up

### Check Blockers

```bash
$ ./track-tasks.sh blockers

Blocking Dependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ IMP-001-T3: Apply permission rules to dev environment
  Blocked by: None (ready to start!)

✗ IMP-001-T4: Test data isolation with all 10 roles
  Blocked by: IMP-001-T3 (status: pending)

✗ IMP-001-T5: Document data isolation implementation and deploy to staging
  Blocked by: IMP-001-T4 (status: pending)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Review Log

```bash
$ tail -20 task-tracker.log

[2025-11-04 09:00:00] Initializing task tracker from segmentation...
[2025-11-04 09:00:00] Task tracker initialized with Phase 1 tasks
[2025-11-04 09:00:00] Starting task: IMP-001-T1
[2025-11-04 09:00:00] Backup created: .task-backups/tracker-20251104-090000.json
[2025-11-04 09:00:00] Task started: IMP-001-T1
[2025-11-04 11:30:00] Completing task: IMP-001-T1
[2025-11-04 11:30:00] Backup created: .task-backups/tracker-20251104-113000.json
[2025-11-04 11:30:00] Task completed: IMP-001-T1
[2025-11-04 12:30:00] Starting task: IMP-001-T2
[2025-11-04 12:30:00] Backup created: .task-backups/tracker-20251104-123000.json
[2025-11-04 12:30:00] Task started: IMP-001-T2
[2025-11-04 15:30:00] Completing task: IMP-001-T2
[2025-11-04 15:30:00] Backup created: .task-backups/tracker-20251104-153000.json
[2025-11-04 15:30:00] Task completed: IMP-001-T2
```

## Tuesday, November 5 - Preview

**Plan for tomorrow:**

```bash
$ ./track-tasks.sh list --status pending | head -5

IMP-001-T3      PENDING      CRITICAL   Apply permission rules to dev...     Dev 1
IMP-001-T4      PENDING      CRITICAL   Test data isolation with all...     Dev 1 (2h) + QA (2h)
IMP-001-T5      PENDING      CRITICAL   Document data isolation...          Dev 1
IMP-002-T1      PENDING      CRITICAL   Review DELETE permission rules      Dev 1
IMP-003-T1      PENDING      CRITICAL   Fix workflow-guard exception...     Dev 1
```

**Tomorrow's goals:**
1. Complete IMP-001-T3 (1.5h) - Apply permissions to dev
2. Complete IMP-001-T4 (4h) - Test with all 10 roles
3. Start IMP-001-T5 (1.5h) - Documentation and staging deploy

**Expected progress by EOD Tuesday:** 25% (5/20 tasks)

## Key Takeaways

### What Worked Well
- ✓ Entry criteria validation caught missing backup
- ✓ Exit criteria validation ensured quality deliverables
- ✓ Dependency enforcement prevented out-of-order execution
- ✓ Automatic backups provided safety net
- ✓ Real-time progress tracking kept team aligned

### Lessons Learned
- IMP-001-T1 took 30 minutes longer than estimated (2.5h vs 2h)
- Creating 63 permission JSON files was tedious but necessary
- Validation checklists prevented missing critical steps
- Rollback plans provided confidence to make changes

### Velocity Metrics
- **Day 1:** 2 tasks, 5.5 hours
- **Estimated velocity:** 10-12 hours/day with testing
- **Projected Phase 1 completion:** Nov 13 (2 days ahead of schedule)

## Appendix: Files Created

```
/home/claudecode/claudecode-system/projects/active/directapp/
├── DATA_ISOLATION_IMPACT_ANALYSIS.md  # IMP-001-T1 deliverable
├── PERMISSION_TEST_PLAN.md            # IMP-001-T2 deliverable
├── permissions/
│   ├── cars-nybilselger.json
│   ├── cars-bruktbilselger.json
│   ├── cars-mekaniker.json
│   ├── ... (63 total files)
├── .task-backups/
│   ├── tracker-20251104-090000.json
│   ├── tracker-20251104-113000.json
│   ├── tracker-20251104-123000.json
│   └── tracker-20251104-153000.json
└── task-tracker.json                  # Updated with 2 completed tasks
```

---

**Ready to continue Phase 1 implementation on Tuesday!** 🚀
