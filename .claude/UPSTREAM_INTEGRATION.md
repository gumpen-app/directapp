# Upstream Claude Code System Integration

**Status**: ✅ Enabled
**Updated**: 2025-10-29

## Overview

This project inherits commands, skills, and agents from the upstream `claudecode-system` at:
```
/home/claudecode/claudecode-system
```

## Available Upstream Resources

### Slash Commands
Located: `/home/claudecode/claudecode-system/.claude/commands/`

- `/help` - Show all available skills and slash commands
- `/build-ui` - **nextjs-ui-designer**: Create Next.js/Tailwind interfaces
- `/orchestrate` - **multi-agent-orchestrator**: Design multi-agent systems
- `/test-edge-cases` - **edge-case-generator**: Generate adversarial test cases
- `/collide-perspectives` - **perspective-collision-engine**: Analyze from competing viewpoints

### Skills
Located: `/home/claudecode/claudecode-system/.claude/skills/`

**Core Skills:**
- `rogue-developer-manager` - Project organization
- `noise-eliminator` - Code cleanup & dead code removal
- `documentation-master` - Living documentation system
- `knowledge-graph` - Searchable knowledge base

**Automation Skills:**
- `auto-workflow-triggers` - Event-driven automation framework
- `claude-code-setup` - Configuration management
- `skill-creator-assistant` - Create new skills

**Planning Skills:**
- `project-architect` - Project planning & decomposition
- `ultrathink-analyzer` - Deep analysis

### Command-Line Tools
Located: `/home/claudecode/claudecode-system/bin/`

```bash
cs                    # Main system command
cs status            # System health check
cs skill [name]      # Execute skills
cs workflow [path]   # Run workflows

memory-search        # Search knowledge base
memory-store         # Store patterns/knowledge
session-analyze      # Analyze work sessions
```

### Workflows
Located: `/home/claudecode/claudecode-system/workflows/`

- **Daily workflows**: Daily standup, review processes
- **Weekly workflows**: Sprint planning, retrospectives
- **Emergency workflows**: Hotfix procedures, incident response
- **Templates**: Reusable workflow templates

### Agents (Planned)
Located: `/home/claudecode/claudecode-system/.claude/agents/`

Agent system is defined but agents not yet populated. Directory structure:
- `core/` - Workflow orchestration agents
- `feature/` - Domain-specific feature agents
- `design/` - Design and UX agents
- `quality/` - Testing, QA, and performance agents
- `infrastructure/` - Deployment and system agents

## Configuration

### Settings Hierarchy
1. **Upstream base**: `/home/claudecode/claudecode-system/config/claude.settings.json`
2. **Project override**: `.claude/settings.local.json` (this file extends upstream)

### Path Configuration
```json
{
  "allowedCommandPaths": [
    ".claude/commands/",
    "/home/claudecode/claudecode-system/.claude/commands/"
  ],
  "allowedSkillPaths": [
    ".claude/skills/",
    "/home/claudecode/claudecode-system/.claude/skills/"
  ],
  "allowedAgentPaths": [
    ".claude/agents/",
    "/home/claudecode/claudecode-system/.claude/agents/"
  ]
}
```

### Search Paths
```json
{
  "skills": {
    "search_paths": [
      "$CLAUDE_SYSTEM_HOME/.claude/skills",
      "$PWD/.claude/skills"
    ]
  },
  "workflows": {
    "search_paths": [
      "$CLAUDE_SYSTEM_HOME/workflows",
      "$PWD/.claude/workflows"
    ]
  }
}
```

## Usage Examples

### Using Upstream Slash Commands
```bash
# In Claude Code session
/help                    # View all commands and skills
/test-edge-cases         # Generate test cases
/build-ui                # Create UI components
/orchestrate             # Multi-agent orchestration
```

### Using Upstream Skills
```bash
# Via natural language
"Run the noise-eliminator skill to clean up dead code"
"Use the documentation-master skill to update docs"

# Via explicit call
"Execute the knowledge-graph skill"
```

### Using Command-Line Tools
```bash
# System status
cs status

# Memory operations
memory-search --topic "directus extensions"
memory-store --pattern "collection patterns"

# Session analytics
session-analyze --last
```

## Project-Specific Overrides

This project also has its own commands and skills:

### Local Commands
Located: `.claude/commands/`
- `/core:work` - Start working session
- `/core:done` - Finish task + PR
- `/core:status` - Project dashboard
- `/core:sync` - GitHub sync
- `/core:check` - Fast validation
- Additional commands in `core/`, `quality/`, `advanced/`, `utils/`

### Local Skills
Located: `.claude/skills/`
- `directus-*` - Directus-specific development skills
- Project-specific extension patterns

## Priority Order

When there's a conflict, Claude Code searches in this order:
1. **Local project** (`.claude/commands/`, `.claude/skills/`)
2. **Upstream system** (`/home/claudecode/claudecode-system/.claude/`)

This allows project-specific overrides while inheriting upstream defaults.

## Maintenance

### Updating Upstream
```bash
cd /home/claudecode/claudecode-system
git pull
```

### Adding Project-Specific Commands
```bash
# Add to local .claude/commands/
echo "---" > .claude/commands/my-command.md
echo "description: My command" >> .claude/commands/my-command.md
echo "---" >> .claude/commands/my-command.md
```

### Checking Available Resources
```bash
# List all commands
ls .claude/commands/
ls /home/claudecode/claudecode-system/.claude/commands/

# List all skills
ls .claude/skills/
ls /home/claudecode/claudecode-system/.claude/skills/

# Check system status
cs status
```

## Troubleshooting

### Commands Not Found
1. Verify settings: `cat .claude/settings.local.json`
2. Check permissions: `"Read(/home/claudecode/claudecode-system/.claude/**)"` must be in allow list
3. Verify paths exist: `ls /home/claudecode/claudecode-system/.claude/commands/`

### Skills Not Loading
1. Check search paths in settings
2. Verify CLAUDE_SYSTEM_HOME env var: `echo $CLAUDE_SYSTEM_HOME`
3. Test skill directly: `cs skill [name]`

### PATH Issues
Add to shell profile (`~/.bashrc` or `~/.zshrc`):
```bash
export PATH="/home/claudecode/claudecode-system/bin:$PATH"
export CLAUDE_SYSTEM_HOME="/home/claudecode/claudecode-system"
```

## Documentation

- **Upstream System**: `/home/claudecode/claudecode-system/CLAUDE.md`
- **Master Structure**: `/home/claudecode/claudecode-system/docs/MASTER_STRUCTURE.md`
- **Skills System**: `/home/claudecode/claudecode-system/skills/*/SKILL.md`
- **Workflows**: `/home/claudecode/claudecode-system/workflows/README.md`
- **Local Commands**: `.claude/commands/README.md`

---

**Integration Complete** ✅
Upstream commands, skills, and workflows are now accessible in this project.
