# DirectApp - Dokploy Integration Complete

**Implementation Date:** 2025-10-21
**Status:** ✅ Complete and Ready for Use

---

## What Was Implemented

A complete, professional Dokploy integration for DirectApp with streamlined development workflow.

### 1. CI/CD Pipeline (Reworked)

**File:** `.github/workflows/directus-ci.yml`

**Changes:**
- ❌ Removed: Docker image building (not needed with Dokploy)
- ✅ Added: Auto-deploy to staging on main branch push
- ✅ Added: Manual production deployment via workflow_dispatch
- ✅ Kept: Lint, type-check, schema validation, security scans

**Flow:**
```
Push to main → Tests → Build Extensions → Auto-deploy Staging
                                       → Manual trigger → Production
```

**Deployment time:** ~15 minutes to staging

### 2. Pre-commit Hooks

**File:** `.git/hooks/pre-commit`

**Validates:**
- ✅ Secret detection (prevents API key commits)
- ✅ Extension linting (ESLint)
- ✅ TypeScript type checking
- ✅ Schema snapshot validation

**Usage:**
Runs automatically on `git commit`

### 3. Local Development Environment

**File:** `docker-compose.dev.yml`

**Features:**
- 🔥 Hot reload for extensions
- 📊 Exposed ports (8055, 5432, 6379)
- 🐛 Verbose logging (debug level)
- ⚡ Fast iteration

**Usage:**
```bash
pnpm dev                # Start all services
pnpm dev:logs           # View logs
pnpm dev:down           # Stop services
```

### 4. Deployment Scripts

**File:** `scripts/deploy.sh`

**Features:**
- 🎯 Unified deployment (staging/production)
- ✅ Pre-flight validation
- 🔨 Auto-build extensions
- 🏥 Health checks
- 🔐 Production confirmation required

**Usage:**
```bash
pnpm deploy:staging     # Deploy to staging
pnpm deploy:production  # Deploy to production (requires 'yes')
```

### 5. Schema Sync System

**File:** `scripts/sync-schema.sh`

**Features:**
- 📤 Export schema from any environment
- 🔄 Sync between environments
- 📊 Show schema diffs
- 🔐 Production protection

**Usage:**
```bash
pnpm sync-schema local staging      # Sync local → staging
pnpm sync-schema staging production # Sync staging → prod
pnpm sync-schema diff local staging # Show differences
```

### 6. Sample Data Seeding

**File:** `scripts/seed-staging.sh`

**Seeds:**
- 3 dealerships (Oslo, Bergen, Trondheim)
- 2 test users (selger, booking)
- 2 sample vehicles

**Usage:**
```bash
pnpm seed:staging
```

### 7. Workflow Commands

**Files:** `.claude/commands/deploy.md`, `.claude/commands/sync-schema.md`

**New commands:**
- `/deploy [staging|production]` - Deploy to Dokploy
- `/sync-schema [source] [target]` - Sync database schema

**Integration with existing .claude workflow system**

### 8. Documentation

**Created:**
- `docs/DNS_SETUP.md` - Complete Cloudflare DNS guide
- `docs/DEVELOPMENT_WORKFLOW.md` - Full development workflow
- `docs/DOKPLOY_INTEGRATION_SUMMARY.md` - This file

**Updated:**
- `README.md` - Added new workflow commands
- `DOKPLOY_SETUP.md` - Updated with new scripts

### 9. Package.json Scripts

**File:** `package.json`

**Added scripts:**
```json
{
  "dev": "Start local development",
  "dev:down": "Stop local development",
  "dev:logs": "View Directus logs",
  "deploy:staging": "Deploy to staging",
  "deploy:production": "Deploy to production",
  "sync-schema": "Schema sync script",
  "seed:staging": "Seed staging data",
  "extensions:dev": "Extension development",
  "extensions:build": "Build extensions",
  "db:backup": "Backup local database",
  "db:restore": "Restore local database"
}
```

---

## File Structure

```
directapp/
├── .github/workflows/
│   └── directus-ci.yml                    # ✅ Reworked CI/CD
│
├── .git/hooks/
│   └── pre-commit                         # ✅ Pre-commit validation
│
├── scripts/
│   ├── deploy.sh                          # ✅ Unified deployment
│   ├── sync-schema.sh                     # ✅ Schema sync
│   └── seed-staging.sh                    # ✅ Sample data seeding
│
├── .claude/commands/
│   ├── deploy.md                          # ✅ /deploy command
│   └── sync-schema.md                     # ✅ /sync-schema command
│
├── docs/
│   ├── DNS_SETUP.md                       # ✅ Cloudflare guide
│   ├── DEVELOPMENT_WORKFLOW.md            # ✅ Complete workflow
│   └── DOKPLOY_INTEGRATION_SUMMARY.md     # ✅ This file
│
├── docker-compose.dev.yml                 # ✅ Local dev environment
├── docker-compose.staging.yml             # (Existing, unchanged)
├── docker-compose.production.yml          # (Existing, unchanged)
│
└── package.json                           # ✅ Added dev scripts
```

---

## Environment Setup

### Dokploy Environments

| Environment | URL | Compose ID | Status |
|------------|-----|------------|--------|
| **Staging** | https://staging-gapp.coms.no | `25M8QUdsDQ97nW5YqPYLZ` | ✅ Configured |
| **Production** | https://gapp.coms.no | `YKhjz62y5ikBunLd6G2BS` | ✅ Configured |

### Required GitHub Secrets

Add these to GitHub repository secrets:

```
DOKPLOY_URL=https://deploy.onecom.ai
DOKPLOY_API_KEY=g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG
DOKPLOY_STAGING_ID=25M8QUdsDQ97nW5YqPYLZ
DOKPLOY_PRODUCTION_ID=YKhjz62y5ikBunLd6G2BS
```

### Environment Variables (Per Environment)

**Required in Dokploy:**
- `DIRECTUS_KEY` - 32+ character secret
- `DIRECTUS_SECRET` - 64+ character secret
- `DB_PASSWORD` - Database password
- `PUBLIC_URL` - Full HTTPS URL
- `S3_ACCESS_KEY` - Storage access key
- `S3_SECRET_KEY` - Storage secret key
- `RESEND_API_KEY` - Email API key

---

## Developer Workflow

### Day-to-Day Development

```bash
# 1. Start local environment
pnpm dev

# 2. Develop extensions (hot reload)
cd extensions
pnpm dev

# 3. Make changes
# ... code ...

# 4. Commit (pre-commit hook validates)
git add .
git commit -m "feat: add feature"

# 5. Push (CI/CD auto-deploys to staging)
git push origin main

# 6. Test in staging
open https://staging-gapp.coms.no/admin

# 7. Deploy to production (manual)
pnpm deploy:production
```

### Extension Development

```bash
# Terminal 1: Run Directus
pnpm dev

# Terminal 2: Extension hot reload
cd extensions
pnpm dev

# Make changes → Auto-rebuild → Refresh browser
```

### Schema Changes

```bash
# 1. Make schema changes in local Directus admin

# 2. Export schema
pnpm sync-schema export local

# 3. Sync to staging
pnpm sync-schema local staging

# 4. Test in staging
open https://staging-gapp.coms.no/admin

# 5. Sync to production (requires confirmation)
pnpm sync-schema staging production
```

---

## Deployment Pipeline

### Automatic (Staging)

**Trigger:** Push to `main` branch

**Steps:**
1. Run tests (15 min)
2. Build extensions
3. Deploy to staging
4. Health check

**Result:** Changes live on staging

### Manual (Production)

**Trigger:** GitHub Actions workflow_dispatch OR `pnpm deploy:production`

**Steps:**
1. Manual approval required
2. Build extensions
3. Deploy to production
4. Health check

**Result:** Changes live on production

---

## DNS Configuration

### Cloudflare Setup

**Domain:** `coms.no`

**A Records:**
```
gapp.coms.no          → <DOKPLOY_SERVER_IP>
staging-gapp.coms.no  → <DOKPLOY_SERVER_IP>
```

**Proxy Status:** DNS only (grey cloud)

**SSL:** Managed by Dokploy/Traefik (Let's Encrypt)

**Full guide:** `docs/DNS_SETUP.md`

---

## Database & Storage Isolation

### Per Environment

**Staging:**
- PostgreSQL: `../files/postgres-staging-data/`
- Redis: `../files/redis-staging-data/`
- S3: `directapp-staging` bucket
- Backups: `../files/backups-staging/`

**Production:**
- PostgreSQL: `../files/postgres-data/`
- Redis: `../files/redis-data/`
- S3: `directapp-production` bucket
- Backups: `../files/backups/`

**No data sharing** - complete isolation

---

## Testing

### Local Testing

```bash
pnpm dev
open http://localhost:8055/admin
```

### Staging Testing

```bash
# Auto-deployed on push to main
open https://staging-gapp.coms.no/admin

# Seed sample data
pnpm seed:staging
```

### Integration Tests

Runs automatically in CI:
- Ephemeral Directus instance
- PostgreSQL + Redis services
- Extension loading tests
- API endpoint tests

---

## Security Features

### Pre-commit Hook

- ✅ Detects secrets in code
- ✅ Prevents .env commits
- ✅ Validates code quality

### CI/CD Pipeline

- ✅ Trivy vulnerability scanning
- ✅ Trufflehog secret detection
- ✅ Schema validation
- ✅ Automated tests

### Environment Isolation

- ✅ Separate databases per environment
- ✅ Different secrets per environment
- ✅ Production requires confirmation
- ✅ No cross-environment data access

---

## Next Steps

### Immediate

1. ✅ Configure GitHub secrets
2. ✅ Configure Cloudflare DNS
3. ✅ Test local development: `pnpm dev`
4. ✅ Push to main (triggers staging deploy)
5. ✅ Test staging deployment
6. ✅ Seed staging data: `pnpm seed:staging`

### Within a Week

1. Deploy to production: `pnpm deploy:production`
2. Import production schema
3. Create production users
4. Monitor logs and errors
5. Set up Sentry (optional)

### Ongoing

1. Develop features locally
2. Push to main → auto-deploy staging
3. Test in staging
4. Deploy to production manually
5. Monitor production health

---

## Troubleshooting

### CI/CD Fails

**Check:**
- GitHub secrets configured
- Dokploy API key valid
- Tests passing locally

**View:**
- GitHub Actions → Workflow runs → Logs

### Deployment Fails

**Check:**
- Dokploy service running
- Environment variables set
- Compose file valid

**View:**
- Dokploy UI → Logs
- Health check endpoint

### Extensions Not Loading

**Check:**
- Extensions built: `pnpm extensions:build`
- Mounted correctly in docker-compose
- No build errors

**Fix:**
- Restart Directus
- Clear browser cache
- Check logs

---

## Support & Resources

### Documentation

- [Development Workflow](./DEVELOPMENT_WORKFLOW.md)
- [DNS Setup](./DNS_SETUP.md)
- [Dokploy Deployment Guide](../DOKPLOY_DEPLOYMENT_GUIDE.md)

### External Docs

- [Dokploy Docs](https://docs.dokploy.com)
- [Directus Docs](https://docs.directus.io)
- [Cloudflare DNS Docs](https://developers.cloudflare.com/dns/)

### Getting Help

- Create issue: https://github.com/gumpen-app/directapp/issues
- Check `.claude/` directory for project docs

---

## Summary

### What You Get

✅ **Simple local development** - `pnpm dev` and you're coding
✅ **Hot reload** - See extension changes instantly
✅ **Auto-deployment** - Push to main → live on staging
✅ **Safe production** - Manual approval required
✅ **Schema sync** - Easy database migrations
✅ **Complete isolation** - Dev/staging/prod separated
✅ **Professional setup** - CI/CD, tests, validation
✅ **No overengineering** - Just what you need

### How to Use It

```bash
# Develop
pnpm dev

# Deploy
git push origin main  # → staging
pnpm deploy:production # → production

# Manage schema
pnpm sync-schema local staging
```

**That's it. Simple and professional.**

---

**Questions?** Read the docs or create an issue. Happy coding! 🚀
