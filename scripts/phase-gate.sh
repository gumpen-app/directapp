#!/usr/bin/env bash
#
# Phase Gate Validation Script
# DirectApp Phase 1 → Phase 2 Gate
#
# Purpose: Validate ALL Phase 1 requirements before allowing Phase 2
# Usage: ./scripts/phase-gate.sh [--force] [--detailed]
#
# Exit Codes:
#   0 - GO: All checks passed, proceed to Phase 2
#   1 - NO-GO: Critical failures, cannot proceed
#   2 - REVIEW: Minor issues, requires stakeholder approval

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Task tracker
TASK_TRACKER="$PROJECT_ROOT/task-tracker.json"

# Options
FORCE=false
DETAILED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE=true
      shift
      ;;
    --detailed)
      DETAILED=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--force] [--detailed]"
      exit 1
      ;;
  esac
done

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# ========================================
# Helper Functions
# ========================================

log_section() {
  echo ""
  echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
  echo -e "${MAGENTA}$1${NC}"
  echo -e "${MAGENTA}═══════════════════════════════════════════${NC}"
}

log_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

log_fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED++))
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# ========================================
# GATE 1: All Tasks Complete
# ========================================

check_all_tasks_complete() {
  log_section "GATE 1: Task Completion"

  if [ ! -f "$TASK_TRACKER" ]; then
    log_fail "Task tracker not found: $TASK_TRACKER"
    return
  fi

  if ! command -v jq &> /dev/null; then
    log_fail "jq not installed (required for validation)"
    return
  fi

  # Total tasks
  TOTAL=$(jq '.phases[0].tasks | length' "$TASK_TRACKER")
  COMPLETED=$(jq '[.phases[0].tasks[] | select(.status == "completed")] | length' "$TASK_TRACKER")
  IN_PROGRESS=$(jq '[.phases[0].tasks[] | select(.status == "in_progress")] | length' "$TASK_TRACKER")
  PENDING=$(jq '[.phases[0].tasks[] | select(.status == "pending")] | length' "$TASK_TRACKER")

  log_info "Total tasks: $TOTAL"
  log_info "Completed: $COMPLETED"
  log_info "In progress: $IN_PROGRESS"
  log_info "Pending: $PENDING"

  if [ "$COMPLETED" -eq "$TOTAL" ]; then
    log_pass "All $TOTAL tasks completed"
  else
    INCOMPLETE=$((TOTAL - COMPLETED))
    log_fail "$INCOMPLETE tasks not completed ($IN_PROGRESS in progress, $PENDING pending)"

    if [ "$DETAILED" = true ]; then
      echo ""
      echo "Incomplete tasks:"
      jq -r '.phases[0].tasks[] | select(.status != "completed") | "  - \(.task_id): \(.title) (\(.status))"' "$TASK_TRACKER"
    fi
  fi

  # Check exit criteria validation
  UNVALIDATED=$(jq '[.phases[0].tasks[] | select(.status == "completed" and .exit_criteria_validated == false)] | length' "$TASK_TRACKER")

  if [ "$UNVALIDATED" -eq 0 ]; then
    log_pass "All completed tasks have validated exit criteria"
  else
    log_warn "$UNVALIDATED completed tasks have unvalidated exit criteria"

    if [ "$DETAILED" = true ]; then
      echo ""
      echo "Tasks with unvalidated exit criteria:"
      jq -r '.phases[0].tasks[] | select(.status == "completed" and .exit_criteria_validated == false) | "  - \(.task_id): \(.title)"' "$TASK_TRACKER"
    fi
  fi
}

# ========================================
# GATE 2: Success Criteria Met
# ========================================

check_success_criteria() {
  log_section "GATE 2: Success Criteria"

  # From IMPROVEMENT_RECOMMENDATIONS.md success metrics
  SUCCESS_CRITERIA=(
    "Security Score: 2.5 → 7.0 (target: ≥7.0)"
    "Data Isolation: 0% → 100% (target: 100%)"
    "Permission Coverage: ? → ? (target: ≥95%)"
    "Workflow Validation: 0 → 100% (target: 100%)"
    "Performance: Baseline → +75-92% (target: +75%)"
    "Vehicle Lookup: Manual → Automated (target: Deployed)"
  )

  log_info "Phase 1 Success Criteria:"
  for criterion in "${SUCCESS_CRITERIA[@]}"; do
    echo "  - $criterion"
  done

  echo ""
  log_warn "Manual validation required for success criteria (no automated metrics available)"

  # Prompt for manual confirmation
  if [ "$FORCE" = false ]; then
    read -p "Have all success criteria been met? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Success criteria confirmed by operator"
    else
      log_fail "Success criteria NOT met (operator confirmation)"
    fi
  else
    log_warn "Skipping manual confirmation (--force mode)"
  fi
}

# ========================================
# GATE 3: Tests Passing
# ========================================

check_tests_passing() {
  log_section "GATE 3: Test Validation"

  # Expected test results from Agent 3 strategy
  EXPECTED_TESTS=(
    "40 data isolation tests (IMP-001-T4)"
    "10 DELETE permission tests (IMP-002-T3)"
    "5 workflow validation tests (IMP-003-T3)"
    "3 vehicle lookup tests (IMP-004-T2)"
    "2 mechanic permission tests (IMP-005-T2)"
    "5 index performance benchmarks (IMP-006-T3)"
  )

  log_info "Expected test coverage:"
  for test_suite in "${EXPECTED_TESTS[@]}"; do
    echo "  - $test_suite"
  done

  echo ""

  # Check test results from task-tracker
  TESTS_PASSED=$(jq '[.phases[0].tasks[] | select(.status == "completed" and .tests_passed == true)] | length' "$TASK_TRACKER")
  TESTS_FAILED=$(jq '[.phases[0].tasks[] | select(.status == "completed" and .tests_passed == false)] | length' "$TASK_TRACKER")

  log_info "Tests passed: $TESTS_PASSED tasks"
  log_info "Tests failed: $TESTS_FAILED tasks"

  if [ "$TESTS_FAILED" -eq 0 ]; then
    log_pass "All tests passing"
  else
    log_fail "$TESTS_FAILED tasks have failing tests"

    if [ "$DETAILED" = true ]; then
      echo ""
      echo "Tasks with failing tests:"
      jq -r '.phases[0].tasks[] | select(.status == "completed" and .tests_passed == false) | "  - \(.task_id): \(.title)"' "$TASK_TRACKER"
    fi
  fi

  # Check for regression tests (manual verification)
  log_warn "Regression test suite verification required (manual)"

  if [ "$FORCE" = false ]; then
    read -p "Have all regression tests passed? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Regression tests confirmed passing"
    else
      log_fail "Regression tests NOT passing"
    fi
  fi
}

# ========================================
# GATE 4: Documentation Complete
# ========================================

check_documentation() {
  log_section "GATE 4: Documentation"

  # Expected deliverables from Agent 2 (14 documents)
  EXPECTED_DOCS=(
    "DATA_ISOLATION_IMPACT_ANALYSIS.md"
    "PERMISSION_TEST_PLAN.md"
    "PERMISSION_TEST_RESULTS.md"
    "DATA_ISOLATION_IMPLEMENTATION.md"
    "DELETE_PERMISSIONS_PLAN.md"
    "DELETE_PERMISSIONS_TEST_RESULTS.md"
    "WORKFLOW_GUARD_TEST_RESULTS.md"
    "VEHICLE_LOOKUP_SETUP.md"
    "HOW_TO_USE_VEHICLE_LOOKUP.md"
    "VEHICLE_LOOKUP_TEST_RESULTS.md"
    "MECHANIC_PERMISSION_TEST_RESULTS.md"
    "INDEX_PERFORMANCE_BASELINE.md"
    "INDEX_PERFORMANCE_COMPARISON.md"
    "INDEX_DEPLOYMENT_REPORT.md"
  )

  DOCS_FOUND=0
  DOCS_MISSING=0

  for doc in "${EXPECTED_DOCS[@]}"; do
    if [ -f "$PROJECT_ROOT/$doc" ] || [ -f "$PROJECT_ROOT/docs/$doc" ]; then
      log_pass "$doc found"
      ((DOCS_FOUND++))
    else
      log_fail "$doc missing"
      ((DOCS_MISSING++))
    fi
  done

  log_info "Documentation: $DOCS_FOUND/${#EXPECTED_DOCS[@]} found"

  if [ "$DOCS_MISSING" -eq 0 ]; then
    log_pass "All documentation deliverables present"
  else
    log_fail "$DOCS_MISSING documentation files missing"
  fi
}

# ========================================
# GATE 5: Deployment Status
# ========================================

check_deployment() {
  log_section "GATE 5: Deployment Status"

  # Check staging deployment
  log_info "Checking staging deployment..."

  if [ "$FORCE" = false ]; then
    read -p "Have all changes been deployed to staging? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Staging deployment confirmed"
    else
      log_fail "Changes NOT deployed to staging"
    fi

    read -p "Has staging been tested and verified? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Staging testing confirmed"
    else
      log_fail "Staging testing NOT complete"
    fi
  else
    log_warn "Skipping deployment checks (--force mode)"
  fi
}

# ========================================
# GATE 6: Stakeholder Sign-off
# ========================================

check_stakeholder_approval() {
  log_section "GATE 6: Stakeholder Approval"

  STAKEHOLDERS=("Product Owner" "Tech Lead" "QA Lead")

  log_info "Required sign-offs:"
  for stakeholder in "${STAKEHOLDERS[@]}"; do
    echo "  - $stakeholder"
  done

  echo ""

  if [ "$FORCE" = false ]; then
    read -p "Have all stakeholders approved Phase 1 completion? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Stakeholder sign-off obtained"
    else
      log_fail "Stakeholder sign-off NOT obtained"
    fi
  else
    log_warn "Skipping stakeholder approval (--force mode)"
  fi
}

# ========================================
# GATE 7: Risk Assessment
# ========================================

check_risks() {
  log_section "GATE 7: Risk Assessment"

  # 10 critical risks from Agent 1
  RISKS=(
    "RISK-001: IMP-001 complexity (actual vs estimate)"
    "RISK-002: IMP-006 index creation time"
    "RISK-003: IMP-010 RBAC complexity"
    "RISK-004: IMP-022 testing framework"
    "RISK-005: IMP-024 schema import"
    "RISK-006: Cross-dealership edge cases"
    "RISK-007: Timeline buffer usage"
    "RISK-008: Phase gate failures"
    "RISK-009: Data isolation validation"
    "RISK-010: Rollback complexity"
  )

  log_info "Risk status review:"
  for risk in "${RISKS[@]}"; do
    echo "  - $risk"
  done

  echo ""
  log_warn "Manual risk assessment required"

  if [ "$FORCE" = false ]; then
    read -p "Have all critical risks been mitigated or accepted? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Risk assessment complete"
    else
      log_warn "Outstanding risks require attention"
    fi
  fi
}

# ========================================
# GATE 8: Performance Metrics
# ========================================

check_performance() {
  log_section "GATE 8: Performance Validation"

  # Expected improvements from IMP-006
  PERFORMANCE_TARGETS=(
    "Query 1 (cars filter): 500ms → 45ms (91% improvement)"
    "Query 2 (mechanic workload): 350ms → 52ms (85% improvement)"
    "Query 3 (capacity provider): 280ms → 70ms (75% improvement)"
    "Query 4 (bookings date): 220ms → 48ms (78% improvement)"
    "Query 5 (capacity lookup): 180ms → 15ms (92% improvement)"
  )

  log_info "Performance targets:"
  for target in "${PERFORMANCE_TARGETS[@]}"; do
    echo "  - $target"
  done

  echo ""

  # Check if INDEX_PERFORMANCE_COMPARISON.md exists
  if [ -f "$PROJECT_ROOT/INDEX_PERFORMANCE_COMPARISON.md" ]; then
    log_pass "Performance comparison document found"
  else
    log_fail "INDEX_PERFORMANCE_COMPARISON.md missing"
  fi

  log_warn "Manual performance validation required (check INDEX_PERFORMANCE_COMPARISON.md)"

  if [ "$FORCE" = false ]; then
    read -p "Have performance targets been met? (yes/no): " response
    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      log_pass "Performance targets confirmed"
    else
      log_fail "Performance targets NOT met"
    fi
  fi
}

# ========================================
# Final Decision
# ========================================

make_decision() {
  log_section "PHASE GATE DECISION"

  TOTAL=$((PASSED + FAILED + WARNINGS))

  echo ""
  echo -e "Gate Results:"
  echo -e "  ${GREEN}Passed:${NC}   $PASSED"
  echo -e "  ${RED}Failed:${NC}   $FAILED"
  echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
  echo -e "  Total:    $TOTAL"
  echo ""

  if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
      echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
      echo -e "${GREEN}║              ✓ GO - PROCEED              ║${NC}"
      echo -e "${GREEN}║    Phase 1 Complete - Start Phase 2     ║${NC}"
      echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
      echo ""
      echo "All phase gate criteria met."
      echo "Authorized to proceed with Phase 2 implementation."
      echo ""
      return 0
    else
      echo -e "${YELLOW}╔═══════════════════════════════════════════╗${NC}"
      echo -e "${YELLOW}║           ⚠ REVIEW REQUIRED             ║${NC}"
      echo -e "${YELLOW}║   Minor Issues - Stakeholder Decision    ║${NC}"
      echo -e "${YELLOW}╚═══════════════════════════════════════════╝${NC}"
      echo ""
      echo "Some warnings present. Review with stakeholders before proceeding."
      echo "Use --force to override and proceed anyway (not recommended)."
      echo ""
      return 2
    fi
  else
    echo -e "${RED}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${RED}║            ✗ NO-GO - BLOCKED             ║${NC}"
    echo -e "${RED}║   Critical Failures - Cannot Proceed     ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════╝${NC}"
    echo ""
    echo "Critical phase gate failures detected."
    echo "Address all failures before proceeding to Phase 2."
    echo ""
    echo "Failure details:"
    echo "  - $FAILED critical checks failed"
    echo "  - Review output above for specific issues"
    echo ""
    return 1
  fi
}

# ========================================
# Main Execution
# ========================================

main() {
  echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║       DirectApp Phase 1 → Phase 2         ║${NC}"
  echo -e "${CYAN}║           Phase Gate Validation           ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"

  if [ "$FORCE" = true ]; then
    echo -e "${YELLOW}⚠ FORCE MODE ENABLED - Skipping manual confirmations${NC}"
  fi

  check_all_tasks_complete
  check_success_criteria
  check_tests_passing
  check_documentation
  check_deployment
  check_stakeholder_approval
  check_risks
  check_performance

  make_decision
  exit $?
}

main
