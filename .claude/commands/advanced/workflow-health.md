---
description: Monitor CI/CD workflow health and deployment analytics
---

# /advanced:workflow-health - CI/CD Health Monitoring

Monitor GitHub Actions CI/CD pipeline health, deployment analytics, and pattern compliance.

## Usage

```bash
/advanced:workflow-health [--detailed] [--last-n=10]
```

## What it does

### Machine Phase (Deterministic)

1. **Fetch Workflow Runs**
   - Query GitHub Actions API for recent workflows
   - Filter by workflow: `directus-ci.yml`
   - Collect: status, duration, failure points, timestamps

2. **Calculate Metrics**
   - Success rate (last 10/30/90 days)
   - Average build duration
   - Failure patterns (which jobs fail most)
   - Deployment frequency

3. **Pattern Validation Stats**
   - Pattern violations caught
   - Anti-patterns prevented
   - Extension compliance rate

4. **Deployment Analytics**
   - Staging deployment frequency
   - Production deployment success rate
   - Rollback frequency
   - Deployment duration trends

### Intelligence Phase (LLM Analysis)

5. **Health Assessment**
   - Overall CI/CD health score (0-100%)
   - Bottleneck identification
   - Failure pattern analysis
   - Improvement recommendations

6. **Trend Analysis**
   - Compare current vs historical metrics
   - Identify degradation trends
   - Suggest preventive measures

## Output Format

```
# CI/CD Workflow Health Report

## Overall Health: 87% (GOOD)

### Workflow Statistics (Last 30 days)
- Total Runs: 45
- Success Rate: 91.1% (41/45)
- Average Duration: 8m 32s
- Failures: 4 (build: 2, integration-test: 1, security-scan: 1)

### Pattern Validation
- Extensions Validated: 6
- Pattern Violations: 0
- Anti-patterns Prevented: 0
- Compliance Rate: 100%

### Deployment Health
- Staging Deploys: 28 (auto)
- Production Deploys: 5 (manual)
- Success Rate: 96.4%
- Average Duration: 2m 15s
- Rollbacks: 0

### Job Performance
| Job                  | Success Rate | Avg Duration | Failures |
|----------------------|--------------|--------------|----------|
| build-extensions     | 100%         | 1m 23s       | 0        |
| lint-extensions      | 100%         | 45s          | 0        |
| validate-patterns    | 100%         | 32s          | 0        |
| validate-schema      | 100%         | 18s          | 0        |
| integration-test     | 95.6%        | 3m 45s       | 2        |
| security-scan        | 97.8%        | 2m 10s       | 1        |

### Recent Failures
1. [2025-10-29 14:23] integration-test: Postgres connection timeout
2. [2025-10-28 09:15] build-extensions: npm install failed (transient)
3. [2025-10-27 16:45] security-scan: New vulnerability detected

### Recommendations
✅ Overall health is GOOD
⚠️  Integration tests have highest failure rate - investigate Postgres stability
✅ Pattern validation preventing issues proactively
✅ Deployment success rate excellent
💡 Consider adding performance regression tests
```

## Metrics Tracked

### Workflow Metrics
- **Success Rate**: Percentage of successful workflow runs
- **Duration**: Time from start to completion
- **Failure Points**: Which jobs fail most frequently
- **Recovery Time**: Time to fix failed workflows

### Pattern Compliance
- **Violations Caught**: Pattern issues detected
- **Anti-patterns**: Prevented bad practices
- **Compliance Rate**: Extensions following patterns
- **Naming Violations**: Incorrect naming conventions

### Deployment Metrics
- **Frequency**: Deployments per week/month
- **Success Rate**: Successful deployments / total
- **Duration**: Average deployment time
- **Rollbacks**: Frequency and reasons

### Extension Health
- **Build Success**: Extensions building correctly
- **Type Check Pass**: TypeScript validation
- **Test Coverage**: Extension test coverage
- **Security Issues**: Vulnerabilities found

## Health Score Calculation

```
Health Score = (
  workflow_success_rate * 0.30 +
  pattern_compliance * 0.25 +
  deployment_success * 0.25 +
  test_pass_rate * 0.20
)

Tiers:
- 90-100%: EXCELLENT ✅
- 75-89%:  GOOD ✅
- 60-74%:  FAIR ⚠️
- <60%:    POOR ❌
```

## Integration with Analytics

Data sources:
1. **GitHub Actions API**: Workflow run data
2. **Analytics DB**: `.claude/analytics/analytics.db`
3. **Pattern Memory**: `.claude/memory/patterns/`
4. **Deployment Logs**: Recorded in analytics

## Examples

### Basic Health Check
```bash
/advanced:workflow-health
```

### Detailed Analysis (last 50 runs)
```bash
/advanced:workflow-health --detailed --last-n=50
```

### Weekly Health Report
```bash
# Run every Monday
/advanced:workflow-health --detailed > .claude/reports/workflow-health-$(date +%Y%m%d).md
```

## Failure Pattern Analysis

Common failure patterns detected:

1. **Transient Network Issues**
   - npm install timeouts
   - Docker registry connection failures
   - GitHub Actions service disruptions

2. **Integration Test Flakiness**
   - Postgres startup timing
   - Redis connection delays
   - Extension loading race conditions

3. **Security Scan False Positives**
   - Config file false alarms
   - Documentation flagged incorrectly
   - Known vulnerabilities in dev dependencies

## Automated Alerts

Configure alerts in `.claude/config/alerts.json`:

```json
{
  "workflow_health": {
    "enabled": true,
    "thresholds": {
      "success_rate_min": 85,
      "health_score_min": 75,
      "consecutive_failures": 3
    },
    "notify": {
      "channels": ["github-issues", "analytics-log"],
      "on_degradation": true,
      "on_recovery": true
    }
  }
}
```

## Historical Trends

View trends over time:

```sql
-- Query analytics database
SELECT
  DATE(timestamp) as date,
  COUNT(*) as runs,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
  ROUND(AVG(duration_seconds), 2) as avg_duration
FROM workflow_runs
WHERE workflow_name = 'directus-ci'
GROUP BY DATE(timestamp)
ORDER BY date DESC
LIMIT 30;
```

## Philosophy

**Machine→Intelligence:**
- Scripts collect and calculate metrics (deterministic)
- LLM analyzes patterns and recommends improvements (intelligence)
- Zero manual metric tracking

**Continuous Improvement:**
- Track health over time
- Identify degradation early
- Data-driven optimization
- Prevent issues proactively

**Pattern-First Monitoring:**
- Pattern compliance tracked
- Anti-pattern prevention measured
- Extension quality monitored

## Related Commands

- `/core:status` - Project dashboard (includes CI/CD)
- `/advanced:analytics` - Deep analytics dive
- `/advanced:debug` - Error diagnosis
- `/core:deploy` - Deployment workflow

## Integration Points

This command integrates with:
- GitHub Actions API (workflow data)
- Analytics Database (historical tracking)
- Pattern Memory (compliance data)
- Deployment Logs (success/failure)

## API Requirements

Requires GitHub CLI authentication:

```bash
gh auth status
# Or set GITHUB_TOKEN environment variable
```

## Notes

- Runs as read-only operation (no modifications)
- Caches data for 5 minutes (avoid API rate limits)
- Automatically tracks trends in analytics DB
- Alerts configured via `.claude/config/alerts.json`

---

**Command Type:** Advanced (Power User)
**Phase:** Machine→Intelligence
**Analytics:** Enabled
**Data Sources:** GitHub API + Analytics DB + Pattern Memory
