---
description: Trigger deployment to staging or production (integrates with GitHub CI/CD)
---

# /core:deploy - Deployment Command

Trigger deployment workflows that integrate with GitHub Actions CI/CD pipeline.

## Usage

```bash
/core:deploy [staging|production] [--skip-checks]
```

## What it does

### Machine Phase (Deterministic)

1. **Pre-deployment Validation**
   - Checks current branch (must be `main` for staging, tagged for production)
   - Verifies all extensions have dist/ directories
   - Runs pattern validation locally
   - Checks for uncommitted changes
   - Validates GitHub CLI authentication

2. **Deployment Trigger**
   - Staging: Triggers auto-deployment on push to `main`
   - Production: Triggers `workflow_dispatch` event manually

3. **Analytics Recording**
   - Records deployment event in `.claude/analytics/analytics.db`
   - Tracks: timestamp, environment, commit, actor, success/failure
   - Updates deployment streak counter

4. **Health Monitoring**
   - Waits for deployment completion
   - Checks endpoint health (30s staging, 45s production)
   - Validates extensions loaded correctly
   - Reports deployment status

### Intelligence Phase (LLM Analysis)

5. **Deployment Summary**
   - Extension changes deployed
   - Health check results
   - Deployment duration
   - Any warnings or recommendations

6. **Post-Deployment Actions**
   - Update STATUS.md with deployment info
   - Suggest rollback if health checks fail
   - Recommend next steps

## Examples

### Deploy to Staging (Auto on main push)
```bash
# Automatically triggered on push to main
git push origin main

# Or manual trigger
/core:deploy staging
```

### Deploy to Production (Manual approval)
```bash
# Requires workflow_dispatch trigger
/core:deploy production

# With skip checks (not recommended)
/core:deploy production --skip-checks
```

## Pre-deployment Checklist

Before deployment, ensure:
- ✅ All extensions built (`/extensions:build`)
- ✅ Pattern validation passing (`/core:check`)
- ✅ Tests passing (`/quality:test`)
- ✅ Schema snapshot updated (if schema changed)
- ✅ PR reviewed and merged to `main`

## Deployment Flow

### Staging (Auto-deploy)
```
Push to main → GitHub Actions
  ├─ Build Extensions
  ├─ Validate Patterns
  ├─ Schema Validation
  ├─ Integration Tests
  ├─ Security Scan
  └─ Deploy to Staging → Health Check
```

### Production (Manual)
```
/core:deploy production → workflow_dispatch
  ├─ Build Extensions
  ├─ Validate Patterns
  ├─ Schema Validation
  ├─ Integration Tests
  ├─ Security Scan
  ├─ Manual Approval Gate
  └─ Deploy to Production → Health Check
```

## Environment Configuration

Deployments use GitHub Environments with protection rules:

**Staging:**
- Auto-deploy on `main` branch
- No approval required
- URL: https://staging-gapp.coms.no

**Production:**
- Manual trigger only
- Requires approval (optional)
- URL: https://gapp.coms.no

## Secrets Required

Ensure these secrets are configured in GitHub:
- `DOKPLOY_URL` - Dokploy API endpoint
- `DOKPLOY_API_KEY` - API authentication key
- `DOKPLOY_STAGING_ID` - Staging compose ID
- `DOKPLOY_PRODUCTION_ID` - Production compose ID

## Analytics Integration

Deployment events are tracked in analytics database:

```sql
-- View recent deployments
SELECT * FROM deployments
ORDER BY timestamp DESC
LIMIT 10;

-- Deployment success rate
SELECT
  environment,
  COUNT(*) as total,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
  ROUND(100.0 * SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate
FROM deployments
GROUP BY environment;
```

## Health Monitoring

Post-deployment health checks:

1. **Server Health**: `/server/health` endpoint
2. **Extensions Loaded**: `/server/info` extensions list
3. **Endpoint Tests**: Specific extension endpoint tests
4. **Response Times**: Latency validation

## Rollback Procedure

If deployment fails or issues detected:

```bash
# Automatic rollback (if health check fails)
# Handled by workflow automatically

# Manual rollback
/advanced:rollback deployment-<id>

# Or via GitHub
gh workflow run directus-ci.yml --ref <previous-commit-sha>
```

## Pattern-First Deployment

This command enforces pattern validation:
- ✅ Official Directus extension structure
- ✅ No anti-patterns (no node_modules, no .disabled)
- ✅ Valid TypeScript configuration
- ✅ Proper naming conventions

Deployment **will fail** if patterns violated.

## Philosophy

**Machine→Intelligence:**
- Scripts handle deployment mechanics (deterministic)
- LLM provides insights and recommendations (analysis)
- Zero manual deployment steps (fully automated)

**Analytics-Driven:**
- Track deployment success rates
- Monitor deployment duration
- Identify deployment patterns
- Continuous improvement

## Related Commands

- `/core:check` - Pre-deployment validation
- `/quality:test` - Run test suite before deploy
- `/advanced:rollback` - Undo failed deployment
- `/core:status` - View deployment history

## Notes

- Staging deploys automatically on push to `main`
- Production deploys require manual trigger
- All deployments record analytics
- Health checks run automatically
- Extensions must pass pattern validation

---

**Command Type:** Core (Daily Use)
**Phase:** Machine→Intelligence
**Analytics:** Enabled
**Upstream:** Inherits from claudecode-system
