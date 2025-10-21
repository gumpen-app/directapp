#!/bin/bash
# Create Initial Infrastructure Issues
# Populates the GitHub Project with foundational tasks

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Creating Initial Infrastructure Issues${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Phase 1: Core Infrastructure (Sprint 1 - Week 1)

echo -e "${YELLOW}Phase 1: Core Infrastructure${NC}"

# Issue 1: Workflow System Integration
echo "  Creating Issue 1: Workflow System Integration..."
gh issue create \
  --title "Phase 1.1: Workflow System Integration & Testing" \
  --body "## Description
Validate and test core workflow commands integration with GitHub

## User Story
As a developer, I want the workflow system fully operational so that I can efficiently manage tasks and track progress

## Acceptance Criteria
- [ ] /core:work command starts session and picks task from GitHub Project
- [ ] /core:done command creates commit, PR, and updates project status
- [ ] /core:status command shows accurate project state
- [ ] /core:check command validates code before commit
- [ ] /core:sync command syncs with GitHub Project bidirectionally
- [ ] Session tracking works (start/end/duration)
- [ ] Analytics database records all activity
- [ ] GitHub Project auto-updates on PR creation/merge

## Technical Details
- Test all workflow commands defined in .claude/commands/
- Verify SQLite analytics database integration
- Ensure GitHub API calls work correctly
- Validate session lifecycle management

## Dependencies
- GitHub Project must be set up first
- GitHub token configured in environment

## Estimated Size
L (2-3 days)" \
  --label "type: chore,component: workflow,priority: high" \
  --assignee "@me" 2>/dev/null || echo "Failed to create issue 1"

# Issue 2: Deployment Pipeline Validation
echo "  Creating Issue 2: Deployment Pipeline Validation..."
gh issue create \
  --title "Phase 1.2: Deployment Pipeline Validation" \
  --body "## Task Description
Validate deployment automation for staging and production environments

## Environment
All

## Configuration Details
- Staging deployment via Dokploy
- Production deployment via Dokploy
- GitHub Actions CI/CD pipeline
- Environment-specific secrets
- Database migration strategy

## Verification Steps
- [ ] Deploy to staging successfully
- [ ] Verify staging environment works
- [ ] Run smoke tests on staging
- [ ] Deploy to production (test environment)
- [ ] Verify rollback procedure works
- [ ] CI/CD pipeline runs on PR creation
- [ ] Auto-deploy to staging on merge to main

## Rollback Plan
- Document rollback procedure in DOKPLOY_DEPLOYMENT_GUIDE.md
- Test rollback on staging first

## Priority
🟠 High

## Estimated Size
L (2-3 days)" \
  --label "type: chore,component: deployment,priority: high" 2>/dev/null || echo "Failed to create issue 2"

# Issue 3: Local Development Environment
echo "  Creating Issue 3: Local Development Environment..."
gh issue create \
  --title "Phase 1.3: Local Development Environment Setup" \
  --body "## Task Description
Ensure local development environment works flawlessly with hot reload

## Environment
Local

## Configuration Details
- Docker Compose for local dev
- PostgreSQL database
- Redis cache
- Directus 11.12.0
- Extensions hot reload
- Environment variables

## Verification Steps
- [ ] \`docker compose -f docker-compose.dev.yml up\` works
- [ ] Access Directus at http://localhost:8055
- [ ] Admin login works (admin@example.com / admin)
- [ ] Extensions hot reload when modified
- [ ] Database migrations apply correctly
- [ ] Redis cache functional
- [ ] MCP server connects to local instance

## Rollback Plan
N/A (local only)

## Priority
🟠 High

## Estimated Size
S (2-4 hours)" \
  --label "type: chore,component: deployment,priority: high" 2>/dev/null || echo "Failed to create issue 3"

echo ""
echo -e "${YELLOW}Phase 2: Testing & CI/CD (Sprint 1 - Week 2)${NC}"

# Issue 4: Automated Testing Setup
echo "  Creating Issue 4: Automated Testing Setup..."
gh issue create \
  --title "Phase 2.1: Automated Testing Framework" \
  --body "## Description
Set up automated testing for extensions and critical workflows

## User Story
As a developer, I want automated tests so that I can catch bugs before deployment

## Acceptance Criteria
- [ ] Unit test framework configured (Jest/Vitest)
- [ ] Integration tests for API endpoints
- [ ] E2E tests for critical user flows
- [ ] Test coverage reporting
- [ ] Tests run in CI/CD pipeline
- [ ] Pre-commit hooks run tests

## Technical Details
- Choose test framework (Jest vs Vitest)
- Set up test database
- Mock Directus SDK where needed
- Configure coverage thresholds

## Dependencies
- Local dev environment working
- CI/CD pipeline set up

## Estimated Size
L (2-3 days)" \
  --label "type: feature,component: workflow,priority: medium" 2>/dev/null || echo "Failed to create issue 4"

# Issue 5: CI/CD Pipeline Enhancement
echo "  Creating Issue 5: CI/CD Pipeline Enhancement..."
gh issue create \
  --title "Phase 2.2: GitHub Actions CI/CD Pipeline" \
  --body "## Task Description
Complete CI/CD pipeline with automated testing and deployment

## Environment
All

## Configuration Details
- GitHub Actions workflows
- Automated tests on PR
- Build verification
- Auto-deploy to staging on merge
- Manual approval for production
- Rollback automation

## Verification Steps
- [ ] PR triggers CI checks
- [ ] Tests run automatically
- [ ] Build succeeds/fails correctly
- [ ] Staging auto-deploys on merge
- [ ] Production requires approval
- [ ] Failed deployments trigger alerts

## Priority
🟡 Medium

## Estimated Size
M (1 day)" \
  --label "type: chore,component: deployment,priority: medium" 2>/dev/null || echo "Failed to create issue 5"

echo ""
echo -e "${YELLOW}Phase 3: Schema & Data (Sprint 2)${NC}"

# Issue 6: Import Pilot Schema
echo "  Creating Issue 6: Import Pilot Production Schema..."
gh issue create \
  --title "Phase 3.1: Import Pilot Production Schema & Data" \
  --body "## Description
Import schema and data from pilot production instance (https://gumpen.coms.no)

## User Story
As a developer, I want the production schema imported so that local development matches production

## Acceptance Criteria
- [ ] Pilot schema exported successfully
- [ ] Schema applied to local environment
- [ ] Schema applied to staging environment
- [ ] Sample data imported for testing
- [ ] Relationships preserved
- [ ] Norwegian translations intact
- [ ] No data loss or corruption

## Technical Details
- Use scripts/sync-schema.sh
- Export from https://gumpen.coms.no (Directus 11.5.1)
- Import to local (Directus 11.12.0)
- Handle version differences
- Validate all 3 collections (cars, cars_files, dealership)

## Dependencies
- MCP connection to pilot configured
- Local environment working
- Staging environment ready

## Estimated Size
M (1 day)" \
  --label "type: feature,component: schema,priority: medium" 2>/dev/null || echo "Failed to create issue 6"

# Issue 7: RBAC Implementation Validation
echo "  Creating Issue 7: RBAC Implementation Validation..."
gh issue create \
  --title "Phase 3.2: RBAC Implementation & Multi-Dealership Testing" \
  --body "## Description
Validate Role-Based Access Control with Norwegian roles and multi-dealership isolation

## User Story
As a dealership manager, I want proper access control so that users only see their dealership's data

## Acceptance Criteria
- [ ] 9 Norwegian roles configured (Nybilselger, Bruktbilselger, etc.)
- [ ] 55 permissions imported correctly
- [ ] Multi-dealership data isolation works
- [ ] Test users can log in
- [ ] Permissions enforced correctly
- [ ] Cross-dealership visibility controlled (bruktbilselger can see all)
- [ ] Admin users have full access

## Technical Details
- Import schema/policies/complete-role-policies.json
- Test each role's permissions
- Verify dealership_id filtering
- Test policy rules (create/read/update/delete)

## Dependencies
- Schema imported from pilot
- Test users created

## Estimated Size
M (1 day)" \
  --label "type: feature,component: api,priority: medium" 2>/dev/null || echo "Failed to create issue 7"

echo ""
echo -e "${GREEN}✅ Initial issues created!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Open GitHub Project to view issues"
echo "2. Assign issues to Sprint 1"
echo "3. Start working with: /core:work"
echo ""
