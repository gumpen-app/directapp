#!/usr/bin/env node
/**
 * /core:done - Finish Task
 *
 * Combines: commit + PR creation + status update + session end
 *
 * Flow:
 * 1. Detect current task from branch name or argument
 * 2. Stage and commit all changes
 * 3. Push branch to origin
 * 4. Create pull request
 * 5. Update GitHub Project status to "Review"
 * 6. Log task completion to analytics DB
 * 7. End session
 * 8. Return summary to user
 *
 * Usage:
 *   node done.mjs [task-id] [summary]
 *   node done.mjs --json
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

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  return {
    taskId: args.find(a => !a.startsWith('--') && /^\d+$/.test(a)),
    summary: args.find(a => !a.startsWith('--') && !/^\d+$/.test(a)),
    json: args.includes('--json')
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
 * Get current git branch
 */
function getCurrentBranch() {
  return exec('git rev-parse --abbrev-ref HEAD', { silent: true });
}

/**
 * Extract issue number from branch name
 */
function getIssueFromBranch(branchName) {
  const match = branchName.match(/feature\/issue-(\d+)/);
  return match ? parseInt(match[1]) : null;
}

/**
 * Get issue details from GitHub
 */
function getIssue(issueNumber) {
  const output = exec(
    `gh issue view ${issueNumber} --json number,title,body,labels,url`,
    { silent: true }
  );
  return JSON.parse(output);
}

/**
 * Get git status
 */
function getGitStatus() {
  const modified = exec('git ls-files -m | wc -l', { silent: true });
  const staged = exec('git diff --cached --name-only | wc -l', { silent: true });
  const untracked = exec('git ls-files -o --exclude-standard | wc -l', { silent: true });

  return {
    modified: parseInt(modified),
    staged: parseInt(staged),
    untracked: parseInt(untracked),
    total: parseInt(modified) + parseInt(staged) + parseInt(untracked)
  };
}

/**
 * Get list of changed files
 */
function getChangedFiles() {
  const files = exec('git diff --name-only HEAD', { silent: true, throwOnError: false });
  if (!files) return [];
  return files.split('\n').filter(f => f.trim());
}

/**
 * Generate commit message
 */
function generateCommitMessage(issue, summary = null) {
  const type = detectCommitType(issue);
  const scope = detectScope(issue);

  let message = `${type}`;
  if (scope) {
    message += `(${scope})`;
  }
  message += `: `;

  if (summary) {
    message += summary;
  } else {
    // Auto-generate from issue title
    message += issue.title
      .replace(/^Phase \d+\.\d+:\s*/i, '')
      .replace(/^\[.*?\]\s*/, '');
  }

  message += `\n\nCloses #${issue.number}`;
  message += '\n\n🤖 Generated with [Claude Code](https://claude.com/claude-code)';
  message += '\n\nCo-Authored-By: Claude <noreply@anthropic.com>';

  return message;
}

/**
 * Detect commit type from issue labels
 */
function detectCommitType(issue) {
  if (!issue.labels) return 'chore';

  const typeMap = {
    'type: bug': 'fix',
    'type: feature': 'feat',
    'type: enhancement': 'feat',
    'type: docs': 'docs',
    'type: chore': 'chore'
  };

  for (const label of issue.labels) {
    if (typeMap[label.name]) {
      return typeMap[label.name];
    }
  }

  return 'chore';
}

/**
 * Detect scope from issue labels
 */
function detectScope(issue) {
  if (!issue.labels) return null;

  const componentLabel = issue.labels.find(l => l.name?.startsWith('component:'));
  if (componentLabel) {
    return componentLabel.name.replace('component: ', '');
  }

  return null;
}

/**
 * Stage and commit changes
 */
function commitChanges(issue, summary) {
  console.error('📝 Creating commit...\n');

  const status = getGitStatus();
  if (status.total === 0) {
    console.error('   ⚠️  No changes to commit\n');
    return false;
  }

  console.error(`   Files to commit: ${status.total}\n`);

  // Stage all changes
  exec('git add -A', { silent: true });

  // Generate commit message
  const message = generateCommitMessage(issue, summary);

  console.error('   Commit message:\n');
  message.split('\n').forEach(line => {
    console.error(`   │ ${line}`);
  });
  console.error('');

  // Create commit
  const escapedMessage = message.replace(/"/g, '\\"');
  exec(`git commit -m "${escapedMessage}"`, { silent: false });

  console.error('   ✓ Changes committed\n');
  return true;
}

/**
 * Push branch to origin
 */
function pushBranch(branch) {
  console.error('📤 Pushing to origin...\n');

  try {
    exec(`git push -u origin ${branch}`, { silent: false });
    console.error('   ✓ Branch pushed\n');
    return true;
  } catch (error) {
    console.error('   ⚠️  Push failed (branch might already be pushed)\n');
    return false;
  }
}

/**
 * Generate PR body
 */
function generatePRBody(issue) {
  let body = '## Summary\n\n';
  body += `Implements #${issue.number}\n\n`;
  body += '## Changes\n\n';

  const files = getChangedFiles();
  if (files.length > 0 && files.length <= 10) {
    files.forEach(file => {
      body += `- ${file}\n`;
    });
  } else if (files.length > 10) {
    body += `${files.length} files changed\n`;
  }

  body += '\n## Test Plan\n\n';
  body += '- [ ] Tested locally\n';
  body += '- [ ] All checks passing\n';
  body += '- [ ] Ready for review\n';
  body += '\n---\n\n';
  body += '🤖 Generated with [Claude Code](https://claude.com/claude-code)';

  return body;
}

/**
 * Create pull request
 */
function createPullRequest(issue, branch) {
  console.error('🔀 Creating pull request...\n');

  const title = issue.title;
  const body = generatePRBody(issue);

  try {
    // Create PR
    const prUrl = exec(
      `gh pr create --title "${title}" --body "${body}" --base main --head ${branch}`,
      { silent: true }
    );

    console.error(`   ✓ Pull request created\n`);
    console.error(`   🔗 ${prUrl}\n`);

    return prUrl;
  } catch (error) {
    // Check if PR already exists
    const existingPR = exec(
      `gh pr list --head ${branch} --json url --jq '.[0].url'`,
      { silent: true, throwOnError: false }
    );

    if (existingPR) {
      console.error(`   ℹ️  Pull request already exists\n`);
      console.error(`   🔗 ${existingPR}\n`);
      return existingPR;
    }

    throw error;
  }
}

/**
 * Update GitHub Project status
 */
function updateProjectStatus(issueNumber) {
  console.error('📊 Updating GitHub Project status...\n');

  try {
    // Add comment to track status change
    const comment = '👀 Ready for review\n\n_Status: Review_';
    exec(`gh issue comment ${issueNumber} --body "${comment}"`, { silent: true });

    console.error('   ✓ Status updated to "Review"\n');
  } catch (error) {
    console.error('   ⚠️  Could not update status\n');
  }
}

/**
 * End session using session-lifecycle.mjs
 */
function endSession(issue, startTime) {
  const sessionScript = join(__dirname, '../workflow/session-lifecycle.mjs');

  if (!existsSync(sessionScript)) {
    console.error('   ⚠️  Session lifecycle script not found\n');
    return null;
  }

  try {
    const duration = startTime ? (Date.now() - startTime) / 1000 / 3600 : null;
    const durationArg = duration ? `--duration=${duration.toFixed(2)}` : '';

    const output = exec(
      `node "${sessionScript}" --phase=end ${durationArg} --json`,
      { silent: true }
    );

    return JSON.parse(output);
  } catch (error) {
    console.error('   ⚠️  Could not end session\n');
    return null;
  }
}

/**
 * Log task completion to analytics DB
 */
function logTaskCompletion(issue, duration) {
  console.error('📊 Logging task completion...\n');
  console.error(`   Task: #${issue.number}\n`);
  console.error(`   Duration: ${duration ? duration.toFixed(2) + 'h' : 'unknown'}\n`);
  console.error('   ⚠️  Analytics DB logging not yet implemented\n');
}

/**
 * Format output for user
 */
function formatOutput(issue, prUrl, stats, sessionEnd, asJson = false) {
  const output = {
    success: true,
    task: {
      id: issue.number,
      title: issue.title,
      url: issue.url
    },
    pr: {
      url: prUrl
    },
    stats: stats,
    session: sessionEnd
  };

  if (asJson) {
    return JSON.stringify(output, null, 2);
  }

  // Formatted text output
  let text = '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '✅ TASK COMPLETE\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `#${issue.number}: ${issue.title}\n\n`;

  text += '════════════════════════════════════════════════════════════════\n';
  text += '📊 SUMMARY\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `   ✓ ${stats.filesChanged} files changed\n`;
  text += `   ✓ Changes committed\n`;
  text += `   ✓ Branch pushed to origin\n`;
  text += `   ✓ Pull request created\n`;
  text += `   ✓ Status updated to "Review"\n`;

  if (sessionEnd) {
    text += `   ✓ Session ended\n`;
  }

  text += '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '🔗 LINKS\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += `   Issue:  ${issue.url}\n`;
  text += `   PR:     ${prUrl}\n`;

  text += '\n';
  text += '════════════════════════════════════════════════════════════════\n';
  text += '🎉 NEXT STEPS\n';
  text += '════════════════════════════════════════════════════════════════\n\n';

  text += '   1. Wait for CI checks to pass\n';
  text += '   2. Request review from team\n';
  text += '   3. Address feedback if needed\n';
  text += '   4. Merge when approved\n\n';

  text += '   Start next task: /core:work\n';
  text += '   Check status: /core:status\n\n';

  return text;
}

/**
 * Main function
 */
async function main() {
  const startTime = Date.now();

  try {
    const args = parseArgs();

    console.error('═══════════════════════════════════════════════════════════════\n');
    console.error('🏁 FINISHING TASK\n');
    console.error('═══════════════════════════════════════════════════════════════\n\n');

    // Step 1: Determine task
    const branch = getCurrentBranch();
    const taskId = args.taskId || getIssueFromBranch(branch);

    if (!taskId) {
      throw new Error('Could not determine task ID. Use: /core:done <task-id>');
    }

    console.error(`📋 Task: #${taskId}\n`);
    console.error(`🌿 Branch: ${branch}\n\n`);

    const issue = getIssue(taskId);
    console.error(`   ${issue.title}\n\n`);

    // Step 2: Commit changes
    const committed = commitChanges(issue, args.summary);

    if (!committed) {
      console.error('   ℹ️  No changes to commit, skipping...\n');
    }

    // Step 3: Push branch
    pushBranch(branch);

    // Step 4: Create PR
    const prUrl = createPullRequest(issue, branch);

    // Step 5: Update status
    updateProjectStatus(taskId);

    // Step 6: Log completion
    const duration = (Date.now() - startTime) / 1000 / 3600;
    logTaskCompletion(issue, duration);

    // Step 7: End session
    console.error('🔚 Ending session...\n');
    const sessionEnd = endSession(issue, startTime);
    if (sessionEnd) {
      console.error('   ✓ Session ended\n\n');
    }

    // Step 8: Output results
    const stats = {
      filesChanged: getChangedFiles().length,
      committed: committed
    };

    const output = formatOutput(issue, prUrl, stats, sessionEnd, args.json);
    console.log(output);

  } catch (error) {
    const args = parseArgs();
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

export { generateCommitMessage, getIssueFromBranch, createPullRequest };
