# WORKFLOW RUNBOOK - THE ACTUAL WORKFLOW

**What this is:** The real commands you run, in order, that actually work.

---

## DAILY FLOW (What Actually Works)

### START YOUR DAY

```bash
/core:work
# - Starts session
# - Picks next task from GitHub Project
# - Creates feature branch
# - Loads task context
# - Shows specialist recommendations
```

### DO THE WORK

```bash
# Code, implement, test

# Validate before committing
/core:check
# - TypeScript check
# - Build dry-run
# - Tests (if configured)
# - Lint (if configured)
```

### FINISH TASK

```bash
/core:done
# - Commits changes
# - Creates PR
# - Updates GitHub Project
# - Logs task timing
# - Updates analytics
```

### END YOUR DAY

```bash
# Session automatically ends with /core:done
# Or manually:
/session-end "what you accomplished"
```

---

## WEEKLY FLOW

```bash
# Monday
/core:sync              # Pull latest from GitHub Project

# During week
/core:work              # Repeat daily
# ... code ...
/core:done

# Friday
/advanced:analytics     # Check performance
/workflow-validate      # Health check
```

---

## WHAT COMMANDS ACTUALLY EXIST

### Core (Daily Use) - 5 commands

```bash
/core:work [task-id]          # Start session + pick task + branch
/core:done [task-id]          # Finish + commit + PR + analytics
/core:status [detailed]       # Project dashboard view
/core:sync [pull|push|both]   # GitHub Project sync
/core:check [quick|full]      # Validation (type/test/lint)
```

### Quality - 2 commands

```bash
/quality:fix [safe|aggressive]  # Auto-fix issues
/quality:test [pattern|watch]   # Run tests
```

### Advanced - 3 commands

```bash
/advanced:analytics [sprint|specialist|tasks]  # Performance insights
/advanced:rollback [operation-id|last]         # Undo operations
/advanced:debug [error-id|recent]              # Error diagnosis
```

### Utils - 2 commands

```bash
/utils:archive [name]       # Snapshot current state
/utils:experiment [name]    # Safe experiment branch
```

**Total: 12 organized commands** (vs 73 in source project!)

---

## WHAT SCRIPTS ACTUALLY RUN

### Analytics (Core Tracking)

```bash
# SQLite Analytics Database
.claude/lib/analytics-db.mjs          # Analytics database library (7 tables, WAL mode)
.claude/analytics/analytics.db        # SQLite database (sessions, tasks, commands, errors, etc.)

# Model Routing
.claude/lib/model-router.mjs          # Haiku/Sonnet routing with thinking budgets

# Analytics Tables:
# - sessions: Session tracking with streaks
# - tasks: Task metrics with specialist performance
# - commands: Command usage with model/thinking budget tracking
# - errors: Error monitoring with severity levels
# - workflow_state: Current workflow state
# - metadata: Key-value storage
# - pattern_usage: Pattern ROI tracking (time saved, confidence)
```

### Workflow Orchestration

```bash
# Session lifecycle (Machine→Intelligence pattern)
.claude/scripts/workflow/session-lifecycle.mjs
```

### Pattern Extraction (Future)

```bash
# Pattern seeding
.claude/scripts/extractors/pattern-extractor.mjs
```

---

## WHAT ANALYTICS EXIST

### Current Analytics Files

```bash
.claude/analytics/
├── session-history.json      # Session tracking
├── task-timing.json          # Task duration & accuracy
├── command-usage.json        # Command frequency
├── workflow-state.json       # Current state
├── error-patterns.json       # Error monitoring
└── analytics.db              # SQLite (future)
```

### Analytics Usage

```bash
# View session history (SQLite)
sqlite3 .claude/analytics/analytics.db "SELECT COUNT(*) FROM sessions"

# Check task completion rate (SQLite)
sqlite3 .claude/analytics/analytics.db "SELECT COUNT(*) FROM tasks WHERE completed_at IS NOT NULL"

# See error stats (last 24h, SQLite)
sqlite3 .claude/analytics/analytics.db "SELECT COUNT(*) as total,
  SUM(CASE WHEN severity >= 8 THEN 1 ELSE 0 END) as critical
  FROM errors WHERE datetime(timestamp) >= datetime('now', '-24 hours')"

# View workflow state (SQLite)
sqlite3 .claude/analytics/analytics.db "SELECT * FROM workflow_state"

# Pattern ROI (SQLite)
sqlite3 .claude/analytics/analytics.db "SELECT pattern_name, SUM(time_saved_hours) as hours_saved
  FROM pattern_usage GROUP BY pattern_name ORDER BY hours_saved DESC"
```

---

## PATTERN MEMORY SYSTEM

### What It Is

**Pattern Memory**: Stores extracted patterns from Directus docs, Context7, and community repos

**Why**: 68-72% time savings on implementation (proven in source)

### Pattern Extraction

```bash
# Extract Directus extension patterns
/pattern-seed hooks          # Hook patterns
/pattern-seed endpoints      # Endpoint patterns
/pattern-seed operations     # Operation patterns

# Patterns saved to:
.claude/memory/patterns/
├── directus/               # Official patterns (95% confidence)
├── context7/               # Context7 patterns (90% confidence)
├── github/                 # Community patterns (60-85% confidence)
└── project/                # Custom patterns (85% confidence)
```

### Pattern Usage

```bash
# Before implementing new extension:
1. /pattern-seed <extension-type>
2. Review: cat .claude/memory/patterns/directus/<type>-pattern.json
3. Implement using verified patterns
4. Save 68-72% implementation time!
```

---

## HEALTH MONITORING

### Quick Health Check

```bash
/workflow-validate
# Shows:
# - Overall health score (0-100%)
# - Session completion rate
# - Task completion rate
# - Error score
# - Estimation accuracy
```

### Detailed Analytics

```bash
/advanced:analytics
# Deep dive:
# - Sprint progress
# - Specialist performance
# - Task timing patterns
# - Velocity calculations
```

### Error Monitoring

```bash
/advanced:debug
# Shows:
# - Recent errors (last 10)
# - Error patterns
# - Severity breakdown
# - Recommendations
```

---

## SUCCESS METRICS

### Target Benchmarks

**From Source Project (proffbemanning-dashboard):**
- ✅ Health Score: 89.9% (GOOD tier)
- ✅ Session Completion: 95%
- ✅ Task Completion: 88.2%
- ✅ Estimation Accuracy: 91%
- ✅ Error Rate: <5 per 24h
- ✅ Session Streak: 12+ days

**Your Metrics:** Track in `.claude/STATUS.md`

### How to Achieve

1. **Use /core:work daily** - Consistent workflow
2. **Always run /core:done** - Complete tasks properly
3. **Run /core:check before committing** - Catch errors early
4. **Use /pattern-seed before implementing** - Save 68-72% time
5. **Weekly /workflow-validate** - Monitor health trends

---

## QUICK REFERENCE CARD

### Morning Routine (2 min)

```bash
1. /core:work              # Pick task
2. Review task details     # Understand requirements
3. /pattern-seed [type]    # Extract relevant patterns
```

### Development Cycle (repeat)

```bash
1. Code                    # Implement
2. /core:check             # Validate
3. Fix issues              # Address errors
4. Repeat until clean
```

### Finish Routine (1 min)

```bash
1. /core:check             # Final validation
2. /core:done              # Commit + PR + Analytics
```

### Weekly Health (5 min)

```bash
1. /workflow-validate      # Check health
2. /advanced:analytics     # Review performance
3. /advanced:debug         # Check errors
```

---

## EMERGENCY PROCEDURES

### Orphaned Sessions

```bash
# Symptoms: Session count incorrect, can't start new session
# Fix: Sessions auto-close on /core:work
# Manual: Run session-lifecycle.mjs --phase=start
```

### Analytics Corrupt

```bash
# Backup first
cp -r .claude/analytics .claude/analytics.backup

# Reset specific file
echo '{"sessions":[]}' > .claude/analytics/session-history.json

# Or reset all
rm .claude/analytics/*.json
/core:work  # Reinitialize
```

### Command Not Found

```bash
# Check command exists
ls .claude/commands/core/work.md

# Check organization
ls .claude/commands/*/

# Available:
# - core/ (5 commands)
# - quality/ (2 commands)
# - advanced/ (3 commands)
# - utils/ (2 commands)
```

### Git Issues

```bash
# Uncommitted changes blocking
git status
git stash  # Save changes
/core:work

# Wrong branch
git checkout main
/core:work  # Creates new feature branch

# Merge conflicts
git status
# Resolve conflicts manually
git add .
/core:done
```

---

## INTEGRATION CHECKLIST

### First-Time Setup (5 min)

- [ ] Configure `.claude/config/project.json`
- [ ] Configure `.claude/config/github-project.json` (if using GitHub)
- [ ] Run `/core:work` to initialize analytics
- [ ] Verify analytics files created in `.claude/analytics/`
- [ ] Test `/workflow-validate` for baseline health

### Daily Checklist

- [ ] `/core:work` - Start session + pick task
- [ ] `/pattern-seed [type]` - Extract patterns (if needed)
- [ ] `/core:check` - Validate before committing
- [ ] `/core:done` - Finish task properly

### Weekly Checklist

- [ ] `/core:sync` - Sync GitHub Project
- [ ] `/workflow-validate` - Health check
- [ ] `/advanced:analytics` - Performance review
- [ ] Review `.claude/STATUS.md` - Progress tracking

---

## CI/CD INTEGRATION (Pattern-First Development)

### GitHub Actions Workflow

The `.github/workflows/directus-ci.yml` workflow enforces the pattern-first development methodology:

**Pipeline Jobs:**
1. **build-extensions** - Builds all extensions using official Directus SDK
2. **lint-extensions** - Type checking and linting
3. **validate-patterns** - Pattern compliance (NEW)
4. **validate-schema** - Schema consistency checks
5. **integration-test** - Ephemeral Directus testing
6. **security-scan** - Trivy + TruffleHog scanning
7. **health-monitor** - Workflow health scoring (NEW)
8. **deploy-staging** - Auto-deploy on `main` branch
9. **deploy-production** - Manual deployment trigger

### Pattern Validation (Enforces Official Directus Patterns)

**Validates:**
- ✅ Extension structure (package.json + src/index.ts)
- ✅ Directus config in package.json
- ✅ Naming conventions (lowercase with hyphens)
- ✅ No committed node_modules
- ✅ No .disabled extensions
- ✅ No monorepo infrastructure

**Prevents Anti-Patterns:**
- ❌ Committed dependencies (195MB+ bloat)
- ❌ Custom monorepo setup
- ❌ Disabled extensions without archiving
- ❌ Invalid naming conventions

### Health Monitoring

**Workflow Health Score:**
- Calculated: `(successful_jobs / total_jobs) * 100`
- Tiers: EXCELLENT (90-100%), GOOD (75-89%), FAIR (60-74%), POOR (<60%)
- Tracked in analytics database
- Alerts on degradation

**Commands:**
```bash
/advanced:workflow-health         # View CI/CD health
/advanced:workflow-health --detailed  # Deep analysis
```

### Commands Integration

**Workflow-Connected Commands:**

```bash
# /core:done - Creates PR + triggers CI
/core:done
  ├─ Commits changes
  ├─ Creates PR
  ├─ Triggers directus-ci.yml workflow
  ├─ Monitors CI status
  ├─ Reports pattern validation results
  └─ Records analytics

# /core:deploy - Manual deployment
/core:deploy staging
  ├─ Pre-deployment validation
  ├─ Pattern compliance check
  ├─ Triggers GitHub Actions
  ├─ Monitors deployment
  └─ Health checks

# /advanced:workflow-health - CI/CD monitoring
/advanced:workflow-health
  ├─ Fetches workflow runs
  ├─ Calculates health score
  ├─ Pattern validation stats
  └─ Deployment analytics
```

### Deployment Flow Integration

**Staging (Automatic):**
```
/core:done → PR merged to main → GitHub Actions
  ├─ Pattern validation
  ├─ Build extensions
  ├─ Integration tests
  ├─ Security scan
  └─ Deploy to staging → Health check
```

**Production (Manual):**
```
/core:deploy production → workflow_dispatch
  ├─ Manual approval gate
  ├─ All validation jobs
  └─ Deploy to production → Health check
```

### Analytics Integration

**Tracked in `.claude/analytics/analytics.db`:**
- Workflow runs (status, duration, failures)
- Deployment events (environment, success rate)
- Pattern violations (caught, prevented)
- Health scores (trends over time)

**Query Examples:**
```sql
-- Workflow success rate
SELECT
  COUNT(*) as total,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
  ROUND(100.0 * SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) / COUNT(*), 2) as rate
FROM workflow_runs
WHERE workflow_name = 'directus-ci';

-- Pattern violations over time
SELECT DATE(timestamp), COUNT(*) as violations
FROM pattern_checks
WHERE violations > 0
GROUP BY DATE(timestamp);
```

### Environment Configuration

**Required GitHub Secrets:**
- `DOKPLOY_URL` - Dokploy API endpoint
- `DOKPLOY_API_KEY` - API authentication
- `DOKPLOY_STAGING_ID` - Staging compose ID
- `DOKPLOY_PRODUCTION_ID` - Production compose ID

**GitHub Environments:**
- `staging` - Auto-deploy, no approval
- `production` - Manual trigger, optional approval

### Philosophy Integration

**Machine→Intelligence:**
- Scripts: Deterministic validation (pattern checks, builds, tests)
- LLM: Analysis and recommendations (health assessment, improvement suggestions)

**Pattern-First Development:**
- 95% confidence from official Directus docs
- Prevents anti-patterns proactively
- Validates before deployment
- Zero tolerance for pattern violations

**Continuous Improvement:**
- Health monitoring tracks trends
- Analytics guide optimization
- Failure patterns identified
- Preventive measures suggested

---

## WHAT WORKS RIGHT NOW

✅ **Session Management:**
- Session start/end tracking
- Orphaned session auto-cleanup
- Session streak calculation
- Duration warnings

✅ **Task Management:**
- GitHub Project integration (via /core:sync)
- Task timing analytics
- Estimation accuracy tracking
- Branch auto-creation

✅ **Analytics:**
- Command usage tracking
- Error pattern monitoring
- Workflow state management
- Health score calculation

✅ **Pattern Memory:**
- Pattern extraction framework
- Confidence scoring system
- Multi-source pattern support
- Documentation ready

---

## WHAT'S COMING (Future)

🔄 **Auto-Integration:**
- Pattern auto-extraction on /core:work
- Auto-validation on commit
- Smart task recommendations

🔄 **SQLite Migration:**
- Faster analytics queries
- Better performance tracking
- Historical trending

🔄 **Enhanced Patterns:**
- GitHub community patterns
- Pattern effectiveness scoring
- Auto-pattern-application

---

## PHILOSOPHY

**Organized > Complex:**
- 12 clear commands vs 73 scattered
- Progressive disclosure (core → advanced)
- Composable operations

**Machine→Intelligence:**
- Scripts handle deterministic work
- LLM provides insights and guidance
- Zero calculation errors

**Pattern-First Development:**
- 95% confidence from official docs
- 68-72% time savings proven
- Prevent implementation mistakes

**Continuous Improvement:**
- Analytics guide decisions
- Health scores track progress
- Iterate based on data

---

## TRUTH

**What works right now:**
- Core workflow (/work → code → /check → /done)
- Analytics tracking (session, task, command, error)
- Pattern memory system (documentation + framework)
- Health monitoring (/workflow-validate, /debug)

**What doesn't work yet:**
- Auto-pattern extraction on /core:work
- SQLite analytics backend
- GitHub community pattern consensus
- Automated improvement suggestions

**Bottom line:** The workflow is operational and analytics are tracking. Pattern system is ready for use. Health monitoring provides visibility.

---

## NEXT STEPS

**Immediate (This Session):**
1. Test core workflow: `/core:work` → code → `/core:done`
2. Verify analytics: Check `.claude/analytics/*.json` files
3. Validate health: Run `/workflow-validate`

**Short-term (This Week):**
1. Use `/pattern-seed` before implementing extensions
2. Build pattern library (hooks, endpoints, operations)
3. Establish baseline metrics in STATUS.md

**Long-term (This Sprint):**
1. Integrate pattern auto-extraction
2. Build specialist performance tracking
3. Optimize workflow based on analytics

---

**Last Updated**: 2025-10-21
**Status**: Foundation Complete, Ready for Daily Use
**Success Metric**: Track 85%+ health score in first sprint
**Philosophy**: Ship fast, measure everything, improve continuously
