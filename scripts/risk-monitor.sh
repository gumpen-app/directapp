#!/usr/bin/env bash
#
# Risk Monitoring Script
# DirectApp Phase 1 Implementation
#
# Purpose: Track 10 critical risks and alert on threshold breaches
# Usage: ./scripts/risk-monitor.sh [--alert] [--detailed]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Risk data file
RISK_DATA="$PROJECT_ROOT/risk-tracking.json"
TASK_TRACKER="$PROJECT_ROOT/task-tracker.json"

# Options
SEND_ALERTS=false
DETAILED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --alert)
      SEND_ALERTS=true
      shift
      ;;
    --detailed)
      DETAILED=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# ========================================
# Initialize Risk Data
# ========================================

initialize_risk_data() {
  if [ ! -f "$RISK_DATA" ]; then
    log "Initializing risk tracking data..."

    cat > "$RISK_DATA" << 'EOF'
{
  "last_updated": null,
  "risks": [
    {
      "risk_id": "RISK-001",
      "title": "IMP-001 Data Isolation Complexity",
      "related_task": "IMP-001",
      "estimated_effort": "12h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "4-6 week buffer, phased implementation",
      "impact_if_realized": "2-day delay, incomplete data isolation",
      "probability": "medium"
    },
    {
      "risk_id": "RISK-002",
      "title": "IMP-006 Index Creation Time",
      "related_task": "IMP-006",
      "estimated_effort": "2h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Create indices during low-traffic periods",
      "impact_if_realized": "Database locks, service downtime",
      "probability": "low"
    },
    {
      "risk_id": "RISK-003",
      "title": "IMP-010 RBAC Complexity",
      "related_task": "IMP-010",
      "estimated_effort": "8h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Nested permission patterns, thorough testing",
      "impact_if_realized": "1-day delay, permission bugs",
      "probability": "medium"
    },
    {
      "risk_id": "RISK-004",
      "title": "IMP-022 Testing Framework Setup",
      "related_task": "IMP-022",
      "estimated_effort": "6h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Use existing Vitest setup",
      "impact_if_realized": "Testing delays, reduced coverage",
      "probability": "low"
    },
    {
      "risk_id": "RISK-005",
      "title": "IMP-024 Schema Import Conflicts",
      "related_task": "IMP-024",
      "estimated_effort": "4h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Careful schema diff review",
      "impact_if_realized": "Data loss, schema corruption",
      "probability": "medium"
    },
    {
      "risk_id": "RISK-006",
      "title": "Cross-Dealership Resource Sharing Edge Cases",
      "related_task": "IMP-001",
      "estimated_effort": "N/A",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Special filter for resource_bookings: provider OR consumer",
      "impact_if_realized": "Incorrect data visibility",
      "probability": "medium"
    },
    {
      "risk_id": "RISK-007",
      "title": "Timeline Buffer Consumption",
      "related_task": null,
      "estimated_effort": "N/A",
      "threshold_multiplier": 1.0,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "4-6 week buffer available",
      "impact_if_realized": "Phase 2 delayed, missed deadlines",
      "probability": "high"
    },
    {
      "risk_id": "RISK-008",
      "title": "Phase Gate Failures",
      "related_task": null,
      "estimated_effort": "N/A",
      "threshold_multiplier": 1.0,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Daily validation, clear exit criteria",
      "impact_if_realized": "Cannot proceed to Phase 2",
      "probability": "low"
    },
    {
      "risk_id": "RISK-009",
      "title": "Data Isolation Test Failures",
      "related_task": "IMP-001-T4",
      "estimated_effort": "4h",
      "threshold_multiplier": 1.5,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "40 comprehensive test cases",
      "impact_if_realized": "Security breach, data leaks",
      "probability": "medium"
    },
    {
      "risk_id": "RISK-010",
      "title": "Rollback Complexity",
      "related_task": null,
      "estimated_effort": "N/A",
      "threshold_multiplier": 1.0,
      "status": "active",
      "actual_effort": null,
      "overrun_percentage": 0,
      "mitigation": "Detailed rollback procedures in each task",
      "impact_if_realized": "Extended downtime, data loss",
      "probability": "low"
    }
  ],
  "alerts": []
}
EOF

    log_success "Risk data initialized: $RISK_DATA"
  fi
}

# ========================================
# Helper Functions
# ========================================

log() {
  echo -e "${BLUE}[RISK]${NC} $1"
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

log_alert() {
  echo -e "${RED}[ALERT]${NC} $1"
}

# ========================================
# Update Risk Status from Tasks
# ========================================

update_risk_status() {
  log "Updating risk status from task tracker..."

  if [ ! -f "$TASK_TRACKER" ]; then
    log_error "Task tracker not found: $TASK_TRACKER"
    return
  fi

  if ! command -v jq &> /dev/null; then
    log_error "jq not installed"
    return
  fi

  # Update timestamp
  jq --arg timestamp "$(date -Iseconds)" '.last_updated = $timestamp' "$RISK_DATA" > "$RISK_DATA.tmp" && mv "$RISK_DATA.tmp" "$RISK_DATA"

  # For each risk, check if related task has actual effort
  for i in $(seq 0 9); do
    RISK_ID=$(jq -r ".risks[$i].risk_id" "$RISK_DATA")
    RELATED_TASK=$(jq -r ".risks[$i].related_task" "$RISK_DATA")

    if [ "$RELATED_TASK" != "null" ] && [ -n "$RELATED_TASK" ]; then
      # Find actual effort from task tracker
      ACTUAL_EFFORT=$(jq -r --arg task "$RELATED_TASK" '
        [.phases[0].tasks[] | select(.task_id | startswith($task)) | .actual_effort] |
        map(select(. != null)) |
        first // null
      ' "$TASK_TRACKER")

      if [ "$ACTUAL_EFFORT" != "null" ] && [ -n "$ACTUAL_EFFORT" ]; then
        # Update risk data
        jq --argjson index "$i" --arg effort "$ACTUAL_EFFORT" '
          .risks[$index].actual_effort = $effort
        ' "$RISK_DATA" > "$RISK_DATA.tmp" && mv "$RISK_DATA.tmp" "$RISK_DATA"
      fi
    fi
  done
}

# ========================================
# Calculate Risk Metrics
# ========================================

calculate_risk_metrics() {
  log "Calculating risk metrics..."

  for i in $(seq 0 9); do
    RISK_ID=$(jq -r ".risks[$i].risk_id" "$RISK_DATA")
    ESTIMATED=$(jq -r ".risks[$i].estimated_effort" "$RISK_DATA")
    ACTUAL=$(jq -r ".risks[$i].actual_effort" "$RISK_DATA")
    THRESHOLD=$(jq -r ".risks[$i].threshold_multiplier" "$RISK_DATA")

    if [ "$ESTIMATED" != "N/A" ] && [ "$ACTUAL" != "null" ] && [ -n "$ACTUAL" ]; then
      # Extract hours (assume format like "12h")
      EST_HOURS=$(echo "$ESTIMATED" | grep -oE '[0-9]+' || echo "0")
      ACT_HOURS=$(echo "$ACTUAL" | grep -oE '[0-9.]+' || echo "0")

      if [ "$EST_HOURS" != "0" ]; then
        # Calculate overrun percentage
        OVERRUN=$(echo "scale=1; (($ACT_HOURS - $EST_HOURS) / $EST_HOURS) * 100" | bc)

        # Update risk data
        jq --argjson index "$i" --argjson overrun "$OVERRUN" '
          .risks[$index].overrun_percentage = $overrun
        ' "$RISK_DATA" > "$RISK_DATA.tmp" && mv "$RISK_DATA.tmp" "$RISK_DATA"
      fi
    fi
  done
}

# ========================================
# Check Alert Thresholds
# ========================================

check_alert_thresholds() {
  log "Checking alert thresholds..."

  ALERTS=()

  for i in $(seq 0 9); do
    RISK_ID=$(jq -r ".risks[$i].risk_id" "$RISK_DATA")
    OVERRUN=$(jq -r ".risks[$i].overrun_percentage" "$RISK_DATA")
    THRESHOLD=$(jq -r ".risks[$i].threshold_multiplier" "$RISK_DATA")
    TITLE=$(jq -r ".risks[$i].title" "$RISK_DATA")

    THRESHOLD_PCT=$(echo "scale=0; ($THRESHOLD - 1) * 100" | bc)

    if [ "$OVERRUN" != "0" ] && [ "$OVERRUN" != "null" ]; then
      # Check if overrun exceeds threshold
      if (( $(echo "$OVERRUN > $THRESHOLD_PCT" | bc -l) )); then
        ALERT_MSG="$RISK_ID: $TITLE - Overrun ${OVERRUN}% (threshold: ${THRESHOLD_PCT}%)"
        ALERTS+=("$ALERT_MSG")
        log_alert "$ALERT_MSG"

        # Add to alerts array in JSON
        jq --arg alert "$ALERT_MSG" --arg timestamp "$(date -Iseconds)" '
          .alerts += [{"timestamp": $timestamp, "message": $alert}]
        ' "$RISK_DATA" > "$RISK_DATA.tmp" && mv "$RISK_DATA.tmp" "$RISK_DATA"
      fi
    fi
  done

  # Additional checks

  # Check test failure rate
  if [ -f "$TASK_TRACKER" ]; then
    COMPLETED=$(jq '[.phases[0].tasks[] | select(.status == "completed")] | length' "$TASK_TRACKER")
    FAILED_TESTS=$(jq '[.phases[0].tasks[] | select(.status == "completed" and .tests_passed == false)] | length' "$TASK_TRACKER")

    if [ "$COMPLETED" -gt 0 ]; then
      FAIL_RATE=$(echo "scale=1; ($FAILED_TESTS / $COMPLETED) * 100" | bc)

      if (( $(echo "$FAIL_RATE > 10" | bc -l) )); then
        ALERT_MSG="Test failure rate: ${FAIL_RATE}% (threshold: 10%)"
        ALERTS+=("$ALERT_MSG")
        log_alert "$ALERT_MSG"
      fi
    fi
  fi

  # Check buffer usage (assume 4-6 week = 20-30 days buffer)
  TARGET_DATE=$(date -d "2025-11-15" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "2025-11-15" +%s 2>/dev/null || echo 0)
  TODAY_DATE=$(date +%s)
  DAYS_UNTIL_TARGET=$(( (TARGET_DATE - TODAY_DATE) / 86400 ))

  if [ "$DAYS_UNTIL_TARGET" -lt 5 ]; then
    ALERT_MSG="Timeline buffer critically low: $DAYS_UNTIL_TARGET days until Phase 1 target"
    ALERTS+=("$ALERT_MSG")
    log_alert "$ALERT_MSG"
  fi

  if [ ${#ALERTS[@]} -gt 0 ]; then
    log_error "${#ALERTS[@]} alert(s) triggered"
  else
    log_success "No alerts triggered"
  fi
}

# ========================================
# Generate Risk Dashboard
# ========================================

generate_dashboard() {
  log "Generating risk dashboard..."

  echo ""
  echo -e "${MAGENTA}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${MAGENTA}║         Risk Monitoring Dashboard        ║${NC}"
  echo -e "${MAGENTA}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  LAST_UPDATED=$(jq -r '.last_updated' "$RISK_DATA")
  echo -e "Last Updated: ${BLUE}$LAST_UPDATED${NC}"
  echo ""

  # Risk summary table
  echo -e "${CYAN}Risk Status Summary:${NC}"
  echo ""
  printf "%-10s %-35s %-12s %-12s %-10s\n" "Risk ID" "Title" "Estimated" "Actual" "Overrun"
  echo "─────────────────────────────────────────────────────────────────────────────────"

  for i in $(seq 0 9); do
    RISK_ID=$(jq -r ".risks[$i].risk_id" "$RISK_DATA")
    TITLE=$(jq -r ".risks[$i].title" "$RISK_DATA" | cut -c1-35)
    ESTIMATED=$(jq -r ".risks[$i].estimated_effort" "$RISK_DATA")
    ACTUAL=$(jq -r ".risks[$i].actual_effort" "$RISK_DATA")
    OVERRUN=$(jq -r ".risks[$i].overrun_percentage" "$RISK_DATA")

    if [ "$ACTUAL" = "null" ]; then
      ACTUAL="--"
    fi

    if [ "$OVERRUN" = "0" ] || [ "$OVERRUN" = "null" ]; then
      OVERRUN_DISPLAY="--"
    else
      # Color code overrun
      if (( $(echo "$OVERRUN > 50" | bc -l) )); then
        OVERRUN_DISPLAY="${RED}${OVERRUN}%${NC}"
      elif (( $(echo "$OVERRUN > 20" | bc -l) )); then
        OVERRUN_DISPLAY="${YELLOW}${OVERRUN}%${NC}"
      else
        OVERRUN_DISPLAY="${GREEN}${OVERRUN}%${NC}"
      fi
    fi

    printf "%-10s %-35s %-12s %-12s %s\n" "$RISK_ID" "$TITLE" "$ESTIMATED" "$ACTUAL" "$OVERRUN_DISPLAY"
  done

  echo ""

  # Active alerts
  ALERT_COUNT=$(jq '.alerts | length' "$RISK_DATA")
  echo -e "${CYAN}Active Alerts: $ALERT_COUNT${NC}"

  if [ "$ALERT_COUNT" -gt 0 ]; then
    jq -r '.alerts[-5:] | .[] | "  ⚠ \(.timestamp): \(.message)"' "$RISK_DATA"
  else
    echo "  No active alerts"
  fi

  echo ""

  # Detailed view
  if [ "$DETAILED" = true ]; then
    echo -e "${CYAN}Detailed Risk Information:${NC}"
    echo ""

    for i in $(seq 0 9); do
      RISK_ID=$(jq -r ".risks[$i].risk_id" "$RISK_DATA")
      TITLE=$(jq -r ".risks[$i].title" "$RISK_DATA")
      PROBABILITY=$(jq -r ".risks[$i].probability" "$RISK_DATA")
      IMPACT=$(jq -r ".risks[$i].impact_if_realized" "$RISK_DATA")
      MITIGATION=$(jq -r ".risks[$i].mitigation" "$RISK_DATA")

      echo -e "${YELLOW}$RISK_ID: $TITLE${NC}"
      echo "  Probability: $PROBABILITY"
      echo "  Impact: $IMPACT"
      echo "  Mitigation: $MITIGATION"
      echo ""
    done
  fi
}

# ========================================
# Send Email Alerts
# ========================================

send_email_alerts() {
  if [ "$SEND_ALERTS" = true ]; then
    ALERT_COUNT=$(jq '.alerts | length' "$RISK_DATA")

    if [ "$ALERT_COUNT" -gt 0 ]; then
      log "Sending email alerts..."

      EMAIL_TO="${DIRECTAPP_EMAIL_TO:-team@example.com}"
      EMAIL_SUBJECT="DirectApp Risk Alert - $ALERT_COUNT alert(s)"

      # Create email body
      EMAIL_BODY=$(mktemp)
      {
        echo "DirectApp Risk Monitoring Alert"
        echo "================================"
        echo ""
        echo "Alert Count: $ALERT_COUNT"
        echo ""
        echo "Recent Alerts:"
        jq -r '.alerts[-5:] | .[] | "  - \(.timestamp): \(.message)"' "$RISK_DATA"
        echo ""
        echo "Full dashboard: $PROJECT_ROOT/risk-tracking.json"
      } > "$EMAIL_BODY"

      if command -v mail &> /dev/null; then
        mail -s "$EMAIL_SUBJECT" "$EMAIL_TO" < "$EMAIL_BODY"
        log_success "Email alert sent to $EMAIL_TO"
      else
        log_warn "mail command not available. Email not sent."
      fi

      rm "$EMAIL_BODY"
    else
      log "No alerts to send"
    fi
  fi
}

# ========================================
# Main Execution
# ========================================

main() {
  initialize_risk_data
  update_risk_status
  calculate_risk_metrics
  check_alert_thresholds
  generate_dashboard
  send_email_alerts

  log_success "Risk monitoring complete"
}

main
