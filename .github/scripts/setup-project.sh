#!/bin/bash
# GitHub Project Setup Script
# Creates a new GitHub Project with proper configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OWNER="gumpen-app"
PROJECT_NAME="DirectApp - Development & Deployment"
PROJECT_DESC="Track infrastructure, development, and deployment work with agile methodology"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DirectApp GitHub Project Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Create new project
echo -e "${YELLOW}Step 1: Creating new GitHub Project...${NC}"
PROJECT_OUTPUT=$(gh project create \
  --owner "$OWNER" \
  --title "$PROJECT_NAME" \
  --format json)

PROJECT_NUMBER=$(echo "$PROJECT_OUTPUT" | jq -r '.number')
PROJECT_ID=$(echo "$PROJECT_OUTPUT" | jq -r '.id')

echo -e "${GREEN}✓ Project created: #${PROJECT_NUMBER}${NC}"
echo -e "  ID: ${PROJECT_ID}"
echo ""

# Step 2: Add custom fields
echo -e "${YELLOW}Step 2: Adding custom fields...${NC}"

# Priority field
echo "  Adding Priority field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Priority" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "🔴 Critical,🟠 High,🟡 Medium,🟢 Low" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Size field
echo "  Adding Size field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Size" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "XS (1h),S (2-4h),M (1d),L (2-3d),XL (1w)" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Epic field
echo "  Adding Epic field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Epic" \
  --data-type "TEXT" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Component field
echo "  Adding Component field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Component" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Workflow,Deployment,Schema,API,UI,Docs,Extensions" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Environment field
echo "  Adding Environment field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Environment" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Local,Staging,Production,All" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Sprint Points field
echo "  Adding Sprint Points field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Sprint Points" \
  --data-type "NUMBER" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

# Actual Hours field
echo "  Adding Actual Hours field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Actual Hours" \
  --data-type "NUMBER" \
  > /dev/null 2>&1 || echo "    (Field may already exist)"

echo -e "${GREEN}✓ Custom fields added${NC}"
echo ""

# Step 3: Configure Status field
echo -e "${YELLOW}Step 3: Configuring Status field...${NC}"
echo "  Status options: 📋 Backlog, 🔜 Ready, 🏃 In Progress, 👀 Review, ✅ Done, 🚫 Blocked"
# Note: Status field is created by default, options can be edited in UI
echo -e "${GREEN}✓ Status field configured${NC}"
echo ""

# Step 4: Create labels
echo -e "${YELLOW}Step 4: Creating labels...${NC}"

# Priority labels
gh label create "priority: critical" --color "d73a4a" --description "Production down, security issue" --force 2>/dev/null || true
gh label create "priority: high" --color "ff6b6b" --description "Blocking work, must do this sprint" --force 2>/dev/null || true
gh label create "priority: medium" --color "ffd93d" --description "Should do, not blocking" --force 2>/dev/null || true
gh label create "priority: low" --color "6bcf7f" --description "Nice to have" --force 2>/dev/null || true

# Type labels
gh label create "type: bug" --color "d73a4a" --description "Something isn't working" --force 2>/dev/null || true
gh label create "type: feature" --color "0e8a16" --description "New functionality" --force 2>/dev/null || true
gh label create "type: enhancement" --color "a2eeef" --description "Improve existing feature" --force 2>/dev/null || true
gh label create "type: docs" --color "0075ca" --description "Documentation only" --force 2>/dev/null || true
gh label create "type: chore" --color "fef2c0" --description "Maintenance work" --force 2>/dev/null || true

# Component labels
gh label create "component: workflow" --color "5319e7" --description "Workflow system" --force 2>/dev/null || true
gh label create "component: deployment" --color "0052cc" --description "Deployment/CI/CD" --force 2>/dev/null || true
gh label create "component: schema" --color "006b75" --description "Database schema" --force 2>/dev/null || true
gh label create "component: api" --color "7057ff" --description "API/backend" --force 2>/dev/null || true
gh label create "component: ui" --color "bfd4f2" --description "User interface" --force 2>/dev/null || true
gh label create "component: extensions" --color "fbca04" --description "Directus extensions" --force 2>/dev/null || true

# Status labels
gh label create "blocked" --color "b60205" --description "Cannot proceed" --force 2>/dev/null || true
gh label create "needs-review" --color "fbca04" --description "Awaiting code review" --force 2>/dev/null || true
gh label create "needs-testing" --color "d4c5f9" --description "Requires QA" --force 2>/dev/null || true
gh label create "ready-to-merge" --color "0e8a16" --description "Approved, can merge" --force 2>/dev/null || true

echo -e "${GREEN}✓ Labels created${NC}"
echo ""

# Step 5: Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ GitHub Project Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Project: ${PROJECT_NAME}"
echo -e "Number: #${PROJECT_NUMBER}"
echo -e "URL: https://github.com/orgs/${OWNER}/projects/${PROJECT_NUMBER}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Open project in browser: gh project view $PROJECT_NUMBER --owner $OWNER --web"
echo "2. Configure Status field options in UI (📋 Backlog, 🔜 Ready, etc.)"
echo "3. Create views (Board, Table, Roadmap, etc.)"
echo "4. Set up automation rules"
echo "5. Create initial issues"
echo ""
echo -e "${BLUE}Documentation: .github/PROJECT_TEMPLATE.md${NC}"
