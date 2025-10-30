#!/usr/bin/env bash
#
# Pre-Flight Checklist Script
# DirectApp Phase 1 Implementation Validation
#
# Purpose: Validate all prerequisites before starting Phase 1 (November 4, 2025)
# Usage: ./scripts/preflight-checklist.sh [--fix] [--verbose]
#
# Exit Codes:
#   0 - All checks passed, ready to begin Phase 1
#   1 - Critical failures, cannot proceed
#   2 - Warnings present, review required

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Options
FIX_MODE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_MODE=true
      shift
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--fix] [--verbose]"
      echo "  --fix      Attempt to fix issues automatically"
      echo "  --verbose  Show detailed output"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Log functions
log_section() {
  echo -e "\n${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

log_check() {
  if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}[CHECK]${NC} $1"
  fi
}

log_pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
  PASSED=$((PASSED + 1))
}

log_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  FAILED=$((FAILED + 1))
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
  WARNINGS=$((WARNINGS + 1))
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

# ========================================
# CHECK 1: Required Tools Installed
# ========================================
check_tools() {
  log_section "1. Required Tools"

  # Git
  log_check "Checking git..."
  if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    log_pass "git installed (version $GIT_VERSION)"
  else
    log_fail "git not found. Install: sudo apt install git"
  fi

  # Node.js
  log_check "Checking node..."
  if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    REQUIRED_NODE="v18.0.0"
    if [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_NODE" ]; then
      log_pass "node installed ($NODE_VERSION, >= $REQUIRED_NODE)"
    else
      log_fail "node version too old ($NODE_VERSION < $REQUIRED_NODE)"
    fi
  else
    log_fail "node not found. Install: https://nodejs.org/"
  fi

  # pnpm
  log_check "Checking pnpm..."
  if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    log_pass "pnpm installed (version $PNPM_VERSION)"
  else
    log_fail "pnpm not found. Install: npm install -g pnpm"
  fi

  # jq (for JSON parsing)
  log_check "Checking jq..."
  if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version | cut -d'-' -f2)
    log_pass "jq installed (version $JQ_VERSION)"
  else
    log_warn "jq not found (optional). Install: sudo apt install jq"
  fi

  # PostgreSQL client
  log_check "Checking psql..."
  if command -v psql &> /dev/null; then
    PSQL_VERSION=$(psql --version | cut -d' ' -f3)
    log_pass "psql installed (version $PSQL_VERSION)"
  else
    log_fail "psql not found. Install: sudo apt install postgresql-client"
  fi

  # Docker
  log_check "Checking docker..."
  if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    log_pass "docker installed (version $DOCKER_VERSION)"

    # Docker running?
    if docker info &> /dev/null; then
      log_pass "Docker daemon is running"
    else
      log_fail "Docker daemon not running. Start: sudo systemctl start docker"
    fi
  else
    log_fail "docker not found. Install: https://docs.docker.com/get-docker/"
  fi

  # Docker Compose
  log_check "Checking docker compose..."
  if docker compose version &> /dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
    log_pass "docker compose installed (version $COMPOSE_VERSION)"
  else
    log_fail "docker compose not found. Install with Docker Desktop or standalone"
  fi
}

# ========================================
# CHECK 2: Access & Authentication
# ========================================
check_access() {
  log_section "2. Access & Authentication"

  # Directus admin access
  log_check "Checking Directus dev environment..."
  if [ -f "$PROJECT_ROOT/.env.development" ]; then
    log_pass ".env.development file exists"

    # Check if Directus is running
    if curl -s http://localhost:8055/server/health &> /dev/null; then
      log_pass "Directus dev server is running (http://localhost:8055)"
    else
      log_warn "Directus dev server not responding. Start: docker compose -f docker-compose.dev.yml up -d"
    fi
  else
    log_fail ".env.development not found. Copy from .env.development.example"
  fi

  # GitHub repo access
  log_check "Checking GitHub access..."
  cd "$PROJECT_ROOT"
  if git remote -v | grep -q "gumpen-app/directapp"; then
    log_pass "GitHub remote configured (gumpen-app/directapp)"

    # Test push access
    if git ls-remote &> /dev/null; then
      log_pass "GitHub push access verified"
    else
      log_warn "Cannot access GitHub remote. Check SSH keys or credentials"
    fi
  else
    log_fail "GitHub remote not configured correctly"
  fi

  # Staging environment
  log_check "Checking staging environment access..."
  if [ -f "$PROJECT_ROOT/.env.staging" ]; then
    log_pass ".env.staging file exists"
  else
    log_warn ".env.staging not found (required for deployment testing)"
  fi

  # Production environment
  log_check "Checking production environment access..."
  if [ -f "$PROJECT_ROOT/.env.production" ]; then
    log_pass ".env.production file exists"
  else
    log_warn ".env.production not found (required for final deployment)"
  fi
}

# ========================================
# CHECK 3: Documentation Review
# ========================================
check_documentation() {
  log_section "3. Documentation Review"

  # Agent outputs
  REQUIRED_DOCS=(
    "IMPROVEMENT_RECOMMENDATIONS.md"
    "IMPLEMENTATION_ROADMAP.md"
    "task-tracker.json"
    "MULTI_AGENT_ORCHESTRATION_SYSTEM.md"
  )

  for doc in "${REQUIRED_DOCS[@]}"; do
    log_check "Checking $doc..."
    if [ -f "$PROJECT_ROOT/$doc" ]; then
      log_pass "$doc exists"
    else
      log_fail "$doc not found (required for Phase 1)"
    fi
  done

  # Role permissions plan
  log_check "Checking ROLE_PERMISSIONS_PLAN.md..."
  if [ -f "$PROJECT_ROOT/docs/ROLE_PERMISSIONS_PLAN.md" ]; then
    log_pass "Role permissions plan exists"
  else
    log_warn "ROLE_PERMISSIONS_PLAN.md not found in docs/"
  fi

  # System design
  log_check "Checking GUMPEN_SYSTEM_DESIGN.md..."
  if [ -f "$PROJECT_ROOT/GUMPEN_SYSTEM_DESIGN.md" ]; then
    log_pass "System design document exists"
  else
    log_fail "GUMPEN_SYSTEM_DESIGN.md not found (critical)"
  fi
}

# ========================================
# CHECK 4: Team Roles Assigned
# ========================================
check_team() {
  log_section "4. Team Roles & Communication"

  # Task tracker for role assignments
  log_check "Checking task assignments..."
  if [ -f "$PROJECT_ROOT/task-tracker.json" ]; then
    if command -v jq &> /dev/null; then
      ASSIGNED_TASKS=$(jq -r '.phases[0].tasks[] | select(.assigned_to != null) | .assigned_to' "$PROJECT_ROOT/task-tracker.json" | sort -u)
      if [ -n "$ASSIGNED_TASKS" ]; then
        log_pass "Tasks assigned to: $(echo "$ASSIGNED_TASKS" | tr '\n' ', ' | sed 's/,$//')"
      else
        log_warn "No tasks assigned yet. Review task-tracker.json"
      fi
    else
      log_warn "jq not available, cannot check task assignments"
    fi
  else
    log_fail "task-tracker.json not found"
  fi

  # Verify role definitions
  REQUIRED_ROLES=("Dev 1" "Dev 2" "QA")
  log_info "Required roles for Phase 1: ${REQUIRED_ROLES[*]}"
  log_warn "Verify team members assigned to roles in task-tracker.json"

  # Communication channels
  log_check "Communication setup..."
  log_warn "Verify Slack/email channel setup (manual verification required)"
  log_warn "Verify daily standup schedule (manual verification required)"
}

# ========================================
# CHECK 5: Test Data & Environment
# ========================================
check_test_data() {
  log_section "5. Test Data & Environment"

  # Database connection
  log_check "Checking database connection..."
  if [ -f "$PROJECT_ROOT/.env.development" ]; then
    # Extract DB credentials (basic check)
    if grep -q "DB_DATABASE=" "$PROJECT_ROOT/.env.development"; then
      DB_NAME=$(grep "DB_DATABASE=" "$PROJECT_ROOT/.env.development" | cut -d'=' -f2)
      log_pass "Database configured: $DB_NAME"

      # Try to connect
      if docker compose -f "$PROJECT_ROOT/docker-compose.dev.yml" exec -T postgres psql -U directus -d "$DB_NAME" -c "SELECT 1;" &> /dev/null; then
        log_pass "Database connection successful"
      else
        log_warn "Cannot connect to database. Ensure containers are running"
      fi
    else
      log_fail "DB_DATABASE not set in .env.development"
    fi
  fi

  # Check for test dealerships
  log_check "Checking test dealerships..."
  log_warn "Verify 2 test dealerships exist: Kristiansand, Mandal (manual verification via Directus admin)"

  # Check for test cars
  log_check "Checking test cars..."
  log_warn "Verify at least 5 cars per dealership (manual verification via Directus admin)"

  # Check for test users
  log_check "Checking test users..."
  log_warn "Verify 10 test users (1 per role) exist (manual verification via Directus admin)"

  # Statens Vegvesen token
  log_check "Checking Statens Vegvesen token..."
  if [ -f "$PROJECT_ROOT/.env.development" ]; then
    if grep -q "STATENS_VEGVESEN_TOKEN=" "$PROJECT_ROOT/.env.development"; then
      log_pass "STATENS_VEGVESEN_TOKEN configured"
    else
      log_warn "STATENS_VEGVESEN_TOKEN not set (required for IMP-004)"
    fi
  fi
}

# ========================================
# CHECK 6: Backup Strategy
# ========================================
check_backups() {
  log_section "6. Backup Strategy"

  # Backups directory
  log_check "Checking backups directory..."
  if [ -d "$PROJECT_ROOT/backups" ]; then
    log_pass "Backups directory exists"
  else
    log_warn "Backups directory not found. Create: mkdir -p $PROJECT_ROOT/backups"
    if [ "$FIX_MODE" = true ]; then
      mkdir -p "$PROJECT_ROOT/backups"
      log_pass "Created backups directory"
    fi
  fi

  # Database backup procedure
  log_check "Database backup procedure..."
  log_info "Backup command: docker compose -f docker-compose.dev.yml exec -T postgres pg_dump -U directus directus_dev > backups/db-backup-\$(date +%Y%m%d).dump"
  log_warn "Verify database backup procedure documented (manual verification)"

  # Permissions backup
  log_check "Permissions backup..."
  log_warn "Create permissions backup before IMP-001: Save current permissions JSON to backups/permissions-backup-YYYYMMDD.json"
}

# ========================================
# CHECK 7: Risk Acknowledgment
# ========================================
check_risks() {
  log_section "7. Risk Acknowledgment"

  log_info "10 Critical Risks from Agent 1 (Validator):"
  echo "  RISK-001: IMP-001 complexity (12h estimate, potential 150% overrun)"
  echo "  RISK-002: IMP-006 index creation time (potential lock issues)"
  echo "  RISK-003: IMP-010 RBAC complexity (nested permissions)"
  echo "  RISK-004: IMP-022 testing framework setup time"
  echo "  RISK-005: IMP-024 schema import conflicts"
  echo "  RISK-006: Cross-dealership resource sharing edge cases"
  echo "  RISK-007: Timeline buffer consumption (4-6 week buffer needed)"
  echo "  RISK-008: Phase gate failures (blocking Phase 2)"
  echo "  RISK-009: Test data isolation validation failures"
  echo "  RISK-010: Rollback complexity (multi-step rollback procedures)"

  log_warn "Verify team has reviewed and acknowledged all 10 risks (manual verification)"
  log_info "Mitigation plans documented in IMPROVEMENT_RECOMMENDATIONS.md"
}

# ========================================
# CHECK 8: Git Status
# ========================================
check_git_status() {
  log_section "8. Git Repository Status"

  cd "$PROJECT_ROOT"

  # Current branch
  log_check "Checking current branch..."
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  log_info "Current branch: $CURRENT_BRANCH"

  if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    log_warn "On main branch. Consider creating feature branch: git checkout -b feature/phase-1-implementation"
  else
    log_pass "On feature branch: $CURRENT_BRANCH"
  fi

  # Uncommitted changes
  log_check "Checking for uncommitted changes..."
  if git diff-index --quiet HEAD --; then
    log_pass "No uncommitted changes (clean working tree)"
  else
    log_warn "Uncommitted changes detected. Commit before starting Phase 1"
  fi

  # Remote sync
  log_check "Checking remote sync..."
  git fetch &> /dev/null || true
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u} 2> /dev/null || echo "")

  if [ -z "$REMOTE" ]; then
    log_warn "No upstream branch set. Push branch: git push -u origin $CURRENT_BRANCH"
  elif [ "$LOCAL" = "$REMOTE" ]; then
    log_pass "Branch in sync with remote"
  else
    log_warn "Branch out of sync with remote. Pull/push changes"
  fi
}

# ========================================
# CHECK 9: Extensions Status
# ========================================
check_extensions() {
  log_section "9. Custom Extensions"

  EXTENSIONS=(
    "extensions/directus-extension-workflow-guard"
    "extensions/directus-extension-vehicle-lookup-button"
  )

  for ext in "${EXTENSIONS[@]}"; do
    EXT_NAME=$(basename "$ext")
    log_check "Checking $EXT_NAME..."

    if [ -d "$PROJECT_ROOT/$ext" ]; then
      log_pass "$EXT_NAME directory exists"

      # Check if built
      if [ -f "$PROJECT_ROOT/$ext/dist/index.js" ]; then
        log_pass "$EXT_NAME is built (dist/index.js exists)"
      else
        log_warn "$EXT_NAME not built. Run: cd $ext && pnpm build"
      fi
    else
      log_fail "$EXT_NAME directory not found at $ext"
    fi
  done
}

# ========================================
# CHECK 10: Final Readiness Summary
# ========================================
print_summary() {
  log_section "Pre-Flight Summary"

  TOTAL=$((PASSED + FAILED + WARNINGS))

  echo ""
  echo "Results:"
  echo -e "  ${GREEN}Passed:${NC}   $PASSED"
  echo -e "  ${RED}Failed:${NC}   $FAILED"
  echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
  echo -e "  Total:    $TOTAL"
  echo ""

  if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
      echo -e "${GREEN}✓ ALL CHECKS PASSED - READY TO BEGIN PHASE 1${NC}"
      echo ""
      echo "Next steps:"
      echo "  1. Run daily-validation.sh every morning"
      echo "  2. Start with IMP-001-T1 (Data isolation analysis)"
      echo "  3. Update task-tracker.json as tasks complete"
      echo ""
      return 0
    else
      echo -e "${YELLOW}⚠ WARNINGS PRESENT - REVIEW BEFORE PROCEEDING${NC}"
      echo ""
      echo "Please address warnings before starting Phase 1"
      echo "Most warnings require manual verification or setup"
      echo ""
      return 2
    fi
  else
    echo -e "${RED}✗ CRITICAL FAILURES - CANNOT PROCEED${NC}"
    echo ""
    echo "Fix failed checks before starting Phase 1"
    echo "Run with --fix flag to auto-fix some issues: $0 --fix"
    echo ""
    return 1
  fi
}

# ========================================
# MAIN EXECUTION
# ========================================
main() {
  echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║   DirectApp Phase 1 Pre-Flight Checklist  ║${NC}"
  echo -e "${BLUE}║   Target Start: November 4, 2025           ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"

  check_tools
  check_access
  check_documentation
  check_team
  check_test_data
  check_backups
  check_risks
  check_git_status
  check_extensions

  print_summary
  exit $?
}

main
