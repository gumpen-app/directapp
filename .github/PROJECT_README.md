# DirectApp - Development & Deployment

**Agile project tracking for infrastructure, development, and deployment work**

---

## 🎯 Project Goals

Get workflow, GitHub integration, and deployment **up and running 100%**:

1. **Workflow System** - Complete integration with GitHub Projects, session tracking, analytics
2. **Deployment Pipeline** - Staging and production automation via Dokploy
3. **Testing Framework** - Automated testing and CI/CD pipeline
4. **Schema & Data** - Import from pilot, RBAC implementation

---

## 📊 Current Sprint

**Sprint 1 - Infrastructure Foundation** (2 weeks)

**Week 1 Focus:**
- Workflow System Integration & Testing (#65)
- Deployment Pipeline Validation (#66)
- Local Development Environment Setup (#67)

**Week 2 Focus:**
- Automated Testing Framework (#68)
- GitHub Actions CI/CD Pipeline (#69)

**Sprint 2:**
- Import Pilot Production Schema & Data (#70)
- RBAC Implementation & Multi-Dealership Testing (#71)

---

## 🔄 Workflow Integration

This project integrates with the workflow system:

```bash
/core:work              # Start next Ready task
/core:status           # View project dashboard
/core:done             # Complete task, create PR
/core:check            # Validate before commit
/core:sync             # Sync with GitHub Project
```

---

## 📈 Sprint Methodology

**Duration**: 2 weeks per sprint

**Sprint Planning** (Monday, Week 1)
- Review backlog
- Move issues to Ready
- Assign to current sprint
- Set sprint goals

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

## 🏗️ Architecture

**Environment Stack:**
- **Local**: Docker Compose, Directus 11.12.0, PostgreSQL, Redis
- **Staging**: Dokploy deployment, auto-deploy on merge to main
- **Production**: Dokploy deployment, manual approval

**Key Systems:**
- **Workflow**: SQLite analytics, model routing (Haiku/Sonnet), session management
- **Schema**: Multi-dealership RBAC, 9 Norwegian roles, 55 permissions
- **Deployment**: GitHub Actions CI/CD, environment-specific secrets

---

## 📋 Custom Fields Guide

| Field | Purpose | Values |
|-------|---------|--------|
| **Status** | Workflow state | Backlog → Ready → In Progress → Review → Done |
| **Priority** | Urgency | 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low |
| **Size** | Effort estimate | XS (1h), S (2-4h), M (1d), L (2-3d), XL (1w) |
| **Sprint** | Sprint assignment | Sprint 1, Sprint 2, Sprint 3... |
| **Epic** | High-level grouping | Infrastructure, Features, Testing, Docs |
| **Component** | System component | Workflow, Deployment, Schema, API, UI, Docs |
| **Environment** | Target environment | Local, Staging, Production, All |
| **Sprint Points** | Story points | 1, 2, 3, 5, 8, 13 |
| **Actual Hours** | Time tracking | Hours spent |

---

## 📚 Documentation

- **Project Template**: `.github/PROJECT_TEMPLATE.md` - Complete field/view/automation documentation
- **Setup Guide**: `.github/README.md` - How to create and configure this project
- **Issue Templates**: `.github/ISSUE_TEMPLATE/` - Feature, Bug, Infrastructure templates
- **Deployment Guide**: `DOKPLOY_DEPLOYMENT_GUIDE.md` - Deployment procedures
- **Workflow Reference**: `.claude/RUNBOOK.md` - Daily workflow commands

---

## 🚀 Quick Links

- **Repository**: [gumpen-app/directapp](https://github.com/gumpen-app/directapp)
- **Pilot Instance**: [gumpen.coms.no](https://gumpen.coms.no) (Directus 11.5.1)
- **Staging**: TBD (Dokploy)
- **Production**: TBD (Dokploy)

---

**Last Updated**: 2025-10-21
**Maintained By**: DirectApp Team
