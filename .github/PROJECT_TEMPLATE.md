# DirectApp GitHub Project Template

**Project Name**: DirectApp - Development & Deployment
**Purpose**: Track infrastructure, development, and deployment work
**Methodology**: Agile with 2-week sprints

---

## 📊 Project Structure

### Custom Fields

| Field Name | Type | Options | Purpose |
|------------|------|---------|---------|
| **Status** | Single Select | 📋 Backlog, 🔜 Ready, 🏃 In Progress, 👀 Review, ✅ Done, 🚫 Blocked | Workflow state |
| **Priority** | Single Select | 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low | Task urgency |
| **Size** | Single Select | XS (1h), S (2-4h), M (1d), L (2-3d), XL (1w) | Effort estimate |
| **Sprint** | Iteration | Sprint 1, Sprint 2, Sprint 3... | Sprint assignment |
| **Epic** | Text | Infrastructure, Features, Testing, Docs | High-level grouping |
| **Component** | Single Select | Workflow, Deployment, Schema, API, UI, Docs | System component |
| **Environment** | Single Select | Local, Staging, Production, All | Target environment |
| **Blocked By** | Text | Issue number or description | Blocker tracking |
| **Actual Hours** | Number | Hours spent | Time tracking |
| **Sprint Points** | Number | 1, 2, 3, 5, 8, 13 | Story points |

---

## 🔄 Workflow States

```
📋 Backlog → 🔜 Ready → 🏃 In Progress → 👀 Review → ✅ Done
                           ↓
                        🚫 Blocked
```

### State Definitions

**📋 Backlog**
- Issues not yet prioritized
- Needs refinement
- Low priority items

**🔜 Ready**
- Requirements clear
- Dependencies resolved
- Ready to start

**🏃 In Progress**
- Actively being worked on
- Assignee required
- Has branch/PR link

**👀 Review**
- PR created
- Awaiting code review
- CI checks running

**✅ Done**
- Merged to main
- Deployed to staging
- Verified working

**🚫 Blocked**
- Cannot proceed
- Waiting on dependency
- Has "Blocked By" filled

---

## 📱 Views Configuration

### 1. **Board View** (Default)
- **Layout**: Kanban board
- **Group by**: Status
- **Sort**: Priority (High→Low), then Created date
- **Filter**: Current sprint only
- **Columns**: Backlog, Ready, In Progress, Review, Done

### 2. **Table View** (All Issues)
- **Layout**: Table
- **Columns**: Title, Status, Priority, Size, Sprint, Assignee, Component
- **Sort**: Priority, then Status
- **Filter**: None (show all)
- **Use for**: Bulk editing, overview

### 3. **Roadmap View** (Timeline)
- **Layout**: Roadmap
- **Group by**: Epic
- **Date field**: Sprint
- **Show**: Next 3 sprints
- **Use for**: Long-term planning

### 4. **Sprint Planning View**
- **Layout**: Table
- **Group by**: Component
- **Filter**: Current sprint + Ready status
- **Columns**: Title, Size, Sprint Points, Assignee, Priority
- **Use for**: Sprint planning meetings

### 5. **My Work View**
- **Layout**: Board
- **Filter**: Assignee = @me, Status != Done
- **Group by**: Status
- **Use for**: Personal focus

### 6. **Blocked Items View**
- **Layout**: Table
- **Filter**: Status = Blocked
- **Columns**: Title, Blocked By, Priority, Assignee
- **Sort**: Priority (High→Low)
- **Use for**: Unblocking work

### 7. **Deployment Tracker**
- **Layout**: Table
- **Filter**: Component = Deployment
- **Group by**: Environment
- **Columns**: Title, Status, Environment, Priority
- **Use for**: Release management

---

## 🤖 Automation Rules

### Auto-Status Updates

```yaml
# When PR is created → Move to Review
- trigger: pull_request.opened
  action: set_field
  field: Status
  value: 👀 Review

# When PR is merged → Move to Done
- trigger: pull_request.merged
  action: set_field
  field: Status
  value: ✅ Done

# When issue is assigned → Move to In Progress
- trigger: issue.assigned
  action: set_field
  field: Status
  value: 🏃 In Progress

# When issue is labeled "blocked" → Move to Blocked
- trigger: issue.labeled
  label: blocked
  action: set_field
  field: Status
  value: 🚫 Blocked
```

### Auto-Sprint Assignment

```yaml
# New issues go to Backlog
- trigger: issue.created
  action: set_field
  field: Status
  value: 📋 Backlog

# High priority → Move to Ready
- trigger: field.changed
  field: Priority
  value: 🔴 Critical
  action: set_field
  field: Status
  value: 🔜 Ready
```

---

## 🏷️ Label System

### Priority Labels
- `priority: critical` - Production down, security issue
- `priority: high` - Blocking work, must do this sprint
- `priority: medium` - Should do, not blocking
- `priority: low` - Nice to have

### Type Labels
- `type: bug` - Something isn't working
- `type: feature` - New functionality
- `type: enhancement` - Improve existing feature
- `type: docs` - Documentation only
- `type: chore` - Maintenance work

### Component Labels
- `component: workflow` - Workflow system
- `component: deployment` - Deployment/CI/CD
- `component: schema` - Database schema
- `component: api` - API/backend
- `component: ui` - User interface
- `component: extensions` - Directus extensions

### Status Labels
- `blocked` - Cannot proceed
- `needs-review` - Awaiting code review
- `needs-testing` - Requires QA
- `ready-to-merge` - Approved, can merge

---

## 📋 Issue Templates

### 1. Feature Template
```markdown
## Description
Brief description of the feature

## User Story
As a [role], I want [feature] so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Details
Implementation approach

## Dependencies
List any blockers or dependencies

## Estimated Size
XS / S / M / L / XL
```

### 2. Bug Template
```markdown
## Bug Description
What's broken?

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Local / Staging / Production
- Browser (if applicable)
- User role (if applicable)

## Screenshots
If applicable

## Priority
Critical / High / Medium / Low
```

### 3. Infrastructure Template
```markdown
## Infrastructure Task
What needs to be set up/configured?

## Environment
Local / Staging / Production / All

## Configuration Details
Specific settings, secrets, etc.

## Verification Steps
How to verify it works

## Rollback Plan
How to undo if needed

## Documentation
Link to docs or add details
```

---

## 🎯 Sprint Structure

### Sprint Duration: 2 weeks

### Sprint Workflow

**Week 1, Day 1 (Monday): Sprint Planning**
- Review backlog
- Assign issues to sprint
- Set sprint goals
- Estimate story points

**Week 1-2: Daily Standups**
- What did I do yesterday?
- What am I doing today?
- Any blockers?

**Week 2, Day 5 (Friday): Sprint Review**
- Demo completed work
- Review metrics
- Update roadmap

**Week 2, Day 5 (Friday): Sprint Retrospective**
- What went well?
- What needs improvement?
- Action items for next sprint

---

## 📈 Metrics to Track

### Velocity Metrics
- Story points completed per sprint
- Issues closed per sprint
- Average cycle time (Ready → Done)

### Quality Metrics
- Bugs found in Review vs Production
- Deployment success rate
- Rollback frequency

### Team Metrics
- Work distribution (per component)
- Blocked time (percentage)
- Estimation accuracy

---

## 🚀 Initial Setup Checklist

- [ ] Create new GitHub Project
- [ ] Add custom fields (Priority, Size, Sprint, Epic, Component, Environment)
- [ ] Configure Status field with workflow states
- [ ] Create 7 views (Board, Table, Roadmap, Sprint Planning, My Work, Blocked, Deployment)
- [ ] Set up automation rules (PR → Review, Merged → Done, etc.)
- [ ] Create issue templates (Feature, Bug, Infrastructure)
- [ ] Add labels (priority, type, component, status)
- [ ] Migrate or close old issues
- [ ] Create first sprint (Sprint 1)
- [ ] Populate backlog with initial issues
- [ ] Assign issues to Sprint 1
- [ ] Document project setup in README

---

## 📚 References

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Project Automation](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project)
- [Custom Fields](https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields)

---

**Template Version**: 1.0
**Last Updated**: 2025-10-21
**Maintained By**: DirectApp Team
