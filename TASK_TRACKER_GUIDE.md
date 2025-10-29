# DirectApp Task Tracker Guide

A simple, effective CLI tool for tracking implementation tasks and enforcing validation against Agent 2's segmentation and Agent 3's test strategy.

## Quick Start

```bash
# 1. Initialize tracker from segmentation
./track-tasks.sh init

# 2. View current status
./track-tasks.sh status

# 3. Start first task
./track-tasks.sh start IMP-001-T1

# 4. Complete task when done
./track-tasks.sh complete IMP-001-T1
```

## Installation

### Prerequisites

- Bash 4.0+
- `jq` (JSON processor)

Install `jq` if missing:

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# RHEL/CentOS
sudo yum install jq
```

### Setup

```bash
# Make executable
chmod +x track-tasks.sh

# Initialize tracker
./track-tasks.sh init
```

## Core Workflow

### Monday, Nov 4 - Starting Implementation

```bash
# 1. Check what's available
$ ./track-tasks.sh status

DirectApp Implementation Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tasks:     20
Completed:       0 (0.0%)
In Progress:     0
Pending:         20

Next Available Tasks:
IMP-001-T1: Analyze existing permission rules and data isolation gaps (Dev 1)

# 2. View task details
$ ./track-tasks.sh show IMP-001-T1

Task Details: IMP-001-T1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title:           Analyze existing permission rules and data isolation gaps
Status:          PENDING
Priority:        CRITICAL
Assigned To:     Dev 1
Estimated:       2h

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

# 3. Start the task (validates entry criteria)
$ ./track-tasks.sh start IMP-001-T1

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

# 4. Work on the task...
# (2 hours later)

# 5. Complete the task (validates exit criteria)
$ ./track-tasks.sh complete IMP-001-T1

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

[4/5] Impact analysis includes: which roles affected
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

## Command Reference

### Task Management

#### `init`
Initialize tracker from `PHASE_SEGMENTATION_COMPLETE.json`.

```bash
./track-tasks.sh init
```

**Note:** Creates backup if tracker already exists.

#### `list [--phase N] [--status S] [--assignee A]`
List tasks with optional filters.

```bash
# All tasks
./track-tasks.sh list

# Phase 1 tasks only
./track-tasks.sh list --phase 1

# Pending tasks
./track-tasks.sh list --status pending

# Tasks assigned to Dev 1
./track-tasks.sh list --assignee "Dev 1"

# Combined filters
./track-tasks.sh list --phase 1 --status in_progress
```

**Output:**
```
Task List
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMP-001-T1      COMPLETED    CRITICAL   Analyze existing permission...   Dev 1
IMP-001-T2      IN_PROGRESS  CRITICAL   Create data isolation rules...   Dev 1
IMP-001-T3      PENDING      CRITICAL   Apply permission rules...        Dev 1
```

#### `show <task_id>`
Display full task details including entry/exit criteria and validation checklist.

```bash
./track-tasks.sh show IMP-001-T1
```

#### `start <task_id>`
Start a task (validates entry criteria and dependencies).

```bash
./track-tasks.sh start IMP-001-T2
```

**Validation:**
- ✓ Checks dependencies completed
- ✓ Interactive entry criteria validation
- ✓ Updates status to `in_progress`
- ✓ Records start timestamp

**Blocks if:**
- Dependencies not completed
- Entry criteria not validated
- Task already started/completed

#### `complete <task_id>`
Complete a task (validates exit criteria).

```bash
./track-tasks.sh complete IMP-001-T2
```

**Validation:**
- ✓ Interactive exit criteria validation
- ✓ Prompts for actual effort
- ✓ Updates status to `completed`
- ✓ Records completion timestamp
- ✓ Shows unblocked tasks

**Blocks if:**
- Task not in progress
- Exit criteria not validated

#### `rollback <task_id>`
Rollback a failed task to pending status.

```bash
./track-tasks.sh rollback IMP-001-T2
```

**Actions:**
- Shows rollback plan from segmentation
- Prompts for confirmation
- Resets task to pending
- Clears timestamps and validation flags

### Validation

#### `validate-entry <task_id>`
Check entry criteria without starting task.

```bash
./track-tasks.sh validate-entry IMP-001-T3
```

**Use case:** Pre-flight check before starting work.

#### `validate-exit <task_id>`
Check exit criteria without completing task.

```bash
./track-tasks.sh validate-exit IMP-001-T3
```

**Use case:** Verify readiness before marking complete.

### Reporting

#### `status`
Show daily status report.

```bash
./track-tasks.sh status
```

**Output:**
```
DirectApp Implementation Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tasks:     20
Completed:       5 (25.0%)
In Progress:     1
Pending:         14

Current Phase:   Phase 1: Critical Fixes & Quick Wins
Status:          IN_PROGRESS
Target End:      2025-11-15

Progress Bar:
[============--------------------------------------] 25.0%

Next Available Tasks:
IMP-001-T6: Create seed data for testing
IMP-002-T1: Review DELETE permission rules
```

#### `blockers`
Show tasks blocked by incomplete dependencies.

```bash
./track-tasks.sh blockers
```

**Output:**
```
Blocking Dependencies
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✗ IMP-001-T3: Apply permission rules to dev environment
  Blocked by: IMP-001-T2 (status: in_progress)

✗ IMP-001-T4: Test data isolation with all 10 roles
  Blocked by: IMP-001-T3 (status: pending)
```

#### `phase-report <phase_num>`
Show phase completion summary.

```bash
./track-tasks.sh phase-report 1
```

**Output:**
```
Phase 1 Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:            Phase 1: Critical Fixes & Quick Wins
Status:          IN_PROGRESS
Target End:      2025-11-15

Total Tasks:     20
Completed:       5
In Progress:     1
Pending:         14
Progress:        25.0%

Tasks by Status:
COMPLETED: IMP-001-T1 - Analyze existing permission rules
COMPLETED: IMP-001-T2 - Create data isolation permission rules
IN_PROGRESS: IMP-001-T3 - Apply permission rules to dev environment
PENDING: IMP-001-T4 - Test data isolation with all 10 roles
...
```

#### `metrics`
Show overall project metrics (alias for `status`).

```bash
./track-tasks.sh metrics
```

## File Structure

```
/home/claudecode/claudecode-system/projects/active/directapp/
├── track-tasks.sh                      # Main CLI tool
├── task-tracker.json                   # Data file
├── .task-backups/                      # Automatic backups
│   └── tracker-20251104-090000.json
└── task-tracker.log                    # Command log
```

## Data Format

### task-tracker.json

```json
{
  "metadata": {
    "project": "DirectApp Implementation",
    "created": "2025-11-04",
    "last_updated": "2025-11-04",
    "version": "1.0"
  },
  "phases": [
    {
      "phase_id": "phase-1",
      "phase_name": "Phase 1: Critical Fixes & Quick Wins",
      "status": "in_progress",
      "start_date": "2025-11-04",
      "target_end_date": "2025-11-15",
      "actual_end_date": null,
      "tasks": [
        {
          "task_id": "IMP-001-T1",
          "improvement_id": "IMP-001",
          "title": "Analyze existing permission rules",
          "description": "...",
          "status": "completed",
          "assigned_to": "Dev 1",
          "priority": "critical",
          "estimated_effort": "2h",
          "actual_effort": "2.5h",
          "started_at": "2025-11-04T09:00:00+01:00",
          "completed_at": "2025-11-04T11:30:00+01:00",
          "entry_criteria": [...],
          "exit_criteria": [...],
          "validation_checklist": [...],
          "dependencies": [],
          "blocks": ["IMP-001-T2"],
          "rollback_plan": {...},
          "entry_criteria_validated": true,
          "exit_criteria_validated": true,
          "tests_passed": true,
          "validation_report": null
        }
      ]
    }
  ],
  "blockers": [],
  "metrics": {
    "total_tasks": 20,
    "completed": 1,
    "in_progress": 0,
    "pending": 19,
    "completion_percentage": 5.0
  }
}
```

## Enforcement Rules

### Dependency Graph

The tool enforces Agent 2's task dependencies:

```
IMP-001-T1 (no deps)
    ↓
IMP-001-T2 (depends on T1)
    ↓
IMP-001-T3 (depends on T2)
    ↓
IMP-001-T4 (depends on T3)
    ↓
IMP-001-T5 (depends on T4)
```

**Cannot start IMP-001-T3 until IMP-001-T2 is completed.**

### Entry Criteria Validation

Interactive checklist before starting task:

```bash
$ ./track-tasks.sh start IMP-001-T2

Entry Criteria Validation: IMP-001-T2

[1/4] IMP-001-T1 completed (impact analysis document ready)
  Validated? (y/n): y
✓ Criterion validated

[2/4] Access to ROLE_PERMISSIONS_PLAN.md
  Validated? (y/n): n
✗ Criterion not met!

ERROR: Not all entry criteria met. Cannot start task.
```

### Exit Criteria Validation

Interactive checklist before completing task:

```bash
$ ./track-tasks.sh complete IMP-001-T2

Exit Criteria Validation: IMP-001-T2

[1/7] Permission JSON files created for 7 collections × 9 roles = 63 rules
  Validated? (y/n): y
✓ Criterion validated

[2/7] Admin role documented as exception
  Validated? (y/n): y
✓ Criterion validated

...

✓ All exit criteria validated!
```

## Integration with Test Strategy

The tool integrates with Agent 3's test strategy:

### Test Commands (Future)

```bash
# Run unit tests (Phase 2a - Week 2-3)
./track-tasks.sh run-tests IMP-022-T1

# Run integration tests
./track-tasks.sh run-tests IMP-022-T2 --type integration

# Run E2E tests (Phase 2b - Week 4)
./track-tasks.sh run-tests IMP-023-T1 --type e2e
```

### Test Validation

When `test_command` is defined in task metadata:

```json
{
  "task_id": "IMP-022-T1",
  "test_command": "pnpm test -- workflow-guard",
  "test_pass_criteria": "80% coverage, 0 failures"
}
```

The tool will:
1. Run `pnpm test -- workflow-guard`
2. Parse output for pass/fail
3. Block completion if tests fail
4. Store results in `validation_report`

## Troubleshooting

### "jq is required but not installed"

**Solution:**
```bash
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS
```

### "Tracker file not found"

**Solution:**
```bash
./track-tasks.sh init
```

### "Task not found"

**Solution:** Check task ID spelling:
```bash
./track-tasks.sh list
```

### "Dependencies not met"

**Solution:** Complete blocking tasks first:
```bash
./track-tasks.sh blockers
```

### "Entry criteria not validated"

**Solution:** Ensure all prerequisites are met before starting task. Review entry criteria:
```bash
./track-tasks.sh show <task_id>
```

### Corrupt tracker file

**Solution:** Restore from backup:
```bash
ls -la .task-backups/
cp .task-backups/tracker-YYYYMMDD-HHMMSS.json task-tracker.json
```

## Best Practices

### Daily Workflow

**Morning:**
```bash
./track-tasks.sh status    # Check progress
./track-tasks.sh blockers  # Identify blockers
./track-tasks.sh show <next-task>  # Review next task
```

**During work:**
```bash
./track-tasks.sh start <task-id>  # Start task
# ... work on task ...
./track-tasks.sh complete <task-id>  # Complete task
```

**Evening:**
```bash
./track-tasks.sh phase-report 1  # Daily summary
```

### Team Coordination

**Assign tasks:**
```bash
./track-tasks.sh list --assignee "Dev 1"
./track-tasks.sh list --assignee "QA"
```

**Share status:**
```bash
./track-tasks.sh status > daily-status.txt
# Share daily-status.txt in Slack/email
```

**Track blockers:**
```bash
./track-tasks.sh blockers > blockers.txt
# Review in daily standup
```

### Validation Rigor

**Always validate:**
- ✓ Entry criteria before starting
- ✓ Exit criteria before completing
- ✓ Tests passing (when applicable)
- ✓ Dependencies met

**Never skip:**
- Entry criteria validation (prevents wasted effort)
- Exit criteria validation (ensures quality)
- Rollback plan review (know escape route)

## Advanced Usage

### Custom Filters

List tasks with complex filters:

```bash
# Critical pending tasks
./track-tasks.sh list --status pending | grep CRITICAL

# Dev 1's in-progress tasks
./track-tasks.sh list --assignee "Dev 1" --status in_progress
```

### Backup Management

```bash
# List backups
ls -lht .task-backups/

# Restore specific backup
cp .task-backups/tracker-20251104-143000.json task-tracker.json

# Clean old backups (keep last 10)
ls -t .task-backups/ | tail -n +11 | xargs -I {} rm .task-backups/{}
```

### Log Analysis

```bash
# View recent activity
tail -50 task-tracker.log

# Search for errors
grep ERROR task-tracker.log

# Task completion history
grep "Task completed" task-tracker.log
```

## Roadmap

### Phase 1 (Week 1) - ✓ COMPLETE
- [x] Basic CRUD operations
- [x] Entry/exit criteria validation
- [x] Dependency enforcement
- [x] Backup system

### Phase 2 (Week 2-3) - PLANNED
- [ ] Test execution integration
- [ ] Test result parsing
- [ ] Coverage reporting
- [ ] GitHub issue integration

### Phase 3 (Week 4+) - FUTURE
- [ ] Web dashboard (JSON export for UI)
- [ ] Slack notifications
- [ ] Email reports
- [ ] Multi-phase support (Phase 2, 3, 4)

## Support

### Documentation
- Agent 2: `PHASE_SEGMENTATION_COMPLETE.json`
- Agent 3: `DIRECTAPP_TEST_STRATEGY.json`
- Validation: `VALIDATION_REPORT.md`

### Contact
- Technical issues: Create GitHub issue
- Process questions: Review `PHASE_SEGMENTATION_SUMMARY.md`

---

**Ready to start?** Run `./track-tasks.sh init` and begin Phase 1! 🚀
