---
description: Deploy to Dokploy environments
argument-hint: [staging|production]
model: claude-sonnet-4-5-20250929
allowed-tools: Bash, Read
---

# /deploy - Deploy to Dokploy

Deploy DirectApp to staging or production Dokploy environments.

## What It Does

1. **Validation**
   - Checks prerequisites (jq, curl)
   - Validates environment configuration
   - Checks if in project root

2. **Build**
   - Installs extension dependencies
   - Builds all extensions
   - Creates deployment artifacts

3. **Deploy**
   - Triggers Dokploy deployment via API
   - Waits for deployment to complete
   - Runs health checks

4. **Confirmation**
   - Staging: Auto-deploy
   - Production: Requires manual confirmation

## Usage

```bash
# Deploy to staging
/deploy staging

# Deploy to production (requires confirmation)
/deploy production

# Show help
/deploy --help
```

## Environments

### Staging
- **URL**: https://staging-gapp.coms.no
- **Auto-deploy**: Yes (on main branch via CI)
- **Confirmation**: Not required
- **Use case**: Testing before production

### Production
- **URL**: https://gapp.coms.no
- **Auto-deploy**: No (manual only)
- **Confirmation**: Required
- **Use case**: Live environment

## Prerequisites

- `jq` installed: `sudo apt install jq`
- `curl` installed
- `DOKPLOY_API_KEY` environment variable (optional, uses default)
- Extensions built (handled automatically)

## Environment Files

Create environment files for each environment:

```bash
# Staging
.env.staging

# Production
.env.production
```

Required variables:
- `DIRECTUS_KEY` - 32+ character secret
- `DIRECTUS_SECRET` - 64+ character secret
- `DB_PASSWORD` - Database password
- `PUBLIC_URL` - Full HTTPS URL

## Deployment Flow

```
1. Check prerequisites
   ↓
2. Validate environment config
   ↓
3. Build extensions (pnpm build)
   ↓
4. Trigger Dokploy deployment (API)
   ↓
5. Wait for deployment (30s)
   ↓
6. Health check (curl /server/health)
   ↓
7. Success ✓
```

## Output Example

```
========================================
DirectApp - Deploy to Staging
========================================

========================================
Checking Prerequisites
========================================

✓ jq installed
✓ curl installed
✓ In project root directory

========================================
Validating Environment: staging
========================================

✓ Environment validation passed

========================================
Building Extensions
========================================

ℹ Installing dependencies...
ℹ Building all extensions...
✓ Extensions built successfully

========================================
Deploying to STAGING
========================================

ℹ Triggering deployment...
✓ Deployment triggered
ℹ Waiting for deployment to complete...
ℹ Running health check...
✓ Health check passed
✓ STAGING deployment completed successfully!

✓ Staging deployment complete!
ℹ URL: https://staging-gapp.coms.no/admin
```

## Error Handling

**Missing prerequisites:**
```
✗ jq is not installed. Install with: sudo apt install jq
```

**Not in project root:**
```
✗ docker-compose.staging.yml not found. Run from project root.
```

**Missing environment variables:**
```
✗ Missing required variable: DIRECTUS_KEY
```

**Health check failed:**
```
✗ Health check failed
```

## Advanced Usage

### Using Custom API Key

```bash
export DOKPLOY_API_KEY="your-api-key"
./scripts/deploy.sh staging
```

### Skip Extension Build

Edit `scripts/deploy.sh` and comment out the `build_extensions` line.

### Custom Compose ID

Edit `scripts/deploy.sh` and update:
```bash
STAGING_COMPOSE_ID="your-compose-id"
PRODUCTION_COMPOSE_ID="your-compose-id"
```

## Integration with CI/CD

This command is also used by GitHub Actions:

- **Staging**: Auto-deploys on push to main
- **Production**: Manual trigger via workflow_dispatch

See `.github/workflows/directus-ci.yml` for details.

## Troubleshooting

**Deployment stuck:**
- Check Dokploy UI for logs
- Verify compose file is valid
- Check environment variables

**Health check fails:**
- Wait 60s and try again
- Check Dokploy logs
- Verify database is running

**Extensions not updated:**
- Clear browser cache
- Hard refresh (Cmd+Shift+R / Ctrl+Shift+R)
- Check `/extensions` directory in Dokploy

## See Also

- `/sync-schema` - Sync database schema
- `/check` - Pre-deployment validation
- `scripts/deploy.sh` - Deployment script
- `DOKPLOY_DEPLOYMENT_GUIDE.md` - Full deployment guide
