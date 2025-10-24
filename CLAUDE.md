# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**DirectApp** is a Directus 11 fork customized for Norwegian car dealerships to manage vehicle preparation workflows from arrival to customer delivery. Built as a **monorepo** with pnpm workspaces, featuring multi-dealership support with data isolation, role-based workflows (sales, reception, mechanics, workshop planners), and comprehensive vehicle tracking.

**Tech Stack:**
- Directus 11 (headless CMS) - monorepo with ~30 packages
- PostgreSQL 15 + PostGIS - database with spatial extensions
- Redis 7 - cache layer
- Vue 3 - admin UI framework
- Docker + Dokploy - deployment platform
- Node 22 + pnpm 10 - runtime and package manager

**Key Characteristics:**
- Fork of Directus with custom extensions for car dealerships
- Multi-tenant architecture (dealership data isolation)
- Norwegian-first localization
- 8-phase roadmap from foundation to production

---

## Essential Commands

### Development Workflow

```bash
# Local development (Docker Compose)
pnpm dev                          # Start development environment
pnpm dev:down                     # Stop services
pnpm dev:logs                     # View Directus logs
pnpm dev:build                    # Rebuild and start

# Extension development (hot reload enabled)
pnpm extensions:dev               # Watch mode for extensions
pnpm extensions:build             # Build extensions for deployment
pnpm extensions:lint              # Lint extensions
pnpm extensions:type-check        # TypeScript type checking

# Testing
pnpm test                         # Run tests (excludes blackbox)
pnpm test:blackbox                # Integration tests
pnpm test:coverage                # Tests with coverage

# Code quality
pnpm lint                         # ESLint check
pnpm lint:style                   # Stylelint check
pnpm format                       # Prettier check
pnpm build                        # Build all packages
```

### Deployment

```bash
# Deploy to environments
pnpm deploy:staging               # Deploy to staging (auto via CI/CD)
pnpm deploy:production            # Deploy to production (manual)

# Schema management
pnpm sync-schema                  # Sync database schema between environments

# Database operations
pnpm db:backup                    # Backup local database
pnpm db:restore                   # Restore from backup
pnpm seed:staging                 # Seed staging with sample data
```

### Workflow Commands (via .claude/)

```bash
# Core workflow (use these daily)
/work                             # Start task (session + branch)
/done                             # Finish task (commit + PR)
/status                           # Project status dashboard
/sync                             # Sync with GitHub Project
/check                            # Fast validation (types + tests + lint)

# Quality
/test [pattern]                   # Run tests
/fix                              # Auto-fix issues (format, lint)

# Advanced
/analytics                        # Deep analytics
/debug                            # Diagnose errors
/rollback                         # Undo last operation

# Deployment
/deploy [staging|production]      # Deploy to environment
/sync-schema [source] [target]    # Sync database schema
```

---

## Architecture

### Monorepo Structure

**DirectApp is a Directus monorepo with added custom extensions.**

Key directories:
- `api/` - Directus backend API (Node.js/TypeScript)
- `app/` - Directus admin UI (Vue 3)
- `packages/` - ~30 internal packages (schema, utils, storage drivers, etc.)
- `sdk/` - Directus SDK for client applications
- `extensions/` - **Custom extensions for car dealership workflows**
- `directus/` - Directus deployment package
- `docs/` - Project documentation
- `.claude/` - Workflow system (commands, templates, analytics)

### Extensions Architecture

**Custom extensions** in `extensions/`:

**Endpoints (API):**
- `directus-extension-vehicle-lookup` - Statens Vegvesen API integration
- `directus-extension-workflow-guard` - Workflow state validation

**Operations (Flows):**
- `directus-extension-send-email` - Resend email notifications

**Interfaces (UI Components):**
- `directus-extension-vehicle-lookup-button` - VIN lookup button
- `directus-extension-key-tag-scanner` - Key tag scanning
- `directus-extension-parse-order-pdf` - PDF order parsing
- `directus-extension-ask-cars-ai` - AI assistant integration

**Panels (Dashboard Widgets):**
- `directus-extension-vehicle-stats` - Vehicle statistics
- `directus-extension-vehicle-search` - Cross-dealership search
- `directus-extension-workshop-calendar` - Calendar view

**Other:**
- `directus-extension-branding-inject` - Custom branding

**Extension development:**
- Extensions use Directus Extensions SDK (`@directus/extensions-sdk`)
- Hot reload enabled in development
- Each extension is TypeScript-based with own `package.json`
- Built to `dist/` directory for deployment

### Data Model (Key Collections)

**Core business entities:**
- `cars` - Main vehicle/order tracking (VIN, status, workflow)
- `dealership` - Multi-tenant dealership management
- `cars_files` - Document/photo attachments (one-to-many)
- `directus_users` - Extended with dealership roles

**Workflow states (Norwegian):**
1. `ubehandlet` (Untreated) - Just arrived
2. `klar_for_planlegging` (Ready for planning) - Passed inspection
3. `planlagt` (Planned) - Workshop scheduled
4. `behandles` (Being processed) - In progress
5. `ferdig` (Finished) - Ready for customer

**Role-based access:**
- `Nybilselger` (New car sales)
- `Bruktbilselger` (Used car sales)
- `Mottakskontroll` (Reception check)
- `Klargjoring` (Mechanics)
- `Booking` (Workshop planners)

See `GUMPEN_SYSTEM_DESIGN.md` for complete data model and workflow details.

### Multi-Tenancy Pattern

**Dealership isolation** is critical:
- Every record must be scoped to `dealership_id`
- Permissions enforce dealership boundaries
- Cross-dealership search allowed only for specific roles (used car sales)
- Prep centers (e.g., dealership 499) serve multiple dealerships

**Security note:** Phase 0 roadmap includes fixing 15 critical multi-tenancy issues. Data isolation is NOT yet production-ready.

---

## Development Patterns

### Extension Development Flow

1. **Create extension** (if new):
   ```bash
   cd extensions
   npx @directus/create-extension
   ```

2. **Develop with hot reload**:
   ```bash
   pnpm extensions:dev
   # Edit code in extensions/your-extension/src/
   # Changes auto-rebuild
   # Refresh browser to see updates
   ```

3. **Type checking**:
   ```bash
   pnpm extensions:type-check
   ```

4. **Build for deployment**:
   ```bash
   pnpm extensions:build
   # Creates dist/ files
   ```

### Schema Changes

**IMPORTANT:** Schema changes require careful coordination across environments.

1. **Make changes in local Directus admin UI** (http://localhost:8055/admin)
2. **Export schema**:
   ```bash
   pnpm sync-schema export local
   ```
3. **Test in staging**:
   ```bash
   pnpm sync-schema local staging
   ```
4. **Verify and sync to production**:
   ```bash
   pnpm sync-schema staging production
   ```

**Schema snapshots stored in:** `schema/snapshots/`

### Deployment Pipeline

**Automated flow:**
```
Git Push → CI/CD → Lint → Build → Tests → Security Scan → Staging (auto) → Production (manual)
```

**GitHub Actions workflow:**
1. Pre-commit hooks run locally (secret detection, lint, type check)
2. Push triggers CI/CD pipeline
3. Extensions built and uploaded as artifacts
4. Staging deployment automatic on main branch
5. Production deployment requires manual trigger

**Dokploy integration:**
- Staging: `staging-gapp.coms.no`
- Production: `gapp.coms.no`
- Docker Compose configs: `docker-compose.{staging,production}.yml`
- Environment variables managed in Dokploy UI

### Testing Strategy

**Local testing:**
```bash
pnpm dev                          # Start dev environment
open http://localhost:8055/admin  # Access Directus
docker logs directapp-dev         # Check logs
```

**Extension testing:**
- Manual testing in local Directus UI
- Integration tests run in CI/CD with ephemeral Directus instance

**No unit tests currently** - relying on Directus core tests and manual integration testing.

---

## Important Context

### Norwegian Localization

- UI strings in Norwegian (Bokmål)
- Norwegian-specific workflows (Statens Vegvesen integration)
- Date/number formats follow Norwegian conventions
- Status labels in Norwegian (see workflow states above)

### Current Development Phase

**⚠️ NOT PRODUCTION READY**

**Active Phase:** Phase 0 - Critical Foundation
- Fixing 15 security and data integrity issues
- Adding unique constraints (VIN, order_number)
- Implementing proper dealership isolation
- Removing dangerous DELETE permissions
- Adding audit logging

**Timeline:** Estimated 2-3 weeks to production-ready state

See `.claude/PRODUCTION_ROADMAP.md` for 8-phase roadmap and `.claude/SCHEMA_ANALYSIS.md` for critical issues.

### Workflow System (.claude/)

This repo uses a complete workflow management system:

**Commands:** 12 organized commands in `.claude/commands/`
- Core: `/work`, `/done`, `/status`, `/sync`, `/check`
- Quality: `/test`, `/fix`
- Advanced: `/analytics`, `/debug`, `/rollback`
- Utils: `/experiment`, `/archive`

**Documentation:** `.claude/docs/` contains project-specific guides
**GitHub Integration:** Two-way sync with GitHub Projects
**Analytics:** Session tracking and task metrics

### Deployment Environments

| Environment | URL | Database | Auto-Deploy |
|------------|-----|----------|-------------|
| **Local** | localhost:8055 | `directapp_dev` | N/A |
| **Staging** | staging-gapp.coms.no | `directapp_staging` | Yes (on push) |
| **Production** | gapp.coms.no | `directapp_production` | Manual only |

**Database ports:**
- Local PostgreSQL: `localhost:5432` (Docker)
- Local Redis: `localhost:6379` (Docker)

### Key Documentation Files

**Essential reading:**
- `README.md` - Project overview and quick start
- `GUMPEN_SYSTEM_DESIGN.md` - Complete system architecture and data model
- `docs/DEVELOPMENT_WORKFLOW.md` - Complete dev workflow guide
- `docs/DOKPLOY_INTEGRATION_SUMMARY.md` - Deployment guide
- `.claude/PRODUCTION_ROADMAP.md` - 8-phase development plan
- `.claude/SCHEMA_ANALYSIS.md` - Database issues and fixes
- `.claude/commands/README.md` - Workflow command reference

**Schema/permissions:**
- `schema/snapshots/` - Schema snapshots for each environment
- Schema changes managed via Directus admin UI + export/sync

---

## Common Tasks

### Add a new extension

```bash
cd extensions
npx @directus/create-extension
# Follow prompts, choose extension type
pnpm install
pnpm extensions:dev
```

### Update Directus core

```bash
# Update dependencies
pnpm update @directus/api @directus/app
pnpm install
pnpm build
pnpm dev
```

### Fix extension not loading

```bash
# 1. Check extension built
ls extensions/your-extension/dist

# 2. Rebuild extension
cd extensions/your-extension
pnpm build

# 3. Restart Directus
docker restart directapp-dev

# 4. Check logs
docker logs directapp-dev | grep -i extension
```

### Add new dealership role

1. Create role in Directus admin UI
2. Configure field-level permissions
3. Test with test user
4. Export schema: `pnpm sync-schema export local`
5. Document in `GUMPEN_SYSTEM_DESIGN.md`

### Debug workflow state transitions

1. Check `directus-extension-workflow-guard` logic
2. Review state machine in `GUMPEN_SYSTEM_DESIGN.md` (status flow section)
3. Check role permissions for status field
4. Test with different user roles

---

## Directus-Specific Patterns

### Collections and Fields

- Use Directus admin UI for schema changes (not migrations)
- Field naming: snake_case (database convention)
- Relationships: Use Directus built-in relationship types
- System fields: `id`, `date_created`, `date_updated`, `user_created`, `user_updated`

### Permissions

- Permissions are role-based at collection and field level
- Custom validation via `directus-extension-workflow-guard`
- Multi-tenancy enforced via permission filters (`dealership_id`)
- CRUD permissions configured per role in Directus admin

### Hooks and Flows

- Use Directus Flows for workflow automation
- Custom operations built as extensions (see `operations/`)
- Event-based triggers (item.create, item.update, etc.)
- Email notifications via `directus-extension-send-email`

### Extensions SDK

Extensions use `@directus/extensions-sdk` build system:
- TypeScript compilation
- Vue component bundling (for interface/panel extensions)
- Rollup-based bundling
- Hot reload in development

---

## Security Considerations

**⚠️ Pre-production security fixes required (Phase 0):**

1. Add unique constraints on VIN and order_number
2. Fix foreign key cascade deletes
3. Implement proper dealership data isolation
4. Remove DELETE permissions for non-admin roles
5. Add VIN/license plate validation
6. Fix user password update permissions
7. Implement audit logging

**Current state:** Development only, NOT production-ready

**Environment secrets:**
- Never commit `.env` files
- Store secrets in Dokploy environment variables
- Use strong passwords (20+ characters)
- Rotate `DIRECTUS_KEY` and `DIRECTUS_SECRET` quarterly

---

## Troubleshooting

### Directus won't start

```bash
# Check all services running
docker ps | grep directapp

# Check logs for errors
docker logs directapp-dev

# Verify database connection
docker exec -it directapp-dev-postgres psql -U directus -d directapp_dev
```

### Extensions not appearing

```bash
# Rebuild extensions
pnpm extensions:build

# Restart Directus
docker restart directapp-dev

# Check extension directories
ls -la extensions/*/dist

# Check Directus logs
docker logs directapp-dev | grep -i extension
```

### Schema sync fails

```bash
# Verify admin token
curl -H "Authorization: Bearer YOUR_TOKEN" https://staging-gapp.coms.no/server/health

# Check schema JSON valid
jq empty schema/snapshots/local.json

# Review differences first
pnpm sync-schema diff local staging
```

### Port conflicts

```bash
# Check what's using port 8055
lsof -i :8055

# Kill process or change port in docker-compose.dev.yml
```

---

## Package Manager

**Use pnpm exclusively** - this is a pnpm workspace monorepo.

```bash
# Install dependencies
pnpm install

# Add dependency to root
pnpm add -w <package>

# Add dependency to specific package
pnpm add <package> --filter @directus/api

# Run command in all packages
pnpm -r <command>

# Run command in specific package
pnpm --filter @directus/app <command>
```

**Never use npm or yarn** - will break workspace setup.

---

## Additional Resources

- **Directus Docs:** https://docs.directus.io
- **Directus Extensions Guide:** https://docs.directus.io/extensions/
- **Dokploy Docs:** https://docs.dokploy.com
- **GitHub Project:** https://github.com/orgs/gumpen-app/projects/1
- **Issues:** https://github.com/gumpen-app/directapp/issues
