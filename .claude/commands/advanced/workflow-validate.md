---
description: Validate workflow health and show performance metrics
argument-hint: [detailed]
model: claude-sonnet-4-5-20250929
allowed-tools: Read, Bash
---

# /workflow-validate - Workflow Health Check

Comprehensive workflow health validation with performance metrics, error analysis, and improvement recommendations.

## What It Does

Analyzes your workflow system to provide:
- **Health Score** (0-100%)
- **Quality Metrics** (task completion, estimation accuracy)
- **Error Analysis** (patterns, thresholds)
- **Session Performance** (streaks, productivity)
- **Recommendations** (actionable improvements)

---

## Usage

```bash
# Quick health check
/workflow-validate

# Detailed analysis
/workflow-validate detailed

# Focus on specific area
/workflow-validate errors
/workflow-validate sessions
```

---

## Steps

### 1. Load Analytics Data

```bash
# Load session history
SESSION_DATA=$(cat .claude/analytics/session-history.json 2>/dev/null || echo '{"sessions":[]}')

# Load task timing
TASK_DATA=$(cat .claude/analytics/task-timing.json 2>/dev/null || echo '{"tasks":[]}')

# Load error patterns
ERROR_DATA=$(cat .claude/analytics/error-patterns.json 2>/dev/null || echo '{"errors":[]}')

# Load workflow state
STATE_DATA=$(cat .claude/analytics/workflow-state.json 2>/dev/null || echo '{}')

# Load command usage
COMMAND_DATA=$(cat .claude/analytics/command-usage.json 2>/dev/null || echo '{"commands":{}}')
```

### 2. Calculate Health Metrics

```bash
# Session metrics
TOTAL_SESSIONS=$(echo "$SESSION_DATA" | jq '.sessions | length')
COMPLETED_SESSIONS=$(echo "$SESSION_DATA" | jq '[.sessions[] | select(.ended_at != null)] | length')
ORPHANED_SESSIONS=$(echo "$SESSION_DATA" | jq '[.sessions[] | select(.orphaned == true)] | length')

# Calculate session completion rate
if [ "$TOTAL_SESSIONS" -gt 0 ]; then
  SESSION_RATE=$(echo "scale=2; $COMPLETED_SESSIONS / $TOTAL_SESSIONS * 100" | bc)
else
  SESSION_RATE=0
fi

# Task metrics
TOTAL_TASKS=$(echo "$TASK_DATA" | jq '.tasks | length')
COMPLETED_TASKS=$(echo "$TASK_DATA" | jq '[.tasks[] | select(.completed_at != null)] | length')

# Calculate task completion rate
if [ "$TOTAL_TASKS" -gt 0 ]; then
  TASK_RATE=$(echo "scale=2; $COMPLETED_TASKS / $TOTAL_TASKS * 100" | bc)
else
  TASK_RATE=0
fi

# Error metrics (from SQLite)
ERROR_COUNT=$(sqlite3 .claude/analytics/analytics.db "SELECT COUNT(*) FROM errors WHERE datetime(timestamp) >= datetime('now', '-24 hours')" 2>/dev/null || echo "0")
CRITICAL_ERRORS=$(sqlite3 .claude/analytics/analytics.db "SELECT COUNT(*) FROM errors WHERE severity >= 8 AND datetime(timestamp) >= datetime('now', '-1 hour')" 2>/dev/null || echo "0")

# Calculate error score (lower errors = higher score)
ERROR_SCORE=100
if [ "$ERROR_COUNT" -gt 0 ]; then
  ERROR_PENALTY=$(echo "scale=2; $ERROR_COUNT * 2" | bc)  # 2 points per error
  ERROR_SCORE=$(echo "scale=2; 100 - $ERROR_PENALTY" | bc)
  if (( $(echo "$ERROR_SCORE < 0" | bc -l) )); then
    ERROR_SCORE=0
  fi
fi

# Estimation accuracy (if tasks have estimates)
TASKS_WITH_ESTIMATES=$(echo "$TASK_DATA" | jq '[.tasks[] | select(.estimated_hours != null and .actual_hours != null)] | length')
if [ "$TASKS_WITH_ESTIMATES" -gt 0 ]; then
  AVG_ACCURACY=$(echo "$TASK_DATA" | jq '
    [.tasks[] | select(.estimated_hours != null and .actual_hours != null) |
     (1 - ((if .actual_hours > .estimated_hours then .actual_hours - .estimated_hours else .estimated_hours - .actual_hours end) / .estimated_hours))] |
    add / length * 100
  ')
  AVG_ACCURACY=$(printf "%.1f" "$AVG_ACCURACY")
else
  AVG_ACCURACY=0
fi
```

### 3. Calculate Overall Health Score

```bash
# Weighted health score calculation
# - Session completion: 25%
# - Task completion: 30%
# - Error score: 25%
# - Estimation accuracy: 20%

HEALTH_SCORE=$(echo "scale=1; (
  ($SESSION_RATE * 0.25) +
  ($TASK_RATE * 0.30) +
  ($ERROR_SCORE * 0.25) +
  ($AVG_ACCURACY * 0.20)
)" | bc)

# Determine health tier
if (( $(echo "$HEALTH_SCORE >= 90" | bc -l) )); then
  HEALTH_TIER="EXCELLENT"
  HEALTH_EMOJI="🌟"
elif (( $(echo "$HEALTH_SCORE >= 80" | bc -l) )); then
  HEALTH_TIER="GOOD"
  HEALTH_EMOJI="✅"
elif (( $(echo "$HEALTH_SCORE >= 70" | bc -l) )); then
  HEALTH_TIER="FAIR"
  HEALTH_EMOJI="⚠️"
else
  HEALTH_TIER="NEEDS IMPROVEMENT"
  HEALTH_EMOJI="❌"
fi
```

### 4. Display Health Dashboard

```bash
echo "🏥 WORKFLOW HEALTH REPORT"
echo "================================"
echo ""
echo "$HEALTH_EMOJI OVERALL HEALTH: ${HEALTH_SCORE}% ($HEALTH_TIER)"
echo ""
echo "📊 Key Metrics:"
echo "   Session Completion: ${SESSION_RATE}%"
echo "   Task Completion: ${TASK_RATE}%"
echo "   Error Score: ${ERROR_SCORE}%"
echo "   Estimation Accuracy: ${AVG_ACCURACY}%"
echo ""
echo "📈 Statistics:"
echo "   Total Sessions: $TOTAL_SESSIONS"
echo "   Completed Tasks: $COMPLETED_TASKS / $TOTAL_TASKS"
echo "   Orphaned Sessions: $ORPHANED_SESSIONS"
echo "   Errors (24h): $ERROR_COUNT"
echo "   Critical Errors (1h): $CRITICAL_ERRORS"
echo ""
```

### 5. Generate Recommendations

```bash
echo "💡 Recommendations:"
echo ""

# Check for orphaned sessions
if [ "$ORPHANED_SESSIONS" -gt 0 ]; then
  echo "   ⚠️  $ORPHANED_SESSIONS orphaned sessions detected"
  echo "      → Always run /session-end or /done to close sessions properly"
  echo ""
fi

# Check for high error rate
if [ "$ERROR_COUNT" -gt 5 ]; then
  echo "   ⚠️  High error rate ($ERROR_COUNT errors in 24h)"
  echo "      → Review .claude/analytics/error-patterns.json"
  echo "      → Consider running /debug to analyze recent errors"
  echo ""
fi

# Check for low task completion
if (( $(echo "$TASK_RATE < 70" | bc -l) )); then
  echo "   ⚠️  Low task completion rate (${TASK_RATE}%)"
  echo "      → Run /done after completing tasks"
  echo "      → Use task timing analytics to track progress"
  echo ""
fi

# Check for poor estimation
if [ "$TASKS_WITH_ESTIMATES" -gt 0 ] && (( $(echo "$AVG_ACCURACY < 70" | bc -l) )); then
  echo "   ⚠️  Low estimation accuracy (${AVG_ACCURACY}%)"
  echo "      → Review task-timing.json for patterns"
  echo "      → Consider breaking down large tasks"
  echo ""
fi

# Success message if health is good
if (( $(echo "$HEALTH_SCORE >= 85" | bc -l) )); then
  echo "   ✅ Workflow health is excellent!"
  echo "      Keep up the good work!"
  echo ""
fi
```

### 6. Detailed Mode (if requested)

```bash
if [ "$1" = "detailed" ]; then
  echo "📋 DETAILED ANALYSIS"
  echo "================================"
  echo ""

  # Session streak
  CURRENT_STREAK=$(node .claude/scripts/workflow/session-lifecycle.mjs --phase=start --json 2>&1 | jq -r '.session.streak // 0')
  echo "🔥 Session Streak: $CURRENT_STREAK days"
  echo ""

  # Command usage
  echo "🛠️  Most Used Commands:"
  echo "$COMMAND_DATA" | jq -r '
    .commands | to_entries |
    sort_by(-.value.count) |
    limit(5; .[]) |
    "   \(.key): \(.value.count) uses"
  '
  echo ""

  # Recent sessions
  echo "📅 Recent Sessions (Last 5):"
  echo "$SESSION_DATA" | jq -r '
    .sessions[-5:] | reverse[] |
    "   Session #\(.number): \(.started_at | split("T")[0]) - \(.duration_hours // 0)h"
  '
  echo ""

  # Task timing stats
  if [ "$COMPLETED_TASKS" -gt 0 ]; then
    AVG_TASK_HOURS=$(echo "$TASK_DATA" | jq '
      [.tasks[] | select(.actual_hours != null) | .actual_hours] |
      add / length
    ')
    echo "⏱️  Average Task Duration: $(printf "%.1f" "$AVG_TASK_HOURS")h"
    echo ""
  fi
fi
```

---

## Example Output

```bash
$ /workflow-validate

🏥 WORKFLOW HEALTH REPORT
================================

✅ OVERALL HEALTH: 87.5% (GOOD)

📊 Key Metrics:
   Session Completion: 95.0%
   Task Completion: 88.2%
   Error Score: 90.0%
   Estimation Accuracy: 82.5%

📈 Statistics:
   Total Sessions: 20
   Completed Tasks: 15 / 17
   Orphaned Sessions: 1
   Errors (24h): 5
   Critical Errors (1h): 0

💡 Recommendations:

   ⚠️  1 orphaned session detected
      → Always run /session-end or /done to close sessions properly

   ✅ Workflow health is good!
      Keep up the good work!
```

---

## Health Score Calculation

**Formula:**
```
Health Score = (
  Session Completion × 0.25 +
  Task Completion × 0.30 +
  Error Score × 0.25 +
  Estimation Accuracy × 0.20
)
```

**Tiers:**
- 90-100%: EXCELLENT 🌟
- 80-89%: GOOD ✅
- 70-79%: FAIR ⚠️
- <70%: NEEDS IMPROVEMENT ❌

---

## When to Run

**Recommended:**
- Start of each week (Monday)
- After completing a sprint
- When workflow feels "off"
- Before major refactoring

**Automated (Future):**
- Auto-run during /session-start if health drops below 75%
- Weekly health report via /analytics

---

## Troubleshooting

### "No analytics data found"
```bash
# Analytics files don't exist yet
# Run a few commands first:
/core:work
/core:done

# Then try again
/workflow-validate
```

### "Health score seems wrong"
```bash
# Check individual metrics
cat .claude/analytics/session-history.json | jq '.sessions | length'
cat .claude/analytics/task-timing.json | jq '.tasks | length'

# Verify calculations manually
```

### "Want to reset analytics"
```bash
# Backup first
cp -r .claude/analytics .claude/analytics.backup

# Reset (careful!)
rm .claude/analytics/*.json

# Start fresh
/core:work
```

---

## Related Commands

- `/core:status` - Quick project status
- `/advanced:analytics` - Deep analytics dive
- `/advanced:debug` - Error diagnosis
- `/core:sync` - GitHub Project sync

---

## Success Metrics (from Source Project)

**proffbemanning-dashboard achieved:**
- Health Score: 89.9% (GOOD)
- Improvement: +7.9 points in one sprint
- Zero critical errors
- 85.7% task completion
- 91% estimation accuracy

**Your results:** Track in STATUS.md
