# Session Architecture Context

**Created**: 2025-11-09 (Session Start)
**Project**: DirectApp - Car Dealership Management System
**Repository**: https://github.com/gumpen-app/directapp
**GitHub Project**: [DirectApp - Development & Deployment](https://github.com/orgs/gumpen-app/projects/2)

---

## System Goal

Transform the current Directus instance into a **production-grade car dealership management platform** for the Norwegian market with:

- Secure, role-based workflow (9 Norwegian roles, 55 permissions)
- Multi-dealership support with data isolation
- Norwegian vehicle registry integration (VIN/license plate auto-population)
- Smart notifications (Resend email + in-app)
- Scheduling system (technical/cosmetic booking)
- MCP integration for AI assistant access
- Production deployment via Dokploy (staging + production)

**Philosophy**: Simplest solution that works, security first, iterate fast.

---

## Architecture

### Technology Stack

**Backend:**
- Directus 11.12.0 (local dev) / 11.5.1 (pilot production)
- PostgreSQL database
- Redis cache
- Node.js 18+ with TypeScript 5.3.3

**Development Environment:**
- Docker Compose for local development
- pnpm workspace (monorepo structure)
- Hot reload enabled for extensions
- MCP server integration

**Deployment:**
- **Staging**: Dokploy auto-deploy on merge to main
- **Production**: Dokploy manual approval deployment
- **CI/CD**: GitHub Actions (automated testing + build validation)

**Workflow System:**
- SQLite analytics database (112KB, 7 tables)
- Model routing (Haiku/Sonnet, 60-70% cost savings)
- Session tracking with duration monitoring
- GitHub Projects integration for task management

### Extension Types in Use

Currently implemented:
- 2 interfaces (UI components)
- 2 hooks (backend automation)
- 3 endpoints (custom API routes)

Target: Templates for all 9 Directus extension types

---

## Critical Requirements

### MUST DO:

1. **Database Integrity**
   - Add unique constraints (VIN, order_number, dealership_code)
   - Fix foreign key cascades (prevent orphaned data)
   - Add VIN validation (ISO 3779: `^[A-HJ-NPR-Z0-9]{17}$`)
   - Add Norwegian license plate validation (`AA 12345` or `AA 12345 EL`)

2. **Security Lockdown**
   - Remove dangerous DELETE permission from Booking role
   - Implement soft delete (status="archived")
   - Implement dealership data isolation (dealership_id filtering)
   - Remove password/email update from non-admins
   - Add audit logging for critical operations

3. **RBAC Implementation**
   - 9 Norwegian roles (Nybilselger, Bruktbilselger, Mottaksansvarlig, etc.)
   - 55 permissions with multi-dealership isolation
   - Cross-dealership visibility controlled (bruktbilselger can see all)
   - Admin users have full access

### MUST NOT DO:

1. **Never use .disabled anti-pattern** - Remove disabled extensions entirely
2. **Never skip validation** - All inputs must be validated
3. **Never allow cross-dealership data leaks** - Strict isolation enforced
4. **Never deploy without testing** - CI/CD pipeline must pass
5. **Never commit secrets** - Use environment variables

---

## Current State

### Progress

**Completed:**
- ✅ Workflow system fully operational (17 commands)
- ✅ SQLite analytics database initialized
- ✅ Model routing with cost optimization
- ✅ GitHub Project set up with 7 issues
- ✅ Local development environment working
- ✅ Docker Compose configuration complete
- ✅ Production roadmap defined

**In Progress:**
- 🔄 Deployment pipeline validation (Issue #66)
- 🔄 Schema import from pilot production (Issue #70)

**GitHub Project Status:**
- **Total Issues**: 7
- **Done**: 2 (Phase 1.1, Phase 1.3)
- **In Progress**: 2 (Phase 1.2 deployment, linked to PR #73)
- **Ready**: 3 (Testing, CI/CD, RBAC)

### Next Steps

**Completed:**
1. ✅ **Autobase cluster connectivity verified** - Direct connection to 10.0.1.6:6432 working
2. ✅ **Databases created on Autobase** - directapp_dev, directapp_staging, directapp_production
3. ✅ **SSL configuration resolved** - DirectApp accepts self-signed certificates from Autobase
4. ✅ **Docker Compose migration complete** - All environments configured for Autobase

**Immediate Priority:**
1. Complete deployment pipeline validation (#66)
2. Set up automated testing framework (#68)
3. Import pilot production schema (#70)
4. Implement RBAC with Norwegian roles (#71)

**Current Sprint: Sprint 1 - Infrastructure Foundation** (2 weeks)
- Focus: Database Migration, Workflow, Deployment, Testing, Schema Import

---

## Decisions Made

### Key Architectural Decisions

1. **Autobase PostgreSQL Cluster** - Centralized database (10.0.1.6:6432, primary/replica)
2. **SSL enabled with self-signed certificates** - Secure connections, client accepts self-signed certs
3. **Directus 11.12.0 for local dev** - Latest stable with hot reload
4. **pnpm workspace** - Monorepo structure for extensions
5. **SQLite analytics** - 10x faster than JSON, ACID transactions
6. **Model routing** - Haiku for simple commands, Sonnet for complex tasks
7. **Dokploy deployment** - Simplified production deployment vs manual Docker
8. **GitHub Projects integration** - Two-way sync for task management
9. **MCP server** - AI assistant access to Directus data

### Implementation Patterns

1. **Extension development**: Template-based approach (9 extension types)
2. **Validation**: Multi-layer (database constraints + hooks + UI)
3. **Testing**: Automated CI/CD pipeline before merge
4. **Deployment**: Staging → Test → Production with rollback capability

---

## Anti-Patterns to Avoid

### Discovered Anti-Patterns

1. **.disabled suffix** - 2 disabled extensions found, should be removed entirely
2. **Manual JSON state** - Use SQLite analytics instead (10x faster)
3. **Hardcoded credentials** - Always use environment variables
4. **Missing validation** - Add constraints at database + application layer
5. **Cross-dealership data leaks** - Strict dealership_id filtering required

### Quality Guardrails

- Pre-flight check script (`extensions/preflight-check.sh`)
- Master validation script (100% pass rate required)
- Guard rail scripts for critical operations
- Session duration monitoring (90-min warning, 2.5-hour critical)

---

## Documentation References

**Master Plans:**
- `EXTENSIONS_MASTER_PLAN.md` - Complete extension development guide
- `.claude/PRODUCTION_ROADMAP.md` - Phase-by-phase implementation plan
- `PLAN_SYNTHESIZER_COMPLETE.md` - Consolidated planning approach

**Workflow Guides:**
- `.claude/RUNBOOK.md` - Daily workflow commands
- `.claude/commands/README.md` - Command reference
- `.claude/STATUS.md` - System capabilities and benchmarks

**GitHub:**
- `.github/PROJECT_TEMPLATE.md` - GitHub Project field documentation
- `.github/README.md` - Project setup guide
- `.github/ISSUE_TEMPLATE/` - Feature, Bug, Infrastructure templates

---

## Session Monitoring

**Session Start Time**: 2025-11-09
**Prompt Count**: 0 (initial session)
**Compaction Events**: 0

**Quality Thresholds:**
- ⚠️ 90-minute warning (approaching context compaction)
- 🚨 2.5-hour critical alert (quality degradation likely)

**Recommendation**: Use `/session-end` before 90 minutes for optimal quality

---

**Last Updated**: 2025-11-09 (Migrated to Autobase cluster)
**Maintained By**: DirectApp Team
**GitHub Project**: [View Project](https://github.com/orgs/gumpen-app/projects/2)

## Recent Changes

**2025-11-09: Autobase PostgreSQL Cluster Migration - COMPLETED ✅**
- Autobase is a Dokploy service on Hetzner VPS (157.180.125.91)
- Service name: `autobase` with internal IPs 10.0.1.6 (primary), 10.0.1.7 (replica)
- Removed local PostgreSQL containers from all docker-compose files
- Configured staging/production to use dokploy-network (10.0.1.6:6432)
- Configured local dev for direct connection to 10.0.1.6:6432
- Created three databases: directapp_dev, directapp_staging, directapp_production
- Resolved SSL certificate validation (configured to accept self-signed certs)
- DirectApp running successfully at http://localhost:8055
- Created DOKPLOY_DEPLOYMENT_GUIDE.md (complete deployment workflow)
- Created AUTOBASE_CLUSTER_SETUP.md and AUTOBASE_CONNECTION_CHECKLIST.md
- **Status**: Database infrastructure complete, ready for schema import and testing
