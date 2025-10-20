---
description: Initialize new Directus extension with intelligent pattern pre-seeding
argument-hint: <project-name> <type> [tech-stack...]
model: claude-sonnet-4-5-20250929
allowed-tools: Bash, Write, Read
---

# /project-init - Initialize Directus Extension with Pattern System

Create a new Directus extension project with intelligent pattern recommendations.

## Usage

```bash
/project-init <project-name> <type> [tech-stack...]

# Examples:
/project-init my-panel panel directus vue3 typescript
/project-init my-hook hook directus typescript
/project-init my-endpoint endpoint directus typescript
/project-init my-module module directus vue3 typescript
```

## What It Does

### 1. Pattern Pre-Seeding 🎯
   - Runs pattern-seeder.ts automatically
   - Extracts Context7 patterns (official docs)
   - Discovers GitHub patterns (community)
   - Ranks and recommends top patterns
   - Generates PATTERN_SUMMARY.md

### 2. Project Structure Creation 📁
   - Creates project directory
   - Standard Directus extension structure
   - Initializes git repository
   - Sets up package.json

### 3. Pattern Documentation 📄
   - Creates PROJECT_PLAN.md with:
     - Top 5 pattern recommendations
     - Pattern composition breakdown
     - Implementation guidance
     - Next steps

### 4. Display Summary ✨
   - Total patterns discovered
   - Source breakdown (Context7 vs GitHub)
   - Top 3 recommendations with scores
   - Files created

## Extension Types

- **panel:** Dashboard panels (Vue3 + TypeScript)
- **hook:** Server-side hooks (TypeScript)
- **endpoint:** Custom API endpoints (TypeScript)
- **module:** Admin modules (Vue3 + TypeScript)
- **interface:** Custom field interfaces (Vue3 + TypeScript)
- **display:** Field displays (Vue3 + TypeScript)
- **operation:** Flow operations (TypeScript)

## Tech Stack Options

**Directus** (always included):
- directus

**Frontend** (for UI extensions):
- vue3 (recommended)

**Language**:
- typescript (recommended)
- javascript

## Pattern System Integration

The command automatically:
1. Detects project type (panel, hook, endpoint, etc.)
2. Builds tech stack array
3. Runs pattern-seeder.ts
4. Saves 20+ patterns to `.claude/memory/patterns/<project>/`
5. Generates recommendations

## Example Output

```
🚀 Initializing Directus extension: my-panel

📊 Pre-seeding patterns...
   ✓ Context7 extractor: 18 patterns
   ✓ GitHub discoverer: 4 patterns
   ✓ Pattern ranking: 22 patterns scored

🎯 Pattern Summary:
   Total patterns: 22
   From Context7: 18 (82%)
   From GitHub: 4 (18%)

⭐ Top 3 Recommendations:
   1. folder-structure (89/100) - GitHub
   2. testing-approach (89/100) - GitHub
   3. common-dependencies (89/100) - GitHub

📁 Created:
   ✓ Project directory: ./my-panel/
   ✓ Pattern files: 22 patterns
   ✓ PROJECT_PLAN.md
   ✓ PATTERN_SUMMARY.md

🎉 Ready to start!
   cd my-panel
   /work  # Start implementing with pattern guidance
```

## Pattern Scoring

Patterns are scored 0-100 using 5 factors:
1. **Base Confidence** (40 pts) - Source reliability
2. **Project Type Match** (25 pts) - Relevance
3. **Tech Stack** (20 pts) - Framework alignment
4. **Community Validation** (15 pts) - Usage frequency
5. **Source Bonus** (5 pts) - Quality multiplier

## Files Generated

```
<project-name>/
├── .claude/
│   └── memory/
│       └── patterns/
│           └── <project-name>/
│               ├── *.json (22 pattern files)
│               └── PATTERN_SUMMARY.md
├── PROJECT_PLAN.md (with pattern recommendations)
├── package.json
├── .gitignore
└── README.md
```

## Next Steps After Init

1. **Review patterns**: `cat PROJECT_PLAN.md`
2. **Start development**: `/work`
3. **Follow recommendations**: Use patterns as implementation guide
4. **Iterate**: Patterns update as project evolves

## Technical Details

### Pattern Sources

**Context7** (18 patterns):
- Directus: hooks, endpoints, panels, flows, schemas, interfaces, displays, modules
- Vue3: composition API, composables, reactive, components, lifecycle
- TypeScript: types, interfaces, generics, guards, utility types

**GitHub** (4 patterns):
- folder-structure
- testing-approach
- common-dependencies
- configuration-patterns

### Integration Script

The command runs:
```bash
npx tsx .claude/scripts/pattern-seeder.ts <project> <type> <tech-stack...>
```

See: `.claude/scripts/PHASE_1_DAY_3_SUMMARY.md` for full pattern seeder documentation.

## See Also

- `/work` - Start implementing with pattern guidance
- Pattern seeder: `.claude/scripts/pattern-seeder.ts`
- Phase 1 docs: `.claude/scripts/PHASE_1_DAY_3_SUMMARY.md`
