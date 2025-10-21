# Workflow + Skills Integration Guide

**Philosophy**: Use the working JSON workflow + invoke Claude Code skills at strategic moments

**Status**: Production ready (tested 2025-10-21)

---

## Current Working System

### What Works (No Changes Needed)

✅ **Session Management**
- `session-lifecycle.mjs` tracks sessions to JSON
- Start/end/duration all working
- Health checks functional
- Error monitoring active

✅ **GitHub Integration**
- Issue listing works
- Task selection works
- Branch creation works

✅ **Commands Available**
- `/core:work` - Start session + pick task
- `/core:done` - Finish task + create PR
- `/core:status` - Show project state
- `/core:check` - Validate before commit
- `/pattern-seed` - Extract patterns

**Data Storage**: `.claude/analytics/session-history.json`

---

## Skills Integration Strategy

### Available Directus Skills

1. **`directus-development-workflow`**
   - Complete development setup
   - TypeScript, testing, CI/CD
   - Best practices

2. **`directus-backend-architecture`**
   - API extensions
   - Hooks, flows, services
   - Database operations

3. **`directus-ai-assistant-integration`**
   - AI-powered features
   - Chat interfaces
   - Content generation

4. **`directus-ui-extensions-mastery`**
   - Vue 3 UI extensions
   - Modern patterns
   - Real-time data

---

## When to Invoke Skills

### Workflow Trigger Points

```bash
# 1. Starting a new Directus extension
/core:work
# → If task type = "hook" or "endpoint" or "interface"
# → Invoke: directus-development-workflow or directus-backend-architecture

# 2. Building UI components
/core:work
# → If task type = "interface" or "panel" or "module"
# → Invoke: directus-ui-extensions-mastery

# 3. Adding AI features
/core:work
# → If task labels contain "ai" or "assistant"
# → Invoke: directus-ai-assistant-integration

# 4. Extracting patterns
/pattern-seed hooks
# → Invoke: directus-backend-architecture
# → Extract hook patterns from Context7/GitHub

# 5. Before commit (validation)
/core:check
# → Invoke: directus-development-workflow
# → Validate TypeScript, tests, build
```

---

## Integration Patterns

### Pattern 1: Task-Triggered Skills

**When starting work on specific task types:**

```bash
# Example: Working on a hook
/core:work 57

# If task description contains "hook" or "flow":
# Auto-suggest: "This looks like a backend task. Invoke directus-backend-architecture skill?"

# Manual invocation:
/skill directus-backend-architecture
```

### Pattern 2: Pattern Extraction

**When seeding patterns:**

```bash
# Extract hook patterns
/pattern-seed hooks
# Then invoke skill for implementation guidance:
/skill directus-backend-architecture

# Extract interface patterns
/pattern-seed interfaces
# Then invoke skill for UI guidance:
/skill directus-ui-extensions-mastery
```

### Pattern 3: Pre-Commit Validation

**Before committing code:**

```bash
# Validate setup
/core:check

# For Directus-specific validation:
/skill directus-development-workflow
# Ask: "Validate my TypeScript setup and build config"
```

### Pattern 4: Problem-Solving

**When stuck on Directus-specific issues:**

```bash
# Example: Database operations not working
/skill directus-backend-architecture
# Ask: "How do I properly query related items in a hook?"

# Example: Vue component reactivity issues
/skill directus-ui-extensions-mastery
# Ask: "How do I make my interface reactive to collection changes?"
```

---

## Practical Examples

### Example 1: Building a Hook

```bash
# 1. Start work
/core:work

# 2. Pick hook-related task
# Selected: #57 "Phase 5 Week 1: Scheduled Harvester"

# 3. Invoke skill for guidance
/skill directus-backend-architecture

# 4. Ask specific question
"I need to create a scheduled hook that harvests patterns daily.
Show me the proper structure and best practices."

# 5. Implement with skill guidance

# 6. Validate before commit
/core:check

# 7. Done
/core:done
```

### Example 2: Creating an Interface

```bash
# 1. Start work
/core:work

# 2. Invoke UI skill
/skill directus-ui-extensions-mastery

# 3. Ask for pattern
"I need to create a pattern browser interface.
Show me the Vue 3 setup with proper reactivity."

# 4. Implement

# 5. Done
/core:done
```

### Example 3: Pattern Extraction + Implementation

```bash
# 1. Extract patterns
/pattern-seed hooks

# 2. Invoke architecture skill
/skill directus-backend-architecture

# 3. Ask for implementation
"Based on the extracted hook patterns, help me implement
a validation hook for my collection."

# 4. Implement with extracted patterns + skill guidance

# 5. Done
/core:done
```

---

## Skill Invocation Rules

### When to Invoke

✅ **DO invoke skills:**
- Starting Directus-specific tasks
- Need architecture/pattern guidance
- Stuck on Directus API usage
- Want best practices validation
- Extracting/applying patterns

❌ **DON'T invoke skills:**
- Generic JavaScript questions
- Git operations
- Project management tasks
- Non-Directus code

### Skill Selection Guide

**Task Type → Skill Mapping:**

| Task Type | Skill to Invoke |
|-----------|----------------|
| Hook/Flow/Endpoint | `directus-backend-architecture` |
| Interface/Panel/Module | `directus-ui-extensions-mastery` |
| AI Feature/Assistant | `directus-ai-assistant-integration` |
| Setup/Testing/CI | `directus-development-workflow` |
| General Directus | `directus-development-workflow` |

---

## Workflow Health

**Current Status** (tested 2025-10-21):
- ✅ Session tracking: Works (JSON-based)
- ✅ GitHub integration: Works
- ✅ Health monitoring: Works
- ✅ Skills available: 4 Directus skills ready
- ⚠️ SQLite analytics: Not connected (not needed)

**Health Score**: 65% (Working system, manual skill invocation)

**To improve to 85%:**
- ✅ Keep JSON workflow (works)
- ✅ Add skill invocation guidance (this doc)
- ⚠️ Consider auto-skill-suggestion based on task labels (future)

---

## Quick Reference

### Daily Workflow with Skills

```bash
# Morning
/core:work                          # Pick task
/skill directus-backend-architecture  # If backend task

# During work
# Code with skill guidance

# Before commit
/core:check                         # Validate

# Finish
/core:done                          # Submit PR
```

### Pattern-Driven Development

```bash
# Extract patterns
/pattern-seed [type]

# Invoke relevant skill
/skill directus-[backend|ui]-*

# Implement with patterns + skill guidance

# Done
/core:done
```

---

## Success Metrics

**Track these manually (no SQLite needed):**
- Sessions completed per week
- Tasks finished per session
- Patterns extracted and reused
- Skills invoked per task
- Time saved by patterns (estimate)

**Target:**
- 5+ sessions per week
- 1-2 tasks per session
- 3+ pattern reuses per sprint
- Skills invoked when actually helpful (not every task)

---

## Notes

- **Don't rebuild infrastructure** - JSON workflow works fine
- **Skills are tools, not automation** - invoke when YOU need help
- **Pattern extraction is manual** - run `/pattern-seed` when you need patterns
- **Keep it simple** - complicated automation leads to rebuilds

---

**Last Updated**: 2025-10-21
**Status**: ✅ Production ready with manual skill invocation
