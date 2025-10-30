#!/usr/bin/env bash
#
# Daily Validation Workflow Script
# DirectApp Phase 1 Implementation (Nov 4-15)
#
# Purpose: Generate daily status reports and validate progress
# Usage: ./scripts/daily-validation.sh [--report-only] [--email]
#
# Run this every morning to:
#   - Check yesterday's task completions
#   - Validate exit criteria
#   - Identify today's available tasks
#   - Send status notifications

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Task tracker file
TASK_TRACKER="$PROJECT_ROOT/task-tracker.json"
DAILY_REPORTS_DIR="$PROJECT_ROOT/daily-reports"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || echo "")

# Options
REPORT_ONLY=false
SEND_EMAIL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --report-only)
      REPORT_ONLY=true
      shift
      ;;
    --email)
      SEND_EMAIL=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--report-only] [--email]"
      exit 1
      ;;
  esac
done

# Ensure reports directory exists
mkdir -p "$DAILY_REPORTS_DIR"

# Report file
REPORT_FILE="$DAILY_REPORTS_DIR/daily-report-$TODAY.md"

# ========================================
# Helper Functions
# ========================================

log() {
  echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

# ========================================
# Load Task Data
# ========================================

load_tasks() {
  if [ ! -f "$TASK_TRACKER" ]; then
    log_error "Task tracker not found: $TASK_TRACKER"
    exit 1
  fi

  if ! command -v jq &> /dev/null; then
    log_error "jq not installed. Install: sudo apt install jq"
    exit 1
  fi
}

# ========================================
# Generate Status Report Header
# ========================================

generate_header() {
  cat > "$REPORT_FILE" << EOF
# DirectApp Phase 1 - Daily Status Report
**Date:** $TODAY
**Report Generated:** $(date +"%Y-%m-%d %H:%M:%S")
**Phase:** Phase 1 - Critical Fixes & Quick Wins
**Target Completion:** November 15, 2025

---

## Executive Summary

EOF
}

# ========================================
# Calculate Metrics
# ========================================

calculate_metrics() {
  log "Calculating metrics..."

  # Total tasks
  TOTAL_TASKS=$(jq '.phases[0].tasks | length' "$TASK_TRACKER")

  # Task status counts
  COMPLETED=$(jq '[.phases[0].tasks[] | select(.status == "completed")] | length' "$TASK_TRACKER")
  IN_PROGRESS=$(jq '[.phases[0].tasks[] | select(.status == "in_progress")] | length' "$TASK_TRACKER")
  PENDING=$(jq '[.phases[0].tasks[] | select(.status == "pending")] | length' "$TASK_TRACKER")

  # Calculate completion percentage
  if [ "$TOTAL_TASKS" -gt 0 ]; then
    COMPLETION_PCT=$(echo "scale=1; ($COMPLETED / $TOTAL_TASKS) * 100" | bc)
  else
    COMPLETION_PCT=0
  fi

  # Blocked tasks (tasks where dependencies are not complete)
  BLOCKED=$(jq '[.phases[0].tasks[] | select(.status == "pending") | select(.dependencies | length > 0)] | length' "$TASK_TRACKER")

  # Available tasks (pending, no incomplete dependencies)
  AVAILABLE=$(jq '[.phases[0].tasks[] | select(.status == "pending") | select(
    if .dependencies | length > 0 then
      [.dependencies[] as $dep | any(.phases[0].tasks[]; .task_id == $dep and .status == "completed")] | all
    else
      true
    end
  )] | length' "$TASK_TRACKER")

  cat >> "$REPORT_FILE" << EOF
### Progress Metrics

| Metric | Value |
|--------|-------|
| **Total Tasks** | $TOTAL_TASKS |
| **Completed** | $COMPLETED (${COMPLETION_PCT}%) |
| **In Progress** | $IN_PROGRESS |
| **Pending** | $PENDING |
| **Blocked** | $BLOCKED |
| **Available Today** | $AVAILABLE |

EOF
}

# ========================================
# Yesterday's Completions
# ========================================

validate_yesterday() {
  log "Validating yesterday's completions..."

  cat >> "$REPORT_FILE" << EOF
---

## Yesterday's Validation ($YESTERDAY)

EOF

  # Get tasks completed yesterday
  YESTERDAY_COMPLETIONS=$(jq -r --arg date "$YESTERDAY" '
    [.phases[0].tasks[] | select(.completed_at != null and (.completed_at | startswith($date)))] | length
  ' "$TASK_TRACKER")

  if [ "$YESTERDAY_COMPLETIONS" -eq 0 ]; then
    cat >> "$REPORT_FILE" << EOF
**No tasks completed yesterday.**

EOF
    log_warn "No tasks completed yesterday"
  else
    cat >> "$REPORT_FILE" << EOF
**$YESTERDAY_COMPLETIONS task(s) completed yesterday:**

EOF

    # List completed tasks
    jq -r --arg date "$YESTERDAY" '
      .phases[0].tasks[] |
      select(.completed_at != null and (.completed_at | startswith($date))) |
      "- **\(.task_id)**: \(.title) (Assigned: \(.assigned_to))"
    ' "$TASK_TRACKER" >> "$REPORT_FILE"

    cat >> "$REPORT_FILE" << EOF

### Exit Criteria Validation

EOF

    # Check exit criteria for each completed task
    jq -r --arg date "$YESTERDAY" '
      .phases[0].tasks[] |
      select(.completed_at != null and (.completed_at | startswith($date))) |
      "#### \(.task_id): \(.title)\n\n**Exit Criteria:**\n" +
      (if .exit_criteria_validated then
        "✓ Exit criteria validated\n"
      else
        "⚠ Exit criteria NOT validated - requires manual review\n"
      end) +
      "\n**Tests Passed:**\n" +
      (if .tests_passed then
        "✓ All tests passing\n"
      else
        "⚠ Tests NOT passing or not run\n"
      end) +
      "\n"
    ' "$TASK_TRACKER" >> "$REPORT_FILE"
  fi
}

# ========================================
# Today's Available Tasks
# ========================================

list_available_tasks() {
  log "Identifying available tasks..."

  cat >> "$REPORT_FILE" << EOF
---

## Today's Available Tasks ($TODAY)

**Tasks ready to start (dependencies met):**

EOF

  # Get available tasks (pending, no blocking dependencies)
  AVAILABLE_TASKS=$(jq -r '
    .phases[0].tasks[] |
    select(.status == "pending") |
    select(
      if .dependencies | length > 0 then
        all(.dependencies[]; . as $dep | any(.phases[0].tasks[]; .task_id == $dep and .status == "completed"))
      else
        true
      end
    ) |
    "### \(.task_id): \(.title)\n" +
    "- **Assigned:** \(.assigned_to)\n" +
    "- **Priority:** \(.priority)\n" +
    "- **Estimated Effort:** \(.estimated_effort)\n" +
    "- **Description:** \(.description | split("\n")[0])\n" +
    "\n**Entry Criteria:**\n" +
    (.entry_criteria | map("- \(.)") | join("\n")) +
    "\n\n"
  ' "$TASK_TRACKER")

  if [ -z "$AVAILABLE_TASKS" ]; then
    cat >> "$REPORT_FILE" << EOF
**No tasks available.** All pending tasks have incomplete dependencies.

EOF
    log_warn "No available tasks today"
  else
    echo "$AVAILABLE_TASKS" >> "$REPORT_FILE"
  fi
}

# ========================================
# In Progress Tasks
# ========================================

list_in_progress() {
  log "Listing in-progress tasks..."

  cat >> "$REPORT_FILE" << EOF
---

## Tasks In Progress

EOF

  IN_PROGRESS_TASKS=$(jq -r '
    [.phases[0].tasks[] | select(.status == "in_progress")] | length
  ' "$TASK_TRACKER")

  if [ "$IN_PROGRESS_TASKS" -eq 0 ]; then
    cat >> "$REPORT_FILE" << EOF
**No tasks currently in progress.**

EOF
  else
    jq -r '
      .phases[0].tasks[] |
      select(.status == "in_progress") |
      "### \(.task_id): \(.title)\n" +
      "- **Assigned:** \(.assigned_to)\n" +
      "- **Started:** \(.started_at)\n" +
      "- **Estimated Effort:** \(.estimated_effort)\n" +
      "\n"
    ' "$TASK_TRACKER" >> "$REPORT_FILE"
  fi
}

# ========================================
# Blocked Tasks
# ========================================

list_blocked() {
  log "Identifying blocked tasks..."

  cat >> "$REPORT_FILE" << EOF
---

## Blocked Tasks

EOF

  # Tasks with incomplete dependencies
  BLOCKED_TASKS=$(jq -r '
    .phases[0].tasks[] |
    select(.status == "pending") |
    select(.dependencies | length > 0) |
    select(
      any(.dependencies[]; . as $dep | all(.phases[0].tasks[]; .task_id != $dep or .status != "completed"))
    ) |
    "### \(.task_id): \(.title)\n" +
    "- **Blocked by:** \(.dependencies | join(", "))\n" +
    "\n"
  ' "$TASK_TRACKER")

  if [ -z "$BLOCKED_TASKS" ]; then
    cat >> "$REPORT_FILE" << EOF
**No blocked tasks.**

EOF
  else
    echo "$BLOCKED_TASKS" >> "$REPORT_FILE"
  fi
}

# ========================================
# Velocity Metrics
# ========================================

calculate_velocity() {
  log "Calculating velocity metrics..."

  cat >> "$REPORT_FILE" << EOF
---

## Velocity & Performance

EOF

  # Phase start date (first task start date)
  PHASE_START=$(jq -r '
    [.phases[0].tasks[] | select(.started_at != null) | .started_at] | sort | first
  ' "$TASK_TRACKER")

  if [ "$PHASE_START" = "null" ] || [ -z "$PHASE_START" ]; then
    cat >> "$REPORT_FILE" << EOF
**Phase not yet started.** No velocity data available.

EOF
  else
    # Days elapsed
    START_DATE=$(date -d "$PHASE_START" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$PHASE_START" +%s 2>/dev/null || echo 0)
    TODAY_DATE=$(date +%s)
    DAYS_ELAPSED=$(( (TODAY_DATE - START_DATE) / 86400 ))

    if [ "$DAYS_ELAPSED" -gt 0 ]; then
      TASKS_PER_DAY=$(echo "scale=2; $COMPLETED / $DAYS_ELAPSED" | bc)
    else
      TASKS_PER_DAY=0
    fi

    # Estimated remaining days
    REMAINING_TASKS=$((TOTAL_TASKS - COMPLETED))
    if [ "$TASKS_PER_DAY" != "0" ]; then
      ESTIMATED_DAYS=$(echo "scale=0; $REMAINING_TASKS / $TASKS_PER_DAY" | bc)
    else
      ESTIMATED_DAYS="N/A"
    fi

    cat >> "$REPORT_FILE" << EOF
| Metric | Value |
|--------|-------|
| **Phase Start Date** | $PHASE_START |
| **Days Elapsed** | $DAYS_ELAPSED |
| **Tasks Completed** | $COMPLETED |
| **Tasks per Day** | $TASKS_PER_DAY |
| **Remaining Tasks** | $REMAINING_TASKS |
| **Estimated Days to Complete** | $ESTIMATED_DAYS |

EOF
  fi
}

# ========================================
# Recommendations
# ========================================

generate_recommendations() {
  log "Generating recommendations..."

  cat >> "$REPORT_FILE" << EOF
---

## Recommendations for Today

EOF

  # Check if on track
  TARGET_COMPLETION="2025-11-15"
  TARGET_DATE=$(date -d "$TARGET_COMPLETION" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$TARGET_COMPLETION" +%s 2>/dev/null || echo 0)
  TODAY_DATE=$(date +%s)
  DAYS_UNTIL_TARGET=$(( (TARGET_DATE - TODAY_DATE) / 86400 ))

  REMAINING_TASKS=$((TOTAL_TASKS - COMPLETED))

  if [ "$DAYS_UNTIL_TARGET" -gt 0 ]; then
    REQUIRED_TASKS_PER_DAY=$(echo "scale=2; $REMAINING_TASKS / $DAYS_UNTIL_TARGET" | bc)

    cat >> "$REPORT_FILE" << EOF
- **Days until Phase 1 target:** $DAYS_UNTIL_TARGET days (Nov 15)
- **Remaining tasks:** $REMAINING_TASKS
- **Required pace:** $REQUIRED_TASKS_PER_DAY tasks/day

EOF

    # Check if on pace
    if [ "$COMPLETED" -gt 0 ]; then
      ACTUAL_PACE=$(echo "scale=2; $COMPLETED / $DAYS_ELAPSED" | bc 2>/dev/null || echo "0")
      PACE_COMPARISON=$(echo "$ACTUAL_PACE >= $REQUIRED_TASKS_PER_DAY" | bc -l 2>/dev/null || echo "0")

      if [ "$PACE_COMPARISON" = "1" ]; then
        cat >> "$REPORT_FILE" << EOF
✓ **On pace:** Current pace ($ACTUAL_PACE tasks/day) meets required pace ($REQUIRED_TASKS_PER_DAY tasks/day)

EOF
      else
        cat >> "$REPORT_FILE" << EOF
⚠ **Behind pace:** Current pace ($ACTUAL_PACE tasks/day) below required pace ($REQUIRED_TASKS_PER_DAY tasks/day)

**Recommended actions:**
- Prioritize available tasks by criticality
- Consider parallel execution where possible
- Review blockers and resolve dependencies
- Adjust timeline if necessary (4-6 week buffer available)

EOF
      fi
    fi
  fi

  # Specific recommendations based on status
  if [ "$IN_PROGRESS" -gt 3 ]; then
    cat >> "$REPORT_FILE" << EOF
⚠ **Many tasks in progress ($IN_PROGRESS):** Consider focusing on completion before starting new tasks.

EOF
  fi

  if [ "$BLOCKED" -gt 5 ]; then
    cat >> "$REPORT_FILE" << EOF
⚠ **Many blocked tasks ($BLOCKED):** Review dependencies and prioritize unblocking.

EOF
  fi
}

# ========================================
# Risks & Issues
# ========================================

track_risks() {
  log "Tracking risks..."

  cat >> "$REPORT_FILE" << EOF
---

## Risk Monitoring

**Critical risks from Agent 1:**

1. **RISK-001 (IMP-001):** Data isolation complexity - 12h estimate
2. **RISK-002 (IMP-006):** Index creation time - potential database locks
3. **RISK-003 (IMP-010):** RBAC complexity - nested permissions

**Mitigation status:** _(Manual update required)_

EOF
}

# ========================================
# Generate Footer
# ========================================

generate_footer() {
  cat >> "$REPORT_FILE" << EOF
---

## Next Steps

1. Review available tasks and assign priorities
2. Validate entry criteria for tasks starting today
3. Address blocked tasks (resolve dependencies)
4. Update task-tracker.json as tasks progress

---

**Report ends.**

EOF
}

# ========================================
# Send Email Notification
# ========================================

send_email_notification() {
  if [ "$SEND_EMAIL" = true ]; then
    log "Sending email notification..."

    # Email configuration (customize as needed)
    EMAIL_TO="${DIRECTAPP_EMAIL_TO:-team@example.com}"
    EMAIL_SUBJECT="DirectApp Phase 1 - Daily Status Report ($TODAY)"

    # Send via mail command (requires mail/sendmail)
    if command -v mail &> /dev/null; then
      mail -s "$EMAIL_SUBJECT" "$EMAIL_TO" < "$REPORT_FILE"
      log_success "Email sent to $EMAIL_TO"
    else
      log_warn "mail command not available. Email not sent."
      log_warn "Install: sudo apt install mailutils"
    fi
  fi
}

# ========================================
# Print Summary to Console
# ========================================

print_console_summary() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║   Daily Status Report - $TODAY    ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "Progress: ${GREEN}$COMPLETED${NC}/$TOTAL_TASKS (${COMPLETION_PCT}%)"
  echo -e "In Progress: ${YELLOW}$IN_PROGRESS${NC}"
  echo -e "Blocked: ${RED}$BLOCKED${NC}"
  echo -e "Available Today: ${GREEN}$AVAILABLE${NC}"
  echo ""
  echo -e "Full report: ${BLUE}$REPORT_FILE${NC}"
  echo ""
}

# ========================================
# Main Execution
# ========================================

main() {
  log "Starting daily validation workflow..."

  load_tasks

  generate_header
  calculate_metrics
  validate_yesterday
  list_available_tasks
  list_in_progress
  list_blocked
  calculate_velocity
  generate_recommendations
  track_risks
  generate_footer

  send_email_notification

  if [ "$REPORT_ONLY" = false ]; then
    print_console_summary
  fi

  log_success "Daily report generated: $REPORT_FILE"
}

main
