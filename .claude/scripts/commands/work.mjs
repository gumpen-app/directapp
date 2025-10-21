#!/usr/bin/env node
/**
 * /core:work - Start Working
 *
 * Combines: session-start + pick-task + branch creation
 *
 * Flow:
 * 1. Start session (via session-lifecycle.mjs)
 * 2. Query GitHub Project for next Ready task
 * 3. Sort by priority (Critical > High > Medium > Low)
 * 4. Update task status to "In Progress"
 * 5. Create feature branch
 * 6. Log task start to analytics DB
 * 7. Return task info to user
 *
 * Usage:
 *   node work.mjs [task-id]
 *   node work.mjs next
 *   node work.mjs --json
 */

import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuration
const PROJECT_NUMBER = 2;
const PROJECT_OWNER = 'gumpen-app';
const REPO = 'directapp';

// Priority mapping for sorting
const PRIORITY_VALUES = {
  '🔴 Critical': 4,
  'Critical': 4,
  '🟠 High': 3,
  'High': 3,
  '🟡 Medium': 2,
  'Medium': 2,
  '🟢 Low': 1,
  'Low': 1
};

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  return {
    taskId: args.find(a => !a.startsWith('--') && a !== 'next'),
    json: args.includes('--json'),
    next: args.includes('next') || args.length === 0
  };
}

/**
 * Execute command and return output
 */
function exec(command, options = {}) {
  try {
    return execSync(command, {
      encoding: 'utf-8',
      stdio: options.silent ? 'pipe' : 'inherit',
      ...options
    }).trim();
  } catch (error) {
    if (options.throwOnError !== false) {
      throw error;
    }
    return null;
  }
}

/**
 * Start session using session-lifecycle.mjs
 */
function startSession() {
  const sessionScript = join(__dirname, '../workflow/session-lifecycle.mjs');

  if (!existsSync(sessionScript)) {
    throw new Error(`Session lifecycle script not found: ${sessionScript}`);
  }

  const output = exec(`node "${sessionScript}" --phase=start --json`, { silent: true });
  return JSON.parse(output);
}

/**
 * Get current git branch
 */
function getCurrentBranch() {
  return exec('git rev-parse --abbrev-ref HEAD', { silent: true });
}

/**
 * Check if branch exists locally
 */
function branchExists(branchName) {
  const result = exec(`git rev-parse --verify ${branchName}`, {
    silent: true,
    throwOnError: false
  });
  return result !== null;
}

/**
 * Create slugified branch name from issue
 */
function createBranchName(issue) {
  const slug = issue.title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 50);

  return `feature/issue-${issue.number}-${slug}`;
}

/**
 * Query GitHub Project for items
 */
function getProjectItems() {
  const output = exec(
    `gh project item-list ${PROJECT_NUMBER} --owner ${PROJECT_OWNER} --format json --limit 100`,
    { silent: true }
  );

  const data = JSON.parse(output);
  return data.items || [];
}

/**
 * Get issue details
 */
function getIssue(issueNumber) {
  const output = exec(
    `gh issue view ${issueNumber} --json number,title,body,labels,assignees,url`,
    { silent: true }
  );

  return JSON.parse(output);
}

/**
 * Get custom field value from project item
 */
function getFieldValue(item, fieldName) {
  // GitHub Projects v2 API returns fields in various formats
  // Try to extract the field value
  if (item[fieldName]) {
    return item[fieldName];
  }

  // Check in custom fields
  if (item.fieldValues) {
    const field = item.fieldValues.find(f => f.field?.name === fieldName);
    return field?.value || field?.name || null;
  }

  return null;
}

/**
 * Extract priority from labels
 */
function getPriorityFromLabels(issue) {
  if (!issue.labels) return 'Medium';

  const priorityLabel = issue.labels.find(l =>
    l.name?.startsWith('priority:')
  );

  if (!priorityLabel) return 'Medium';

  const priority = priorityLabel.name.replace('priority: ', '');
  return priority.charAt(0).toUpperCase() + priority.slice(1);
}

/**
 * Get next Ready task from GitHub Project
 */
function getNextTask(specificTaskId = null) {
  console.error('🔍 Querying GitHub Project for tasks...\n');

  const items = getProjectItems();

  if (items.length === 0) {
    throw new Error('No items found in GitHub Project');
  }

  // If specific task ID requested
  if (specificTaskId) {
    const item = items.find(i => i.content?.number === parseInt(specificTaskId));
    if (!item) {
      throw new Error(`Task #${specificTaskId} not found in project`);
    }

    const issue = getIssue(specificTaskId);
    return {
      ...item,
      issue
    };
  }

  // Filter for Ready tasks (or tasks without status)
  // Note: Status field might not be configured yet, so we accept items without status
  const readyItems = items.filter(item => {
    const status = getFieldValue(item, 'Status') || getFieldValue(item, 'status');

    // Accept: no status, "Ready", "Todo", or similar
    if (!status) return true;
    if (status.toLowerCase().includes('ready')) return true;
    if (status.toLowerCase().includes('todo')) return true;
    if (status.toLowerCase().includes('backlog')) return true;

    return false;
  });

  if (readyItems.length === 0) {
    throw new Error('No Ready tasks found in GitHub Project. Move some tasks to "Ready" status.');
  }

  console.error(`   Found ${readyItems.length} Ready tasks\n`);

  // Get full issue details for each item
  const itemsWithIssues = readyItems.map(item => {
    const issue = getIssue(item.content.number);
    const priority = getPriorityFromLabels(issue);

    return {
      ...item,
      issue,
      priority,
      priorityValue: PRIORITY_VALUES[priority] || 1
    };
  });

  // Sort by priority (highest first)
  itemsWithIssues.sort((a, b) => b.priorityValue - a.priorityValue);

  console.error('📋 Ready Tasks (sorted by priority):\n');
  itemsWithIssues.slice(0, 5).forEach((item, idx) => {
    console.error(`   ${idx + 1}. #${item.issue.number}: ${item.issue.title}`);
    console.error(`      Priority: ${item.priority}\n`);
  });

  // Return highest priority task
  return itemsWithIssues[0];
}

/**
 * Update GitHub Project item status
 */
function updateTaskStatus(issueNumber, status) {
  console.error(`📝 Updating task #${issueNumber} status to "${status}"...\n`);

  // Note: Updating custom fields via gh CLI is complex
  // For now, we'll use GitHub API directly via gh api
  // This is a simplified version - full implementation would use GraphQL mutations

  try {
    // First, assign to current user if not already assigned
    const currentUser = exec('gh api user --jq .login', { silent: true });
    exec(`gh issue edit ${issueNumber} --add-assignee ${currentUser}`, { silent: true });

    console.error(`   ✓ Assigned to @${currentUser}\n`);
  } catch (error) {
    console.error(`   ⚠ Could not assign task (might already be assigned)\n`);
  }

  // TODO: Update Status field via GraphQL mutation
  // For now, we add a comment to track status
  const comment = `🏃 Started working on this task\n\n_Status: ${status}_`;
  try {
    exec(`gh issue comment ${issueNumber} --body "${comment}"`, { silent: true });
    console.error(`   ✓ Added status comment\n`);
  } catch (error) {
    console.error(`   ⚠ Could not add comment\n`);
  }
}

/**
 * Create and checkout feature branch
 */
function createFeatureBranch(task) {
  const branchName = createBranchName(task.issue);
  const currentBranch = getCurrentBranch();

  console.error(`🌿 Creating feature branch: ${branchName}\n`);

  // Check if branch already exists
  if (branchExists(branchName)) {
    console.error(`   ℹ Branch already exists, checking out...\n`);
    exec(`git checkout ${branchName}`, { silent: true });
    return branchName;
  }

  // Make sure we're on main/master first
  if (currentBranch !== 'main' && currentBranch !== 'master') {
    console.error(`   ⚠ Currently on ${currentBranch}, switching to main first...\n`);
    exec('git checkout main', { silent: true });
    exec('git pull origin main', { silent: true, throwOnError: false });
  }

  // Create and checkout new branch
  exec(`git checkout -b ${branchName}`, { silent: true });
  console.error(`   ✓ Branch created and checked out\n`);

  return branchName;
}

/**
 * Log task start to analytics DB
 */
function logTaskStart(task, sessionInfo) {
  // TODO: Implement analytics DB logging
  // For now, just log to console
  console.error(`📊 Logging task start to analytics DB...\n`);
  console.error(`   Session: ${sessionInfo.session.id}\n`);
  console.error(`   Task: #${task.issue.number}\n`);
  console.error(`   ⚠ Analytics DB logging not yet implemented\n`);
}

/**
 * Format output for user
 */
function formatOutput(task, branch, sessionInfo, asJson = false) {
  const output = {
    success: true,
    session: sessionInfo.session,
    task: {
      id: task.issue.number,
      title: task.issue.title,
      url: task.issue.url,
      priority: task.priority,
      labels: task.issue.labels.map(l => l.name),
      assignees: task.issue.assignees.map(a => a.login)
    },
    branch: branch,
    health: sessionInfo.health
  };

  if (asJson) {
    return JSON.stringify(output, null, 2);
  }

  // Formatted text output
  let text = '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '✨ SESSION STARTED\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `📊 Session #${sessionInfo.session.number}\n`;
  text += `🔥 Streak: ${sessionInfo.session.streak} day(s)\n`;
  text += `🆔 ID: ${sessionInfo.session.id}\n\n`;

  text += '════════════════════════════════════════════════════════════════\n';
  text += '✅ NEXT TASK\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `#${output.task.id}: ${output.task.title}\n\n`;
  text += `🔗 URL: ${output.task.url}\n`;
  text += `🏷️  Priority: ${output.task.priority}\n`;
  text += `🌿 Branch: ${branch}\n`;

  if (output.task.assignees.length > 0) {
    text += `👤 Assigned: @${output.task.assignees.join(', @')}\n`;
  }

  if (output.task.labels.length > 0) {
    text += `🏷️  Labels: ${output.task.labels.join(', ')}\n`;
  }

  text += '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '📊 HEALTH CHECK\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `   ${sessionInfo.health.git.modified > 0 ? '⚠️' : '✓'} Modified files: ${sessionInfo.health.git.modified}\n`;
  text += `   ${sessionInfo.health.git.untracked > 0 ? '⚠️' : '✓'} Untracked files: ${sessionInfo.health.git.untracked}\n`;
  text += `   ${sessionInfo.health.dependencies_installed ? '✓' : '❌'} Dependencies installed\n`;
  text += `   ${sessionInfo.health.env_exists ? '✓' : '❌'} Environment configured\n`;

  if (sessionInfo.errors.day_total > 0) {
    text += `\n   ⚠️  ${sessionInfo.errors.day_total} errors in last 24h\n`;
  }

  text += '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '🚀 READY TO START\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `When done: /core:done\n`;
  text += `Check status: /core:status\n`;
  text += `Validate code: /core:check\n\n`;

  return text;
}

/**
 * Main function
 */
async function main() {
  try {
    const args = parseArgs();

    // Step 1: Start session
    console.error('═══════════════════════════════════════════════════════════════\n');
    console.error('🚀 STARTING WORK SESSION\n');
    console.error('═══════════════════════════════════════════════════════════════\n\n');

    const sessionInfo = startSession();
    console.error(`✓ Session #${sessionInfo.session.number} started (ID: ${sessionInfo.session.id})\n`);
    console.error(`✓ Streak: ${sessionInfo.session.streak} day(s)\n\n`);

    // Step 2: Get next task
    const task = getNextTask(args.taskId);

    // Step 3: Update task status
    updateTaskStatus(task.issue.number, 'In Progress');

    // Step 4: Create feature branch
    const branch = createFeatureBranch(task);

    // Step 5: Log to analytics DB
    logTaskStart(task, sessionInfo);

    // Step 6: Output results
    const output = formatOutput(task, branch, sessionInfo, args.json);
    console.log(output);

  } catch (error) {
    console.error('\n❌ ERROR\n');
    console.error(`   ${error.message}\n`);

    if (args.json) {
      console.log(JSON.stringify({
        success: false,
        error: error.message
      }, null, 2));
    }

    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { getNextTask, createBranchName, startSession };
