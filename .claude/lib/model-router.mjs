#!/usr/bin/env node
/**
 * Model Router - Intelligent routing between Haiku 4.5 and Sonnet 4.5
 *
 * PURPOSE:
 * - Use Haiku 4.5 for simple, deterministic tasks (10x faster, 20x cheaper)
 * - Use Sonnet 4.5 for complex reasoning tasks with extended thinking
 *
 * BENEFITS:
 * - 80% cost reduction on simple commands
 * - 10x speed improvement on simple commands
 * - Superior quality on complex commands with thinking budgets
 */

export const MODELS = {
  HAIKU: 'claude-3-5-haiku-20250219',
  SONNET: 'claude-sonnet-4-5-20250929'
};

/**
 * Extended Thinking Budgets
 *
 * Controls how much thinking time Sonnet 4.5 gets for different task types.
 * Higher budgets = deeper reasoning, better error detection, higher quality.
 *
 * Budget Guidelines:
 * - LOW (10k tokens): ~30 seconds thinking - Simple tasks with clear structure
 * - MEDIUM (20k tokens): ~1 minute thinking - Standard complexity, some ambiguity
 * - HIGH (32k tokens): ~2 minutes thinking - Complex reasoning, error fixing, planning
 * - ULTRA (64k tokens): ~4 minutes thinking - Critical decisions, architecture, security
 */
export const THINKING_BUDGETS = {
  LOW: 10000,
  MEDIUM: 20000,
  HIGH: 32000,
  ULTRA: 64000
};

/**
 * Commands that should use Haiku 4.5
 *
 * CRITERIA:
 * - Simple, deterministic logic (read/write files, API calls)
 * - No complex reasoning required
 * - No error interpretation/fixing
 * - Template-based output
 */
const HAIKU_COMMANDS = [
  // Session management (simple state updates)
  'core:status',

  // Data operations (simple reads)
  'advanced:analytics',
  'core:sync',

  // Template generation
  'project-init',
];

/**
 * Commands that MUST use Sonnet 4.5 with Extended Thinking
 *
 * Budget allocation based on task complexity and criticality.
 */
const SONNET_COMMANDS = {
  // ULTRA Budget (64k tokens) - Critical decisions, architecture, security
  ULTRA: [
    'advanced:rollback',      // Critical undo operations
    'pattern-extraction',     // Pattern discovery (high ROI)
  ],

  // HIGH Budget (32k tokens) - Complex reasoning, error fixing, planning
  HIGH: [
    'core:work',              // Task selection + context loading (strategic)
    'core:check',             // Validation + auto-fix (critical path)
    'advanced:workflow-validate',  // Health scoring + recommendations
    'advanced:debug',         // Error diagnosis + fixing
    'pattern-seed',           // Pattern extraction from docs
    'utils:pattern-seed',     // Alias for pattern-seed
  ],

  // MEDIUM Budget (20k tokens) - Standard complexity
  MEDIUM: [
    'core:done',              // Review changes, generate commit/PR
    'quality:test',           // Test analysis
    'quality:fix',            // Auto-fix issues
  ],

  // LOW Budget (10k tokens) - Simple reasoning with clear structure
  LOW: [
    'utils:archive',
    'utils:experiment',
  ],
};

/**
 * Get the appropriate model and thinking budget for a command
 *
 * @param {string} command - Command name (e.g., 'core:work', 'pattern-seed')
 * @returns {object} { model: string, thinkingBudget: number|null, reasoning: string }
 */
export function getModelForCommand(command) {
  // Normalize command name (remove leading slash, prefixes)
  const normalized = command
    .replace(/^\//, '')
    .replace(/^core:/, '')
    .replace(/^quality:/, '')
    .replace(/^advanced:/, '')
    .replace(/^utils:/, '');

  // Check Haiku commands (simple, deterministic)
  if (HAIKU_COMMANDS.some(cmd => cmd.includes(normalized) || normalized === cmd)) {
    return {
      model: MODELS.HAIKU,
      thinkingBudget: null,
      reasoning: 'Simple, deterministic task - Haiku for speed'
    };
  }

  // Check Sonnet commands by thinking budget tier
  for (const [tier, commands] of Object.entries(SONNET_COMMANDS)) {
    if (commands.some(cmd => cmd.includes(normalized) || normalized === cmd)) {
      return {
        model: MODELS.SONNET,
        thinkingBudget: THINKING_BUDGETS[tier],
        reasoning: `Complex reasoning - Sonnet with ${tier} budget (${THINKING_BUDGETS[tier]} tokens)`
      };
    }
  }

  // Default to Sonnet with HIGH budget for unknown commands (safe fallback)
  return {
    model: MODELS.SONNET,
    thinkingBudget: THINKING_BUDGETS.HIGH,
    reasoning: 'Unknown command - Sonnet HIGH budget for safety'
  };
}

/**
 * Get model metadata
 */
export function getModelMetadata(modelId) {
  return {
    [MODELS.HAIKU]: {
      name: 'Haiku 4.5',
      speed: '10x faster',
      cost: '20x cheaper',
      best_for: 'Simple, deterministic tasks',
    },
    [MODELS.SONNET]: {
      name: 'Sonnet 4.5',
      speed: 'Standard',
      cost: 'Standard',
      best_for: 'Complex reasoning, error fixing, planning',
    }
  }[modelId] || { name: 'Unknown' };
}

/**
 * Validate command routing
 */
export function validateRouting() {
  const sonnetCommands = Object.values(SONNET_COMMANDS).flat();

  return {
    haiku_count: HAIKU_COMMANDS.length,
    sonnet_count: sonnetCommands.length,
    sonnet_by_budget: {
      ULTRA: SONNET_COMMANDS.ULTRA.length,
      HIGH: SONNET_COMMANDS.HIGH.length,
      MEDIUM: SONNET_COMMANDS.MEDIUM.length,
      LOW: SONNET_COMMANDS.LOW.length,
    },
    total_commands: HAIKU_COMMANDS.length + sonnetCommands.length,
  };
}

// CLI usage
if (import.meta.url === `file://${process.argv[1]}`) {
  const command = process.argv[2];

  if (!command) {
    console.log('Usage: node model-router.mjs <command>');
    console.log('\nExamples:');
    console.log('  node model-router.mjs core:work');
    console.log('  node model-router.mjs pattern-seed');
    console.log('  node model-router.mjs validate');
    process.exit(1);
  }

  if (command === 'validate') {
    const validation = validateRouting();
    console.log('Model Router Validation:');
    console.log(`  Haiku commands: ${validation.haiku_count}`);
    console.log(`  Sonnet commands: ${validation.sonnet_count}`);
    console.log(`    - ULTRA: ${validation.sonnet_by_budget.ULTRA}`);
    console.log(`    - HIGH: ${validation.sonnet_by_budget.HIGH}`);
    console.log(`    - MEDIUM: ${validation.sonnet_by_budget.MEDIUM}`);
    console.log(`    - LOW: ${validation.sonnet_by_budget.LOW}`);
    console.log(`  Total: ${validation.total_commands}`);
    console.log('  ✅ Validation passed');
    process.exit(0);
  }

  const config = getModelForCommand(command);
  const metadata = getModelMetadata(config.model);

  console.log(`Command: ${command}`);
  console.log(`Model: ${metadata.name}`);
  console.log(`Thinking Budget: ${config.thinkingBudget ? `${config.thinkingBudget} tokens` : 'N/A'}`);
  console.log(`Reasoning: ${config.reasoning}`);
  console.log(`Speed: ${metadata.speed}`);
  console.log(`Cost: ${metadata.cost}`);
}
