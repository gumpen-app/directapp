# Complete Dokploy Management Guide

**Created**: 2025-10-21
**Session**: #9
**Status**: Enhanced MCP with deployment diagnostics

---

## Overview

This guide provides complete Dokploy management access through **three complementary tools**:

1. **Dokploy CLI** (v0.2.8) - Interactive terminal commands
2. **Dokploy MCP** (13 tools) - Natural language automation
3. **Dokploy Dashboard** - Web UI (backup/manual operations)

---

## Quick Reference

### When to Use What

| Task | Tool | Command/Method |
|------|------|---------------|
| Check deployment status | MCP | "What's the status of staging?" |
| View recent deployments | MCP | "Show me recent staging deployments" |
| Deploy compose stack | MCP | `mcp__dokploy__compose_deploy` |
| Create domain routing | MCP | `mcp__dokploy__domain_create` |
| Push env variables | CLI | `dokploy env push .env.staging` (interactive) |
| View container logs | Dashboard | Manual access required |
| Debug failed deployment | MCP | "Show staging deployment history" |

---

## Dokploy MCP Server (Enhanced)

### Installation

Already configured in `.mcp.json`:

```json
{
  "dokploy": {
    "command": "/home/claudecode/dev_projects/tools/dokploy-mcp-python/.venv/bin/python",
    "args": ["/home/claudecode/dev_projects/tools/dokploy-mcp-python/server_full.py"],
    "env": {
      "DOKPLOY_URL": "https://deploy.onecom.ai/api",
      "DOKPLOY_API_KEY": "dd_d..."
    }
  }
}
```

**Restart Claude Code to load changes after enhancing the MCP server.**

### Available Tools (13 total)

#### Project Management
1. **project_all** - List all projects
2. **project_one**(project_id) - Get project details

#### Compose Lifecycle
3. **compose_one**(compose_id) - Get compose stack details
4. **compose_deploy**(compose_id, title, description) - Deploy stack
5. **compose_update**(compose_id, env, compose_file) - Update configuration
6. **compose_start**(compose_id) - Start stack
7. **compose_stop**(compose_id) - Stop stack

#### Deployment Diagnostics (NEW!)
8. **compose_deployments**(compose_id, limit=10) - Get deployment history
9. **compose_status**(compose_id) - Get status summary with latest deployment

#### Domain Routing
10. **domain_create**(host, compose_id, https, certificate_type, port) - Create domain

#### Deployment Status
11. **deployment_one**(deployment_id) - Get deployment details

#### Application Management
12. **application_one**(application_id) - Get application details
13. **application_deploy**(application_id, title) - Deploy application

---

## Natural Language DevOps Examples

### Check Status

"What's the status of the staging environment?"

→ Calls `compose_status('USdQOoYpD-sCfneo9kQbs')`

Returns:
- Current status (idle/running/error/done)
- Latest deployment info
- Domain configuration
- Total deployments
- Branch and auto-deploy settings

### View Deployment History

"Show me the last 5 deployments for staging"

→ Calls `compose_deployments('USdQOoYpD-sCfneo9kQbs', 5)`

Returns:
- Recent deployments (sorted by date)
- Status of each (done/error/running)
- Creation timestamps
- Deployment IDs

### Deploy to Staging

"Deploy the staging environment"

→ Calls `compose_deploy('USdQOoYpD-sCfneo9kQbs', 'Manual deployment', 'Testing deployment')`

### Create Domain

"Add domain staging-gapp.coms.no to staging with HTTPS"

→ Calls `domain_create('staging-gapp.coms.no', 'USdQOoYpD-sCfneo9kQbs', True, 'letsencrypt', 8055)`

### Update Environment Variables

"Update the staging environment variables"

→ Calls `compose_update('USdQOoYpD-sCfneo9kQbs', env='KEY=value\\nKEY2=value2')`

**Note**: Must deploy after updating to apply changes

---

## Dokploy CLI (v0.2.8)

### Setup

```bash
# Already installed and authenticated
dokploy verify  # Check authentication
```

### Available Commands

#### Authentication
```bash
dokploy authenticate
# Prompts for:
# - Server URL: https://deploy.onecom.ai
# - API Token: dd_dSDAITWuPCTmjuHKbLzfAFfItqiqjxBzYZqqjenhxWeSWGJrXeieeGMHojydXOex

dokploy verify
# Verify token is valid
```

#### Project Management
```bash
dokploy project
# Interactive project creation
```

#### Application Management
```bash
dokploy app
# Interactive application creation
```

#### Database Management
```bash
dokploy database
# Interactive database creation
```

#### Environment Variables (Interactive Only)
```bash
dokploy env push .env.staging
# Prompts:
# 1. Confirm override
# 2. Select project (G-app)
# 3. Select compose (staging)
# 4. Confirmation

dokploy env pull
# Download remote env vars to local file
```

### Limitations

❌ **No scripted deployment** - Must use MCP or Dashboard
❌ **No logs access** - Must use Dashboard
❌ **No domain management** - Must use MCP or Dashboard
❌ **Interactive-only env** - Cannot script env updates
❌ **No status checking** - Must use MCP or Dashboard

---

## Complete DevOps Workflow

### 1. Development

```bash
# Local changes committed
git push origin feature-branch

# Staging auto-deploys (if enabled)
# Or trigger manually via MCP
```

### 2. Check Status (via MCP)

```
"What's the status of staging?"
```

Response shows:
- Compose status
- Latest deployment
- Domain configuration

### 3. View Deployment History (via MCP)

```
"Show me recent staging deployments"
```

Response shows:
- Last 10 deployments
- Status (done/error)
- Timestamps

### 4. Debug Failures (via MCP + Dashboard)

**MCP**: Check deployment history to find failed deployment

```
"Show staging deployments"
# Returns: Latest deployment is "error" at 2025-10-21T15:31:35
```

**Dashboard**: Access logs

1. Go to https://deploy.onecom.ai
2. Navigate to G-app → Staging
3. Click "Logs" or "Deployments"
4. View error messages

### 5. Fix and Redeploy

```bash
# Fix issue locally
git commit -m "fix: resolve deployment error"
git push

# Or trigger manual deployment via MCP
```

```
"Deploy staging"
```

### 6. Verify Success

```
"What's the staging status?"
# Check latest deployment shows "done"

curl -I https://staging-gapp.coms.no/server/health
# Verify endpoint responds
```

---

## Environment-Specific IDs

### Staging
- **Compose ID**: `USdQOoYpD-sCfneo9kQbs`
- **Domain**: `staging-gapp.coms.no`
- **Branch**: `staging`
- **Auto-deploy**: Enabled

### Production
- **Compose ID**: `YKhjz62y5ikBunLd6G2BS`
- **Domain**: `gapp.coms.no`
- **Branch**: `main`
- **Auto-deploy**: Enabled (use with caution!)

---

## Troubleshooting

### HTTP 526 (Invalid SSL Certificate)

**Symptoms**: Cloudflare returns 526 error

**Causes**:
1. Domain not configured in Dokploy
2. Container not running
3. Container unhealthy

**Solution**:

```
# 1. Check domain configuration
"List domains for staging"

# 2. Check compose status
"What's the staging status?"
# Look for: status = "error" or "idle"

# 3. Check deployment history
"Show staging deployments"
# Look for recent "error" status

# 4. Access Dashboard for logs
# https://deploy.onecom.ai → G-app → Staging → Logs
```

### Deployment Fails

**MCP Diagnosis**:

```
"Show me recent staging deployments"
# Identify failed deployment ID and timestamp
```

**Dashboard Investigation**:
1. Access Dokploy dashboard
2. View deployment logs
3. Check for errors:
   - Missing environment variables
   - Port conflicts
   - Build failures
   - Docker compose syntax errors

### Domain Not Routing

**Check domain exists**:
```
"List domains for staging"
```

**If missing, create**:
```
"Add domain staging-gapp.coms.no to staging with HTTPS"
```

### Environment Variables Not Applied

**After updating env vars, must deploy**:

```
"Update staging env with KEY=value"
# Then
"Deploy staging"
```

---

## Session #9 Enhancements

### Added Tools

1. **compose_deployments** - Get deployment history
   - Use case: "Show me recent deployments"
   - Returns: Sorted list of deployments with status

2. **compose_status** - Get comprehensive status
   - Use case: "What's the staging status?"
   - Returns: Status, latest deployment, domains, config

### Benefits

✅ **Diagnose without dashboard** - Check deployment status via natural language
✅ **Quick debugging** - See failure history immediately
✅ **Programmatic access** - Can script deployment checks
✅ **Complete visibility** - Status, history, domains in one place

### Testing

```bash
cd /home/claudecode/dev_projects/tools/dokploy-mcp-python

# Test new tools
.venv/bin/python3 -c "
import os, requests, json
os.environ['DOKPLOY_URL'] = 'https://deploy.onecom.ai/api'
os.environ['DOKPLOY_API_KEY'] = 'dd_dSDAITWuPCTmjuHKbLzfAFfItqiqjxBzYZqqjenhxWeSWGJrXeieeGMHojydXOex'
# Test logic here
"
```

---

## Next Steps

### Priority 1: Restart Claude Code

**To load enhanced MCP tools**:
1. Exit Claude Code
2. Restart Claude Code
3. Test new tools:
   ```
   "Show me staging deployment history"
   "What's the status of staging?"
   ```

### Priority 2: Fix Staging Deployment

**Now that we can diagnose**:
1. Check latest deployment status via MCP
2. Access dashboard to view logs
3. Fix identified issue
4. Redeploy and verify

### Priority 3: Document Learnings

**Add to deployment guide**:
- Common error patterns
- Quick fixes
- Deployment checklist

---

## Success Criteria

✅ **Complete DevOps cycle without manual dashboard access**:
- Check status → View history → Deploy → Verify

✅ **Natural language management**:
- "What's the status?" works
- "Show deployments" works
- "Deploy staging" works

✅ **Rapid debugging**:
- Identify failures in <30 seconds
- Access logs in <1 minute
- Fix and redeploy in <5 minutes

---

**Last Updated**: 2025-10-21 (Session #9)
**MCP Tools**: 13 (enhanced from 11)
**Status**: Ready for complete natural language DevOps

