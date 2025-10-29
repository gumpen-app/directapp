# DirectApp Workflow Automation Guide

**Version:** 1.0
**Last Updated:** 2025-10-29
**Phase:** Phase 1 Implementation (Nov 4-15, 2025)

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Component 1: Pre-Flight Checklist](#component-1-pre-flight-checklist)
4. [Component 2: Daily Validation](#component-2-daily-validation)
5. [Component 3: Phase Gate](#component-3-phase-gate)
6. [Component 4: Test Integration](#component-4-test-integration)
7. [Component 5: Risk Monitoring](#component-5-risk-monitoring)
8. [Integration with Agents 1-4](#integration-with-agents-1-4)
9. [Troubleshooting](#troubleshooting)

---

## Overview

This workflow automation system ensures DirectApp Phase 1 implementation follows the validated plan with continuous verification. It synthesizes findings from 4 specialized agents:

- **Agent 1 (Validator)**: 7.5/10 roadmap score, 10 critical risks, 13 recommendations
- **Agent 2 (Segmentation)**: 27 atomic tasks, entry/exit criteria, 18.5h effort (revised from 3.75h)
- **Agent 3 (Test Strategy)**: 40 data isolation tests, 80 RBAC tests, 5 performance metrics
- **Agent 4 (Task Tracker)**: CLI tool (track-tasks.sh), JSON tracking, dependency enforcement

### Key Features

- ✅ **Automated Prerequisites Validation** - Pre-flight checklist before Phase 1
- ✅ **Daily Progress Tracking** - Morning reports with status, velocity, blockers
- ✅ **Phase Gate Enforcement** - Block Phase 2 if Phase 1 incomplete
- ✅ **Continuous Testing** - Git hooks, cron jobs, test automation
- ✅ **Risk Monitoring** - Track 10 risks, alert on threshold breaches

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  WORKFLOW AUTOMATION SYSTEM                 │
└─────────────────────────────────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
         ▼                  ▼                  ▼
    ┌─────────┐       ┌─────────┐       ┌─────────┐
    │Pre-Flight│       │ Daily   │       │ Phase   │
    │Checklist │       │Validation│       │  Gate   │
    └─────────┘       └─────────┘       └─────────┘
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
    ┌─────────┐       ┌─────────┐       ┌─────────┐
    │  Test   │       │  Risk   │       │  Task   │
    │Integration│      │Monitoring│       │Tracker  │
    └─────────┘       └─────────┘       └─────────┘
```

**5 Core Components:**

1. **Pre-Flight Checklist** - Run ONCE before Nov 4
2. **Daily Validation** - Run EVERY MORNING during Phase 1
3. **Phase Gate** - Run ONCE before Phase 2 (Nov 15)
4. **Test Integration** - Automated via Git/cron
5. **Risk Monitoring** - Weekly review (automated alerts)

---

## Component 1: Pre-Flight Checklist

### Purpose

Validate ALL prerequisites before starting Phase 1 on November 4, 2025.

### When to Run

**ONCE** - Before starting Phase 1 (ideally on Nov 3 or morning of Nov 4)

### How to Run

```bash
cd /path/to/directapp
./scripts/preflight-checklist.sh

# With verbose output
./scripts/preflight-checklist.sh --verbose

# Attempt auto-fixes
./scripts/preflight-checklist.sh --fix
```

### What It Checks

#### 1. Required Tools (8 checks)
- Git (version tracking)
- Node.js (≥v18.0.0)
- pnpm (package management)
- jq (JSON parsing)
- psql (PostgreSQL client)
- Docker (containerization)
- Docker daemon running
- Docker Compose (orchestration)

#### 2. Access & Authentication (5 checks)
- `.env.development` exists
- Directus dev server running (http://localhost:8055)
- GitHub remote configured
- GitHub push access
- Staging/production `.env` files

#### 3. Documentation Review (5 checks)
- `IMPROVEMENT_RECOMMENDATIONS.md`
- `IMPLEMENTATION_ROADMAP.md`
- `task-tracker.json`
- `MULTI_AGENT_ORCHESTRATION_SYSTEM.md`
- `ROLE_PERMISSIONS_PLAN.md`
- `GUMPEN_SYSTEM_DESIGN.md`

#### 4. Team Roles (Manual Verification)
- Dev 1, Dev 2, QA roles assigned
- Task assignments in `task-tracker.json`
- Slack/email communication setup
- Daily standup schedule

#### 5. Test Data (Manual Verification)
- Database connection successful
- 2 test dealerships (Kristiansand, Mandal)
- 5 cars per dealership
- 10 test users (1 per role)
- `STATENS_VEGVESEN_TOKEN` configured

#### 6. Backup Strategy (2 checks)
- `backups/` directory exists
- Database backup procedure documented

#### 7. Risk Acknowledgment (Manual)
- Team reviewed 10 Agent 1 risks
- Mitigation plans understood

#### 8. Git Status (4 checks)
- Current branch (not main)
- No uncommitted changes
- Remote sync status

#### 9. Extensions Status (4 checks)
- `workflow-guard` exists and built
- `vehicle-lookup-button` exists and built
- `vehicle-lookup-endpoint` exists and built
- `send-email-operation` exists and built

### Exit Codes

- **0** - All checks passed, ready for Phase 1
- **1** - Critical failures, cannot proceed
- **2** - Warnings present, review required

### Example Output

```
╔════════════════════════════════════════════╗
║   DirectApp Phase 1 Pre-Flight Checklist  ║
║   Target Start: November 4, 2025           ║
╚════════════════════════════════════════════╝

========================================
1. Required Tools
========================================
[PASS] git installed (version 2.34.1)
[PASS] node installed (v20.10.0, >= v18.0.0)
[PASS] pnpm installed (version 8.15.0)
...

Results:
  Passed:   35
  Failed:   0
  Warnings: 5
  Total:    40

✓ ALL CHECKS PASSED - READY TO BEGIN PHASE 1

Next steps:
  1. Run daily-validation.sh every morning
  2. Start with IMP-001-T1 (Data isolation analysis)
  3. Update task-tracker.json as tasks complete
```

### Common Issues

**Issue**: Docker daemon not running
```bash
# Fix
sudo systemctl start docker

# Verify
docker info
```

**Issue**: Directus not responding
```bash
# Fix
docker compose -f docker-compose.dev.yml up -d

# Check logs
docker logs directus
```

**Issue**: Missing `.env.development`
```bash
# Fix
cp .env.development.example .env.development

# Edit with actual values
nano .env.development
```

---

## Component 2: Daily Validation

### Purpose

Generate daily status reports and validate progress every morning during Phase 1 (Nov 4-15).

### When to Run

**EVERY MORNING** - First thing each workday during Phase 1

### How to Run

```bash
cd /path/to/directapp
./scripts/daily-validation.sh

# Generate report without console output
./scripts/daily-validation.sh --report-only

# Send email notification
./scripts/daily-validation.sh --email
```

### What It Generates

#### 1. Progress Metrics
- Total tasks: 20
- Completed: X (Y%)
- In Progress: X
- Pending: X
- Blocked: X
- Available Today: X

#### 2. Yesterday's Validation
- Tasks completed yesterday
- Exit criteria validation status
- Tests passed/failed
- Issues identified

#### 3. Today's Available Tasks
- Tasks ready to start (dependencies met)
- Assigned to whom
- Priority level
- Estimated effort
- Entry criteria

#### 4. Tasks In Progress
- Currently active tasks
- Who's working on them
- Time spent vs estimate

#### 5. Blocked Tasks
- Tasks with incomplete dependencies
- What's blocking them

#### 6. Velocity Metrics
- Phase start date
- Days elapsed
- Tasks per day
- Estimated days to complete

#### 7. Recommendations
- Required pace vs actual pace
- On track / behind schedule
- Suggested actions

#### 8. Risk Monitoring
- 3 critical risks tracked
- Mitigation status

### Output Location

**Report file**: `daily-reports/daily-report-YYYY-MM-DD.md`

**Example**: `daily-reports/daily-report-2025-11-05.md`

### Example Output

```
╔════════════════════════════════════════════╗
║   Daily Status Report - 2025-11-05        ║
╚════════════════════════════════════════════╝

Progress: 8/20 (40.0%)
In Progress: 2
Blocked: 3
Available Today: 5

Full report: /path/to/directapp/daily-reports/daily-report-2025-11-05.md
```

### Setting Up Email Notifications

```bash
# Install mailutils (Ubuntu/Debian)
sudo apt install mailutils

# Set email recipient
export DIRECTAPP_EMAIL_TO="team@example.com"

# Run with email
./scripts/daily-validation.sh --email
```

### Integration with Stand-ups

**Morning Routine:**

1. Run `daily-validation.sh` (5 minutes)
2. Review generated report
3. Use report as stand-up agenda:
   - Yesterday's completions
   - Today's available tasks
   - Blockers to resolve
   - Velocity check

---

## Component 3: Phase Gate

### Purpose

Validate ALL Phase 1 requirements before allowing Phase 2 to start.

### When to Run

**ONCE** - Before starting Phase 2 (target: Nov 15, 2025)

### How to Run

```bash
cd /path/to/directapp
./scripts/phase-gate.sh

# Show detailed failure reasons
./scripts/phase-gate.sh --detailed

# Force proceed (NOT RECOMMENDED)
./scripts/phase-gate.sh --force
```

### 8 Gate Checks

#### Gate 1: All Tasks Complete
- ✓ All 20 tasks status = "completed"
- ✓ Exit criteria validated
- ✗ Shows incomplete tasks if any

#### Gate 2: Success Criteria Met
- Security Score: 2.5 → 7.0 (target: ≥7.0)
- Data Isolation: 0% → 100%
- Permission Coverage: ≥95%
- Workflow Validation: 100%
- Performance: +75-92% improvement
- Vehicle Lookup: Deployed

**Manual confirmation required**

#### Gate 3: Tests Passing
- 40 data isolation tests (IMP-001-T4)
- 10 DELETE permission tests
- 5 workflow validation tests
- 3 vehicle lookup tests
- 2 mechanic permission tests
- 5 index performance benchmarks
- Regression test suite

**Manual confirmation required**

#### Gate 4: Documentation Complete
- 14 deliverables from Agent 2:
  - `DATA_ISOLATION_IMPACT_ANALYSIS.md`
  - `PERMISSION_TEST_PLAN.md`
  - `PERMISSION_TEST_RESULTS.md`
  - `DATA_ISOLATION_IMPLEMENTATION.md`
  - `DELETE_PERMISSIONS_PLAN.md`
  - `DELETE_PERMISSIONS_TEST_RESULTS.md`
  - `WORKFLOW_GUARD_TEST_RESULTS.md`
  - `VEHICLE_LOOKUP_SETUP.md`
  - `HOW_TO_USE_VEHICLE_LOOKUP.md`
  - `VEHICLE_LOOKUP_TEST_RESULTS.md`
  - `MECHANIC_PERMISSION_TEST_RESULTS.md`
  - `INDEX_PERFORMANCE_BASELINE.md`
  - `INDEX_PERFORMANCE_COMPARISON.md`
  - `INDEX_DEPLOYMENT_REPORT.md`

#### Gate 5: Deployment Status
- Changes deployed to staging
- Staging tested and verified

**Manual confirmation required**

#### Gate 6: Stakeholder Approval
- Product Owner sign-off
- Tech Lead sign-off
- QA Lead sign-off

**Manual confirmation required**

#### Gate 7: Risk Assessment
- All 10 critical risks mitigated or accepted

**Manual confirmation required**

#### Gate 8: Performance Validation
- Query 1: 500ms → 45ms (91% improvement)
- Query 2: 350ms → 52ms (85% improvement)
- Query 3: 280ms → 70ms (75% improvement)
- Query 4: 220ms → 48ms (78% improvement)
- Query 5: 180ms → 15ms (92% improvement)

**Manual confirmation required**

### Exit Codes

- **0** - GO: Proceed to Phase 2
- **1** - NO-GO: Critical failures
- **2** - REVIEW: Minor issues, stakeholder decision

### Decision Output

**GO:**
```
╔═══════════════════════════════════════════╗
║              ✓ GO - PROCEED              ║
║    Phase 1 Complete - Start Phase 2     ║
╚═══════════════════════════════════════════╝
```

**NO-GO:**
```
╔═══════════════════════════════════════════╗
║            ✗ NO-GO - BLOCKED             ║
║   Critical Failures - Cannot Proceed     ║
╚═══════════════════════════════════════════╝
```

**REVIEW:**
```
╔═══════════════════════════════════════════╗
║           ⚠ REVIEW REQUIRED             ║
║   Minor Issues - Stakeholder Decision    ║
╚═══════════════════════════════════════════╝
```

---

## Component 4: Test Integration

### Purpose

Integrate testing into Git workflow and CI/CD pipeline for continuous validation.

### Installation

**One-time setup:**

```bash
cd /path/to/directapp
./scripts/test-integration.sh install
```

This installs:
1. **Git pre-commit hook** - Runs unit tests before every commit
2. **Nightly cron job** - Runs integration tests at 2 AM

### Test Suites

#### Unit Tests
**When**: Before every Git commit (pre-commit hook)

**What**: TypeScript compilation, extension builds

**Run manually**:
```bash
./scripts/test-integration.sh unit

# Fast mode (critical tests only)
./scripts/test-integration.sh unit --fast
```

#### Integration Tests
**When**: Nightly at 2 AM (cron job)

**What**: Directus health, database connectivity, API endpoints

**Run manually**:
```bash
./scripts/test-integration.sh integration
```

#### Security Tests
**When**: After IMP-001, IMP-010, IMP-025 (RBAC changes)

**What**: Data isolation (40 tests), RBAC enforcement, DELETE restrictions

**Run manually**:
```bash
./scripts/test-integration.sh security
```

#### Performance Tests
**When**: Before IMP-008, IMP-009 (dashboard deployment)

**What**: 5 database query benchmarks, dashboard load time, API response time

**Run manually**:
```bash
./scripts/test-integration.sh performance
```

### Test Reports

**Location**: `test-results/`

**Files**:
- `unit-YYYYMMDD-HHMMSS.txt`
- `integration-YYYYMMDD-HHMMSS.txt`
- `security-YYYYMMDD-HHMMSS.txt`
- `performance-YYYYMMDD-HHMMSS.txt`
- `combined-report-YYYYMMDD-HHMMSS.md`

### Generate Combined Report

```bash
./scripts/test-integration.sh report
```

### Disable Pre-commit Hook (Temporary)

```bash
# Skip hook for one commit
git commit --no-verify -m "message"

# Remove hook entirely
rm .git/hooks/pre-commit
```

### Cron Job Management

**View current cron jobs:**
```bash
crontab -l
```

**Remove nightly tests:**
```bash
crontab -e
# Delete the line: 0 2 * * * /path/to/nightly-tests.sh
```

---

## Component 5: Risk Monitoring

### Purpose

Track 10 critical risks from Agent 1 and alert on threshold breaches.

### When to Run

**Weekly** - Every Monday morning (or after major task completions)

### How to Run

```bash
cd /path/to/directapp
./scripts/risk-monitor.sh

# Show detailed risk information
./scripts/risk-monitor.sh --detailed

# Send email alerts
./scripts/risk-monitor.sh --alert
```

### 10 Critical Risks Tracked

| Risk ID | Title | Threshold |
|---------|-------|-----------|
| RISK-001 | IMP-001 Data Isolation Complexity | 150% (18h) |
| RISK-002 | IMP-006 Index Creation Time | 150% (3h) |
| RISK-003 | IMP-010 RBAC Complexity | 150% (12h) |
| RISK-004 | IMP-022 Testing Framework | 150% (9h) |
| RISK-005 | IMP-024 Schema Import | 150% (6h) |
| RISK-006 | Cross-Dealership Edge Cases | N/A |
| RISK-007 | Timeline Buffer Consumption | 75% buffer used |
| RISK-008 | Phase Gate Failures | N/A |
| RISK-009 | Data Isolation Test Failures | >10% fail rate |
| RISK-010 | Rollback Complexity | N/A |

### Alert Thresholds

**Task Overrun:**
- Task exceeds 150% of estimated effort
- Example: IMP-001 estimated 12h, actual 18h+ → ALERT

**Timeline:**
- Critical path delayed >2 days
- Days until Phase 1 target <5 days → ALERT

**Tests:**
- Test failure rate >10%
- Example: 5 out of 40 tests failing → ALERT

**Buffer:**
- Buffer consumed >75%
- Example: 4-6 week buffer reduced to <1 week → ALERT

### Risk Dashboard

**Example output:**

```
╔═══════════════════════════════════════════╗
║         Risk Monitoring Dashboard        ║
╚═══════════════════════════════════════════╝

Last Updated: 2025-11-08T09:30:00Z

Risk Status Summary:

Risk ID    Title                              Estimated    Actual       Overrun
─────────────────────────────────────────────────────────────────────────────────
RISK-001   IMP-001 Data Isolation Complexity  12h          15h          25.0%
RISK-002   IMP-006 Index Creation Time        2h           --           --
RISK-003   IMP-010 RBAC Complexity            8h           --           --
...

Active Alerts: 2
  ⚠ 2025-11-08T09:15:00Z: RISK-001: IMP-001 Data Isolation Complexity - Overrun 25.0% (threshold: 50%)
  ⚠ 2025-11-08T09:30:00Z: Timeline buffer critically low: 4 days until Phase 1 target
```

### Risk Data File

**Location**: `risk-tracking.json`

**Structure**:
```json
{
  "last_updated": "2025-11-08T09:30:00Z",
  "risks": [
    {
      "risk_id": "RISK-001",
      "title": "IMP-001 Data Isolation Complexity",
      "related_task": "IMP-001",
      "estimated_effort": "12h",
      "actual_effort": "15h",
      "overrun_percentage": 25.0,
      "threshold_multiplier": 1.5,
      "status": "active",
      "mitigation": "4-6 week buffer, phased implementation",
      "impact_if_realized": "2-day delay, incomplete data isolation",
      "probability": "medium"
    }
  ],
  "alerts": [
    {
      "timestamp": "2025-11-08T09:15:00Z",
      "message": "RISK-001: IMP-001 Data Isolation Complexity - Overrun 25.0% (threshold: 50%)"
    }
  ]
}
```

---

## Integration with Agents 1-4

### Agent 1 (Validator) Integration

**Inputs:**
- 10 risk findings → `risk-monitor.sh`
- 13 recommendations → Implementation tracking
- Timeline validation → `daily-validation.sh` velocity checks

**Outputs:**
- Risk alerts when thresholds exceeded
- Timeline adherence monitoring

### Agent 2 (Segmentation) Integration

**Inputs:**
- 27 atomic tasks → `task-tracker.json`
- Entry/exit criteria → `daily-validation.sh` checks
- Dependencies → `phase-gate.sh` validation

**Outputs:**
- Task completion tracking
- Dependency enforcement
- Exit criteria validation

### Agent 3 (Test Strategy) Integration

**Inputs:**
- 40 data isolation tests → `test-integration.sh security`
- 80 RBAC tests → Manual execution
- 5 performance metrics → `test-integration.sh performance`

**Outputs:**
- Test pass/fail status
- Coverage reports
- Performance benchmarks

### Agent 4 (Task Tracker) Integration

**Inputs:**
- `task-tracker.json` → All scripts read this file
- Task status updates → Manual updates via track-tasks.sh

**Outputs:**
- Daily reports use task data
- Phase gate checks task completion
- Risk monitor reads actual effort

---

## Troubleshooting

### Pre-Flight Checklist Failures

**Problem**: Git not found
```bash
# Fix (Ubuntu/Debian)
sudo apt install git

# Fix (macOS)
brew install git
```

**Problem**: Node version too old
```bash
# Install Node v20.x (Ubuntu/Debian)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
```

**Problem**: Docker daemon not running
```bash
# Start Docker (Linux)
sudo systemctl start docker
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

### Daily Validation Issues

**Problem**: jq not installed
```bash
# Install jq (Ubuntu/Debian)
sudo apt install jq

# Install jq (macOS)
brew install jq
```

**Problem**: task-tracker.json not found
```bash
# Verify file exists
ls -l task-tracker.json

# If missing, restore from Git
git checkout task-tracker.json
```

**Problem**: Email not sending
```bash
# Install mailutils (Ubuntu/Debian)
sudo apt install mailutils

# Test email
echo "test" | mail -s "test subject" your-email@example.com

# Configure SMTP (optional)
sudo dpkg-reconfigure postfix
```

### Phase Gate Failures

**Problem**: Tasks not completing
- Review `task-tracker.json` status
- Run `track-tasks.sh status` to see current state
- Identify blockers with `daily-validation.sh`

**Problem**: Documentation missing
```bash
# Generate missing docs manually
# Refer to task exit criteria for doc requirements
```

**Problem**: Tests failing
```bash
# Run test suite manually
./scripts/test-integration.sh all

# Review test results
cat test-results/combined-report-*.md
```

### Test Integration Issues

**Problem**: Pre-commit hook not triggering
```bash
# Verify hook exists
ls -l .git/hooks/pre-commit

# Verify executable
chmod +x .git/hooks/pre-commit

# Test hook manually
.git/hooks/pre-commit
```

**Problem**: Extension builds failing
```bash
# Check Node/pnpm versions
node --version
pnpm --version

# Clean install
cd extensions/directus-extension-workflow-guard
rm -rf node_modules dist
pnpm install
pnpm build
```

**Problem**: Cron job not running
```bash
# Check cron service
sudo systemctl status cron

# View cron logs
grep CRON /var/log/syslog

# Test nightly script manually
./scripts/nightly-tests.sh
```

### Risk Monitoring Issues

**Problem**: Risk data not initializing
```bash
# Check if risk-tracking.json exists
ls -l risk-tracking.json

# If missing, run risk-monitor once
./scripts/risk-monitor.sh
```

**Problem**: Alerts not triggering
- Verify `task-tracker.json` has `actual_effort` fields populated
- Check alert thresholds in `risk-tracking.json`
- Run with `--detailed` flag to see risk calculations

---

## Quick Reference

### Pre-Phase 1 (Before Nov 4)

```bash
# Run pre-flight checklist
./scripts/preflight-checklist.sh --verbose

# Fix any failures
./scripts/preflight-checklist.sh --fix

# Install test automation
./scripts/test-integration.sh install
```

### During Phase 1 (Nov 4-15)

```bash
# EVERY MORNING
./scripts/daily-validation.sh --email

# WEEKLY (Mondays)
./scripts/risk-monitor.sh --alert --detailed

# AFTER RBAC CHANGES
./scripts/test-integration.sh security

# BEFORE DASHBOARD DEPLOYMENT
./scripts/test-integration.sh performance
```

### Before Phase 2 (Nov 15)

```bash
# Run phase gate
./scripts/phase-gate.sh --detailed

# If NO-GO, review failures and fix
# If REVIEW, get stakeholder approval
# If GO, proceed to Phase 2
```

---

## Support

**Issues?** Create GitHub issue with:
- Script name
- Error message
- Output of `./scripts/preflight-checklist.sh --verbose`

**Questions?** Contact:
- Dev 1: [email]
- Dev 2: [email]
- QA Lead: [email]

---

**End of Workflow Automation Guide**
