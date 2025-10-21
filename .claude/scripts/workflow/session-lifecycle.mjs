#!/usr/bin/env node
/**
 * Session Lifecycle Orchestrator - Machine→Intelligence Pattern
 *
 * Handles ALL deterministic work BEFORE LLM sees it:
 * - Session logging and analytics
 * - Orphaned session detection and repair
 * - Git status checks
 * - Error monitoring dashboard
 * - Duration warnings
 * - Workflow state updates
 *
 * Usage: node session-lifecycle.mjs --phase=<start|end> [--json] [--duration=<hours>]
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const ANALYTICS_DIR = join(__dirname, '../../analytics');
const SESSION_FILE = join(ANALYTICS_DIR, 'session-history.json');
const ERROR_FILE = join(ANALYTICS_DIR, 'error-patterns.json');

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = {
    phase: null,
    json: false,
    duration: null
  };

  args.forEach(arg => {
    if (arg.startsWith('--phase=')) {
      parsed.phase = arg.split('=')[1];
    } else if (arg === '--json') {
      parsed.json = true;
    } else if (arg.startsWith('--duration=')) {
      parsed.duration = parseFloat(arg.split('=')[1]);
    }
  });

  return parsed;
}

/**
 * Get git status
 */
function getGitStatus() {
  try {
    const branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf-8' }).trim();
    const modified = execSync('git ls-files -m | wc -l', { encoding: 'utf-8' }).trim();
    const staged = execSync('git diff --cached --name-only | wc -l', { encoding: 'utf-8' }).trim();
    const untracked = execSync('git ls-files -o --exclude-standard | wc -l', { encoding: 'utf-8' }).trim();

    // Get recent commits
    const commits = execSync('git log --oneline -n 5', { encoding: 'utf-8' })
      .trim()
      .split('\n')
      .map(line => {
        const match = line.match(/^([a-f0-9]+)\s+(.+)$/);
        return match ? { hash: match[1], message: match[2] } : null;
      })
      .filter(c => c !== null);

    return {
      branch,
      modified: parseInt(modified),
      staged: parseInt(staged),
      untracked: parseInt(untracked),
      recent_commits: commits
    };
  } catch (error) {
    return {
      branch: 'unknown',
      modified: 0,
      staged: 0,
      untracked: 0,
      recent_commits: [],
      error: error.message
    };
  }
}

/**
 * Get project health info
 */
function getProjectHealth() {
  const health = {
    git: getGitStatus(),
    dependencies_installed: existsSync('node_modules'),
    env_exists: existsSync('.env')
  };

  return health;
}

/**
 * Get error monitoring stats
 */
function getErrorStats() {
  if (!existsSync(ERROR_FILE)) {
    return {
      hour_critical: 0,
      day_total: 0,
      top_command: 'none'
    };
  }

  try {
    const data = JSON.parse(readFileSync(ERROR_FILE, 'utf-8'));
    const now = Date.now();
    const oneHour = 60 * 60 * 1000;
    const oneDay = 24 * oneHour;

    const hourErrors = data.errors.filter(e => {
      const errorTime = new Date(e.timestamp).getTime();
      return (now - errorTime) < oneHour;
    });

    const dayErrors = data.errors.filter(e => {
      const errorTime = new Date(e.timestamp).getTime();
      return (now - errorTime) < oneDay;
    });

    const criticalHourErrors = hourErrors.filter(e => e.severity >= 75);

    // Find most frequent command
    const commandCounts = {};
    dayErrors.forEach(e => {
      commandCounts[e.command] = (commandCounts[e.command] || 0) + 1;
    });

    const topCommand = Object.entries(commandCounts)
      .sort((a, b) => b[1] - a[1])[0];

    return {
      hour_critical: criticalHourErrors.length,
      day_total: dayErrors.length,
      top_command: topCommand ? topCommand[0] : 'none',
      top_command_count: topCommand ? topCommand[1] : 0
    };
  } catch (error) {
    return {
      hour_critical: 0,
      day_total: 0,
      top_command: 'none',
      error: error.message
    };
  }
}

/**
 * Calculate session streak
 */
function calculateStreak(sessions) {
  if (sessions.length === 0) return 1;

  const today = new Date().toISOString().split('T')[0];
  let streak = 1;
  let currentDate = new Date(today);

  const sortedSessions = [...sessions]
    .filter(s => s.started_at)
    .sort((a, b) => new Date(b.started_at) - new Date(a.started_at));

  for (const session of sortedSessions) {
    const sessionDate = new Date(session.started_at).toISOString().split('T')[0];
    const sessionDateObj = new Date(sessionDate);

    const daysDiff = Math.floor((currentDate - sessionDateObj) / (1000 * 60 * 60 * 24));

    if (daysDiff === 0) {
      continue;
    } else if (daysDiff === 1) {
      streak++;
      currentDate = sessionDateObj;
    } else {
      break;
    }
  }

  return streak;
}

/**
 * Handle session start phase
 */
function handleSessionStart() {
  try {
    // Load or create session history
    let sessionData = { sessions: [] };
    if (existsSync(SESSION_FILE)) {
      sessionData = JSON.parse(readFileSync(SESSION_FILE, 'utf-8'));
    }

    // Check for orphaned sessions
    const orphanedSessions = sessionData.sessions.filter(s => !s.ended_at);
    const orphanCount = orphanedSessions.length;

    if (orphanCount > 0) {
      const now = new Date().toISOString();
      orphanedSessions.forEach(session => {
        session.ended_at = now;
        session.duration_hours = 0;
        session.orphaned = true;
      });
    }

    // Create new session
    const sessionId = `session_${Date.now()}`;
    const sessionNumber = sessionData.sessions.length + 1;

    const session = {
      id: sessionId,
      number: sessionNumber,
      started_at: new Date().toISOString(),
      ended_at: null,
      duration_hours: null,
      commands_run: 0,
      tasks_completed: 0
    };

    sessionData.sessions.push(session);
    writeFileSync(SESSION_FILE, JSON.stringify(sessionData, null, 2));

    // Get health and error info
    const health = getProjectHealth();
    const errors = getErrorStats();
    const streak = calculateStreak(sessionData.sessions);

    // Check last session for duration warnings
    const lastSession = sessionData.sessions
      .slice(0, -1)
      .reverse()
      .find(s => s.ended_at && s.duration_hours !== null);

    const warnings = [];
    if (orphanCount > 0) {
      warnings.push({
        type: 'orphaned_sessions',
        count: orphanCount,
        message: `Auto-closed ${orphanCount} orphaned session(s)`
      });
    }

    if (lastSession && lastSession.duration_hours >= 12) {
      warnings.push({
        type: 'marathon',
        duration: lastSession.duration_hours,
        date: lastSession.started_at.split('T')[0],
        message: 'Last session was marathon (>12h)',
        tip: 'Consider shorter sessions for better quality'
      });
    } else if (lastSession && lastSession.duration_hours >= 8) {
      warnings.push({
        type: 'long',
        duration: lastSession.duration_hours,
        date: lastSession.started_at.split('T')[0],
        message: 'Last session was long (>8h)',
        tip: 'Aim for 2-6 hour sessions for best productivity'
      });
    } else if (lastSession && lastSession.duration_hours < 0.1) {
      warnings.push({
        type: 'too_short',
        duration: lastSession.duration_hours,
        date: lastSession.started_at.split('T')[0],
        message: 'Last session was very short (<6min)',
        tip: 'May indicate orphaned session or testing'
      });
    }

    // Output JSON
    const output = {
      session: {
        id: sessionId,
        number: sessionNumber,
        streak: streak
      },
      health,
      errors,
      warnings
    };

    console.log(JSON.stringify(output, null, 2));
    return true;

  } catch (error) {
    console.error(JSON.stringify({ error: error.message, stack: error.stack }));
    return false;
  }
}

/**
 * Handle session end phase
 */
function handleSessionEnd(durationHours = null) {
  try {
    if (!existsSync(SESSION_FILE)) {
      throw new Error('No session history found');
    }

    const sessionData = JSON.parse(readFileSync(SESSION_FILE, 'utf-8'));

    // Find current session
    const currentSession = sessionData.sessions
      .slice()
      .reverse()
      .find(s => !s.ended_at);

    if (!currentSession) {
      throw new Error('No active session found');
    }

    // Calculate duration if not provided
    if (durationHours === null && currentSession.started_at) {
      const start = new Date(currentSession.started_at);
      const end = new Date();
      durationHours = (end - start) / (1000 * 60 * 60);
    }

    // Update session
    currentSession.ended_at = new Date().toISOString();
    currentSession.duration_hours = parseFloat(durationHours.toFixed(2));

    writeFileSync(SESSION_FILE, JSON.stringify(sessionData, null, 2));

    // Check for warnings
    let warning = null;
    if (durationHours >= 12) {
      warning = 'marathon';
    } else if (durationHours >= 8) {
      warning = 'long';
    } else if (durationHours < 0.1) {
      warning = 'too_short';
    }

    // Output JSON
    const output = {
      session: {
        id: currentSession.id,
        number: currentSession.number,
        duration: currentSession.duration_hours,
        commands_run: currentSession.commands_run || 0,
        tasks_completed: currentSession.tasks_completed || 0
      },
      warning
    };

    console.log(JSON.stringify(output, null, 2));
    return true;

  } catch (error) {
    console.error(JSON.stringify({ error: error.message, stack: error.stack }));
    return false;
  }
}

// Main
const args = parseArgs();

if (!args.phase) {
  console.error('Usage: session-lifecycle.mjs --phase=<start|end> [--json] [--duration=<hours>]');
  process.exit(1);
}

if (args.phase === 'start') {
  process.exit(handleSessionStart() ? 0 : 1);
} else if (args.phase === 'end') {
  process.exit(handleSessionEnd(args.duration) ? 0 : 1);
} else {
  console.error('Phase must be "start" or "end"');
  process.exit(1);
}
