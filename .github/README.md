# DirectApp GitHub Setup

Complete GitHub Project configuration with issue templates, automation, and workflows.

---

## 📁 Structure

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug.yml              # Bug report template
│   ├── feature.yml          # Feature request template
│   ├── infrastructure.yml   # Infrastructure task template
│   └── config.yml           # Template configuration
├── scripts/
│   ├── setup-project.sh           # Create new GitHub Project
│   └── create-initial-issues.sh   # Populate with initial issues
├── PROJECT_TEMPLATE.md      # Complete project documentation
└── README.md                # This file
```

---

## 🚀 Quick Start

### 1. Create New GitHub Project

```bash
# Make script executable
chmod +x .github/scripts/setup-project.sh

# Run setup
./.github/scripts/setup-project.sh
```

This creates a new GitHub Project with:
- Custom fields (Priority, Size, Component, Environment, etc.)
- Labels (priority, type, component, status)
- Proper configuration

### 2. Add Project README (Manual in UI)

**IMPORTANT**: Add the project README to provide context and documentation.

1. Open project: `gh project view 2 --owner gumpen-app --web`
2. Click the `...` menu (top right) → **Settings**
3. Under **README**, click **Add README**
4. Copy content from `.github/PROJECT_README.md` and paste
5. Click **Save**

This provides project overview, sprint info, workflow integration, and quick links.

### 3. Configure Project Views (Manual in UI)

After adding the README, create these views in the project:

**Board View** (Default)
- Group by: Status
- Filter: Current sprint
- Columns: Backlog → Ready → In Progress → Review → Done

**Table View** (All Issues)
- Show all columns
- Sort by: Priority, Status
- Filter: None

**Roadmap View** (Timeline)
- Group by: Epic
- Date field: Sprint
- Show next 3 sprints

**My Work** (Personal)
- Filter: Assignee = @me, Status != Done
- Group by: Status

**Blocked Items**
- Filter: Status = Blocked
- Sort by: Priority

### 4. Set Up Automation Rules (Manual in UI)

Configure these automations in Project Settings → Workflows:

```yaml
# When PR is created → Move to Review
trigger: pull_request.opened
action: set Status = 👀 Review

# When PR is merged → Move to Done
trigger: pull_request.merged
action: set Status = ✅ Done

# When issue assigned → Move to In Progress
trigger: issue.assigned
action: set Status = 🏃 In Progress

# When labeled "blocked" → Move to Blocked
trigger: issue.labeled (blocked)
action: set Status = 🚫 Blocked
```

### 5. Create Initial Infrastructure Issues

```bash
# Make script executable
chmod +x .github/scripts/create-initial-issues.sh

# Create issues
./.github/scripts/create-initial-issues.sh
```

This creates 7 foundational issues:
- Phase 1: Core Infrastructure (3 issues)
- Phase 2: Testing & CI/CD (2 issues)
- Phase 3: Schema & Data (2 issues)

---

## 📊 Project Structure

### Custom Fields

| Field | Type | Purpose |
|-------|------|---------|
| **Status** | Single Select | Workflow state (Backlog, Ready, In Progress, Review, Done, Blocked) |
| **Priority** | Single Select | 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low |
| **Size** | Single Select | XS, S, M, L, XL (effort estimate) |
| **Sprint** | Iteration | Sprint assignment |
| **Epic** | Text | High-level grouping |
| **Component** | Single Select | System component (Workflow, Deployment, Schema, API, UI, Docs, Extensions) |
| **Environment** | Single Select | Local, Staging, Production, All |
| **Sprint Points** | Number | Story points (1, 2, 3, 5, 8, 13) |
| **Actual Hours** | Number | Time tracking |

### Workflow States

```
📋 Backlog → 🔜 Ready → 🏃 In Progress → 👀 Review → ✅ Done
                           ↓
                        🚫 Blocked
```

### Labels

**Priority**: `priority: critical`, `priority: high`, `priority: medium`, `priority: low`

**Type**: `type: bug`, `type: feature`, `type: enhancement`, `type: docs`, `type: chore`

**Component**: `component: workflow`, `component: deployment`, `component: schema`, `component: api`, `component: ui`, `component: extensions`

**Status**: `blocked`, `needs-review`, `needs-testing`, `ready-to-merge`

---

## 📝 Issue Templates

### Feature Request (`feature.yml`)
For new features and enhancements
- User story format
- Acceptance criteria
- Priority and size estimation
- Component assignment

### Bug Report (`bug.yml`)
For bugs and issues
- Steps to reproduce
- Expected vs actual behavior
- Environment tracking
- Screenshots and logs

### Infrastructure Task (`infrastructure.yml`)
For deployment and configuration
- Environment specification
- Configuration details
- Verification steps
- Rollback plan

---

## 🔄 Workflow Integration

### Using with /core:work

```bash
# Start work on next task
/core:work

# This will:
# 1. Query GitHub Project for next Ready task
# 2. Create feature branch
# 3. Start session tracking
# 4. Set task to "In Progress"
```

### Using with /core:done

```bash
# Complete current task
/core:done

# This will:
# 1. Commit changes
# 2. Create pull request
# 3. Set task to "Review"
# 4. Update GitHub Project
# 5. Log analytics
```

### Using with /core:sync

```bash
# Sync with GitHub Project
/core:sync

# Options:
/core:sync pull   # Pull latest from GitHub
/core:sync push   # Push local changes
/core:sync both   # Bidirectional sync
```

---

## 📈 Sprint Management

### Sprint Duration: 2 weeks

**Sprint Planning** (Monday, Week 1)
1. Review backlog
2. Move issues to Ready
3. Assign to current sprint
4. Set sprint goals

**Daily** (Throughout sprint)
- Update issue status
- Move blocked items
- Add comments/updates

**Sprint Review** (Friday, Week 2)
- Demo completed work
- Review metrics
- Update roadmap

**Sprint Retrospective** (Friday, Week 2)
- What went well?
- What needs improvement?
- Action items

---

## 📊 Views Guide

### 1. Board View (Default)
**Use for**: Daily work, sprint execution
- Kanban board grouped by Status
- Shows current sprint only
- Drag and drop to change status

### 2. Table View (All Issues)
**Use for**: Overview, bulk editing
- All issues in table format
- All custom fields visible
- Sort and filter capabilities

### 3. Roadmap View (Timeline)
**Use for**: Long-term planning
- Visual timeline by sprint
- Grouped by Epic
- Shows next 3 sprints

### 4. Sprint Planning View
**Use for**: Sprint planning meetings
- Grouped by Component
- Shows Ready issues
- Estimation visible

### 5. My Work View
**Use for**: Personal task list
- Filtered to assigned issues
- Excludes completed
- Grouped by status

### 6. Blocked Items View
**Use for**: Unblocking work
- Shows only blocked items
- Sorted by priority
- Shows blocker details

### 7. Deployment Tracker
**Use for**: Release management
- Filtered to deployment tasks
- Grouped by environment
- Shows deployment status

---

## 🤖 Automation

### Enabled Automations

**PR Automation**:
- PR created → Status = Review
- PR merged → Status = Done
- PR closed (not merged) → Status = Ready

**Issue Automation**:
- Issue assigned → Status = In Progress
- Label "blocked" added → Status = Blocked
- Label "blocked" removed → Status = In Progress

**Priority Automation**:
- Priority set to Critical → Status = Ready (if Backlog)

---

## 📚 Documentation

**Project Template**: `PROJECT_TEMPLATE.md`
- Complete project documentation
- Field definitions
- View configurations
- Automation rules
- Sprint structure
- Best practices

---

## 🎯 Initial Issues

Run `.github/scripts/create-initial-issues.sh` to create:

**Sprint 1 - Week 1** (Core Infrastructure)
1. Workflow System Integration & Testing
2. Deployment Pipeline Validation
3. Local Development Environment Setup

**Sprint 1 - Week 2** (Testing & CI/CD)
4. Automated Testing Framework
5. GitHub Actions CI/CD Pipeline

**Sprint 2** (Schema & Data)
6. Import Pilot Production Schema & Data
7. RBAC Implementation & Multi-Dealership Testing

---

## 🔧 Maintenance

### Adding New Labels
```bash
gh label create "new-label" \
  --color "RRGGBB" \
  --description "Description"
```

### Adding Issues to Project
```bash
gh project item-add PROJECT_NUMBER \
  --owner gumpen-app \
  --url https://github.com/gumpen-app/directapp/issues/ISSUE_NUMBER
```

### Updating Field Values
Done via GitHub UI or API

---

## 📖 References

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Issue Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [Project Automation](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project)
- [Workflow Commands](../.claude/commands/README.md)

---

**Version**: 1.0
**Last Updated**: 2025-10-21
**Maintained By**: DirectApp Team
