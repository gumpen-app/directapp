# Dokploy CLI Configuration Guide

**Created**: 2025-10-21
**Purpose**: Document patterns for configuring Dokploy via CLI for DirectApp deployments

---

## Root Cause: Missing Domain Configuration

### Issue Discovered
After testing staging deployment, health check failed with HTTP 526 (Invalid SSL Certificate).

**Analysis**:
- ✅ Cloudflare DNS configured correctly (* A record → Dokploy IP)
- ✅ Other services on same Dokploy server work fine
- ✅ Deployment script works correctly
- ❌ **Issue**: Traefik routing misconfigured due to incorrect DOMAIN environment variable

### The Problem

In `docker-compose.staging.yml` line 177:
```yaml
- "traefik.http.routers.directapp-staging.rule=Host(`staging-gapp.${DOMAIN}`)"
```

With `.env.staging` having:
```bash
DOMAIN="staging-gapp.coms.no"  # WRONG
```

This expands to:
```yaml
Host(`staging-gapp.staging-gapp.coms.no`)  # DOUBLE PREFIX - WRONG!
```

### The Fix

Change `.env.staging`:
```bash
DOMAIN="coms.no"  # CORRECT
```

Now expands to:
```yaml
Host(`staging-gapp.coms.no`)  # CORRECT!
```

---

## Dokploy Environment Variable Management

### How It Works

1. **Dokploy stores compose configurations internally**
   - Docker Compose file stored in Dokploy
   - Environment variables stored in Dokploy (separate from .env file in repo)
   - Deployments use Dokploy's stored configuration, NOT local files

2. **Local .env files are for reference only**
   - `.env.staging` in repo = documentation/template
   - Actual values used = Dokploy's stored environment variables

### Dokploy CLI Commands

#### Authentication
```bash
# Authenticate (one-time setup)
dokploy authenticate

# Verify authentication
dokploy verify
```

#### Environment Variables

**Pull environment variables FROM Dokploy:**
```bash
dokploy env pull .env.staging.remote
```

**Push environment variables TO Dokploy:**
```bash
dokploy env push .env.staging
```

**Process** (Interactive):
1. Confirms override warning (y/N)
2. Lists projects → Select "G-app"
3. Lists composes → Select staging compose
4. Pushes all variables from file to Dokploy

---

## Configuration Pattern That Works

### Pattern 1: Using Dokploy CLI (Recommended for env vars)

```bash
# 1. Fix local .env file
vim .env.staging
# Change: DOMAIN="staging-gapp.coms.no"
# To:     DOMAIN="coms.no"

# 2. Push to Dokploy
dokploy env push .env.staging
# → Select project: G-app
# → Select compose: staging (25M8QUdsDQ97nW5YqPYLZ)

# 3. Redeploy
./scripts/deploy.sh staging
```

### Pattern 2: Using Dokploy Dashboard (Recommended for compose file)

```bash
# 1. Open Dokploy
https://deploy.onecom.ai

# 2. Navigate to compose
Projects → G-app → Staging Compose (25M8QUdsDQ97nW5YqPYLZ)

# 3. Update environment variables
Settings → Environment → Edit .env
# Change DOMAIN to "coms.no"

# 4. Redeploy
Dashboard → Deploy button
# OR via CLI: ./scripts/deploy.sh staging
```

### Pattern 3: Direct API (For CI/CD automation)

```bash
# Environment variables update (not yet implemented - needs investigation)
# API endpoint: /api/compose.update (needs proper authentication)

# Deployment trigger (already working)
curl -X POST "https://deploy.onecom.ai/api/compose.deploy" \
  -H "x-api-key: $DOKPLOY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"composeId": "25M8QUdsDQ97nW5YqPYLZ"}'
```

---

## Deployment Workflow

### Current Workflow (As Implemented in deploy.sh)

```
1. Check prerequisites (jq, curl)
   ↓
2. Validate environment file exists (.env.staging)
   ↓
3. Build extensions (pnpm build)
   ↓
4. Trigger deployment via API
   POST /api/compose.deploy
   ↓
5. Wait 30 seconds
   ↓
6. Health check
   GET https://staging-gapp.coms.no/server/health
```

**Issue**: Step 4 deploys with Dokploy's STORED config, not local .env file

### Improved Workflow (Recommended)

```
1. Sync environment variables
   dokploy env push .env.staging  # NEW STEP
   ↓
2. Check prerequisites
   ↓
3. Validate local .env matches remote
   ↓
4. Build extensions
   ↓
5. Trigger deployment
   ↓
6. Wait for Traefik to update (60 seconds recommended)
   ↓
7. Health check
```

---

## Domain Configuration Methods

### Method 1: Traefik Labels in docker-compose.yml (Current approach)

**docker-compose.staging.yml:**
```yaml
services:
  directus:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.directapp-staging.rule=Host(`staging-gapp.${DOMAIN}`)"
      - "traefik.http.routers.directapp-staging.entrypoints=websecure"
      - "traefik.http.routers.directapp-staging.tls.certresolver=letsencrypt"
      - "traefik.http.services.directapp-staging.loadbalancer.server.port=8055"
      - "traefik.docker.network=dokploy-network"
```

**Requirements:**
- DOMAIN environment variable must be set to base domain ("coms.no")
- Compose must be deployed for Traefik to pick up labels
- SSL configured via letsencrypt certresolver

### Method 2: Dokploy Domain API (Alternative)

```bash
# Create domain via API
curl -X POST "https://deploy.onecom.ai/api/domain.create" \
  -H "Authorization: Bearer $DOKPLOY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "host": "staging-gapp.coms.no",
    "port": 8055,
    "https": true,
    "certificateType": "letsencrypt",
    "composeId": "25M8QUdsDQ97nW5YqPYLZ",
    "serviceName": "directus",
    "domainType": "compose"
  }'

# List domains for compose
curl "https://deploy.onecom.ai/api/domain.byComposeId?composeId=25M8QUdsDQ97nW5YqPYLZ" \
  -H "Authorization: Bearer $DOKPLOY_TOKEN"
```

**Note**: Requires proper API token (not the deployment-only token)

---

## Environment Variables Reference

### Required for Traefik Routing

```bash
# BASE DOMAIN (not full subdomain!)
DOMAIN="coms.no"                          # ✅ CORRECT
# DOMAIN="staging-gapp.coms.no"          # ❌ WRONG

# Public URL (full URL with protocol)
PUBLIC_URL="https://staging-gapp.coms.no"  # ✅ Used by Directus

# Cookie domain (base domain for cookies)
COOKIE_DOMAIN="gapp.coms.no"               # ✅ Allows subdomain cookies
```

### Environment Variable Precedence

1. **Dokploy Stored Variables** (highest priority - actually used)
2. Environment-specific .env file (`.env.staging`, `.env.production`)
3. Docker Compose file defaults

**Key Insight**: Local .env files are TEMPLATES. Dokploy uses its own stored values.

---

## Troubleshooting

### Health Check Returns HTTP 526

**Symptoms:**
- `curl https://staging-gapp.coms.no` returns HTTP 526
- Cloudflare "Invalid SSL Certificate" error

**Causes:**
1. ❌ Domain not configured in Traefik (wrong DOMAIN env var)
2. ❌ Container not running
3. ❌ SSL certificate not provisioned

**Solution:**
```bash
# 1. Check DOMAIN variable
dokploy env pull .env.remote
grep DOMAIN .env.remote

# 2. Fix if needed
# Edit local .env.staging: DOMAIN="coms.no"
dokploy env push .env.staging

# 3. Redeploy
./scripts/deploy.sh staging

# 4. Wait for SSL certificate (can take 2-3 minutes)
sleep 180

# 5. Test
curl -I https://staging-gapp.coms.no/server/health
```

### Deployment Succeeds but Changes Don't Apply

**Cause**: Local .env file != Dokploy stored variables

**Solution**:
```bash
# Always sync before deploying
dokploy env push .env.staging
./scripts/deploy.sh staging
```

---

## Next Steps

### Immediate Actions

1. ✅ Fix DOMAIN variable in local .env.staging
2. ⏳ Push corrected variables to Dokploy (via CLI or dashboard)
3. ⏳ Redeploy staging
4. ⏳ Verify health endpoint works
5. ⏳ Document successful pattern in deploy.sh

### Future Improvements

1. **Add env sync to deploy.sh**
   ```bash
   # Before deployment
   if command -v dokploy &> /dev/null; then
       echo "y" | dokploy env push .env.$ENV
   fi
   ```

2. **Add domain validation**
   ```bash
   # Check if domain responds before declaring success
   MAX_RETRIES=10
   for i in $(seq 1 $MAX_RETRIES); do
       if curl -sf https://$DOMAIN/server/health; then
           break
       fi
       sleep 30
   done
   ```

3. **Create rollback script**
   ```bash
   # scripts/rollback.sh
   # - Pull previous .env from backup
   # - Redeploy with old config
   ```

---

## Known Issues & Workarounds

### Issue #1: CLI Error - "Cannot read properties of undefined (reading 'map')"

**Discovered**: 2025-10-21 12:50 UTC
**Affects**: `dokploy env push` command
**CLI Version**: v0.2.8

**Error Message**:
```
? Select the project: G-app
TypeError: Cannot read properties of undefined (reading 'map')
```

**Root Cause**:
Dokploy CLI bug when listing compose services. The API response doesn't contain the expected data structure for the compose list.

**Workaround #1: Use Dokploy Dashboard (Recommended)**

```bash
# 1. Open Dokploy Dashboard
https://deploy.onecom.ai

# 2. Navigate to compose
Projects → G-app → Staging Compose

# 3. Go to Settings → Environment
# or look for "Environment Variables" section

# 4. Edit .env file directly in web editor
# Change: DOMAIN="staging-gapp.coms.no"
# To:     DOMAIN="coms.no"

# 5. Save

# 6. Redeploy
./scripts/deploy.sh staging
```

**Workaround #2: Use Alternative CLI (Community)**

```bash
# Install community CLI
npm install -g @sebbev/dokploy-cli

# Use community CLI instead
sebbev-dokploy env push .env.staging
```

**Workaround #3: Direct API Method (Advanced)**

```bash
# Get current compose configuration
curl -s "https://deploy.onecom.ai/api/compose.one?composeId=25M8QUdsDQ97nW5YqPYLZ" \
  -H "Authorization: Bearer $DOKPLOY_API_TOKEN" | jq '.'

# Update environment variables via API
# (API endpoint documentation pending - needs investigation)
```

**Status**: Bug reported to Dokploy team (pending)

---

## Summary: The Pattern That Works

### For Environment Variable Changes

```bash
# 1. Edit local .env file
vim .env.staging

# 2. Validate syntax
source .env.staging  # Should not error

# 3. Push to Dokploy
dokploy env push .env.staging

# 4. Redeploy
./scripts/deploy.sh staging

# 5. Verify
curl https://staging-gapp.coms.no/server/health
```

### For Docker Compose File Changes

```bash
# 1. Edit docker-compose.staging.yml
vim docker-compose.staging.yml

# 2. Update in Dokploy dashboard
# (No CLI command for this yet - use web UI)
# Projects → G-app → Staging → Compose File → Edit

# 3. Redeploy
./scripts/deploy.sh staging
```

### For Domain-Only Changes

```bash
# Option A: Via Traefik labels (recommended)
# 1. Fix DOMAIN env var
# 2. Redeploy (Traefik picks up new labels)

# Option B: Via Dokploy Domain API
# 1. Use domain.create API endpoint
# 2. Configure domain with SSL
# 3. No redeploy needed
```

---

**Last Updated**: 2025-10-21 12:45 UTC
**Status**: Pattern identified, awaiting env var push to Dokploy
**Next**: Push .env.staging to Dokploy and redeploy
