#!/usr/bin/env node
/**
 * Analytics Database Service
 * SQLite-based storage for workflow analytics
 * Simple, fast, ACID-compliant
 */

import Database from 'better-sqlite3';
import { join } from 'path';
import { existsSync } from 'fs';

const DB_PATH = join(process.cwd(), '.claude/analytics/analytics.db');

// Singleton database instance
let db = null;

/**
 * Get or create database instance
 */
export function getDatabase() {
  if (!db) {
    const isNew = !existsSync(DB_PATH);
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL'); // Better concurrent performance

    if (isNew) {
      initializeSchema();
    }
  }
  return db;
}

/**
 * Initialize database schema
 */
function initializeSchema() {
  const db = getDatabase();

  // Sessions table
  db.exec(`
    CREATE TABLE IF NOT EXISTS sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT UNIQUE NOT NULL,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      duration_hours REAL,
      tasks_completed INTEGER DEFAULT 0,
      commands_run INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_sessions_started ON sessions(started_at);
    CREATE INDEX IF NOT EXISTS idx_sessions_ended ON sessions(ended_at);
  `);

  // Tasks table
  db.exec(`
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      specialist TEXT,
      type TEXT,
      complexity TEXT,
      started_at TEXT,
      completed_at TEXT,
      duration_hours REAL,
      estimation_hours REAL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_tasks_specialist ON tasks(specialist);
    CREATE INDEX IF NOT EXISTS idx_tasks_type ON tasks(type);
    CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed_at);
  `);

  // Commands table
  db.exec(`
    CREATE TABLE IF NOT EXISTS commands (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      command TEXT NOT NULL,
      status TEXT DEFAULT 'success',
      executed_at TEXT NOT NULL,
      session_id TEXT,
      model TEXT,
      thinking_budget INTEGER,
      duration_ms INTEGER,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_commands_command ON commands(command);
    CREATE INDEX IF NOT EXISTS idx_commands_executed ON commands(executed_at);
    CREATE INDEX IF NOT EXISTS idx_commands_model ON commands(model);
  `);

  // Errors table
  db.exec(`
    CREATE TABLE IF NOT EXISTS errors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TEXT NOT NULL,
      command TEXT,
      source TEXT,
      message TEXT NOT NULL,
      error_code INTEGER,
      severity TEXT DEFAULT 'error',
      pattern_key TEXT,
      context TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_errors_timestamp ON errors(timestamp);
    CREATE INDEX IF NOT EXISTS idx_errors_pattern ON errors(pattern_key);
    CREATE INDEX IF NOT EXISTS idx_errors_severity ON errors(severity);
  `);

  // Workflow state table (single row)
  db.exec(`
    CREATE TABLE IF NOT EXISTS workflow_state (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      last_updated TEXT NOT NULL,
      session_active INTEGER DEFAULT 0,
      session_id TEXT,
      session_start TEXT,
      active_task INTEGER,
      active_branch TEXT,
      task_started_at TEXT,
      uncommitted_changes INTEGER DEFAULT 0,
      last_command TEXT,
      last_command_status TEXT,
      sprint_progress REAL DEFAULT 0,
      velocity_trend TEXT,
      last_project_pull TEXT,
      kanban_synced INTEGER DEFAULT 0,
      last_task_completed INTEGER,
      last_task_completed_at TEXT,
      last_retro_date TEXT,
      last_retro_sprint TEXT
    );

    -- Initialize single row
    INSERT OR IGNORE INTO workflow_state (id, last_updated)
    VALUES (1, datetime('now'));
  `);

  // Metadata table
  db.exec(`
    CREATE TABLE IF NOT EXISTS metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    INSERT OR IGNORE INTO metadata (key, value) VALUES
      ('schema_version', '1'),
      ('created_at', datetime('now')),
      ('total_sessions', '0'),
      ('session_streak', '0'),
      ('last_session_date', NULL);
  `);

  // Pattern usage table
  db.exec(`
    CREATE TABLE IF NOT EXISTS pattern_usage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pattern_name TEXT NOT NULL,
      task_id INTEGER,
      session_id TEXT,
      time_saved_hours REAL,
      confidence REAL,
      source TEXT,
      used_at TEXT DEFAULT CURRENT_TIMESTAMP,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );

    CREATE INDEX IF NOT EXISTS idx_pattern_name ON pattern_usage(pattern_name);
    CREATE INDEX IF NOT EXISTS idx_used_at ON pattern_usage(used_at);
    CREATE INDEX IF NOT EXISTS idx_task_id ON pattern_usage(task_id);
    CREATE INDEX IF NOT EXISTS idx_session_id ON pattern_usage(session_id);
  `);

  console.log('✅ Database schema initialized');
}

/**
 * Session operations
 */
export const SessionDB = {
  start(sessionId) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO sessions (session_id, started_at)
      VALUES (?, datetime('now'))
    `);

    const result = stmt.run(sessionId);

    // Update metadata
    db.prepare(`
      UPDATE metadata
      SET value = CAST((CAST(value AS INTEGER) + 1) AS TEXT),
          updated_at = datetime('now')
      WHERE key = 'total_sessions'
    `).run();

    return result.lastInsertRowid;
  },

  end(sessionId) {
    const db = getDatabase();
    const stmt = db.prepare(`
      UPDATE sessions
      SET ended_at = datetime('now'),
          duration_hours = ROUND(
            (julianday(datetime('now')) - julianday(started_at)) * 24,
            2
          )
      WHERE session_id = ? AND ended_at IS NULL
    `);

    return stmt.run(sessionId);
  },

  get(sessionId) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM sessions WHERE session_id = ?').get(sessionId);
  },

  getLast() {
    const db = getDatabase();
    return db.prepare('SELECT * FROM sessions ORDER BY id DESC LIMIT 1').get();
  },

  getAll(limit = 50) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM sessions ORDER BY started_at DESC LIMIT ?').all(limit);
  },

  updateStreak(streak, date) {
    const db = getDatabase();
    db.prepare(`UPDATE metadata SET value = ?, updated_at = datetime('now') WHERE key = 'session_streak'`).run(streak.toString());
    db.prepare(`UPDATE metadata SET value = ?, updated_at = datetime('now') WHERE key = 'last_session_date'`).run(date);
  },

  getMetadata() {
    const db = getDatabase();
    const rows = db.prepare('SELECT key, value FROM metadata').all();
    return Object.fromEntries(rows.map(r => [r.key, r.value]));
  }
};

/**
 * Task operations
 */
export const TaskDB = {
  create(task) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO tasks (task_id, specialist, type, complexity, started_at, estimation_hours)
      VALUES (?, ?, ?, ?, datetime('now'), ?)
    `);

    return stmt.run(
      task.task_id,
      task.specialist || null,
      task.type || null,
      task.complexity || null,
      task.estimation_hours || null
    );
  },

  complete(taskId, duration) {
    const db = getDatabase();
    const stmt = db.prepare(`
      UPDATE tasks
      SET completed_at = datetime('now'),
          duration_hours = ?
      WHERE task_id = ? AND completed_at IS NULL
    `);

    return stmt.run(duration, taskId);
  },

  get(taskId) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM tasks WHERE task_id = ?').get(taskId);
  },

  getAll(limit = 100) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM tasks ORDER BY created_at DESC LIMIT ?').all(limit);
  },

  getBySpecialist(specialist) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM tasks WHERE specialist = ? ORDER BY completed_at DESC').all(specialist);
  },

  getStats() {
    const db = getDatabase();
    return {
      total: db.prepare('SELECT COUNT(*) as count FROM tasks').get().count,
      completed: db.prepare('SELECT COUNT(*) as count FROM tasks WHERE completed_at IS NOT NULL').get().count,
      avgDuration: db.prepare('SELECT AVG(duration_hours) as avg FROM tasks WHERE duration_hours IS NOT NULL').get().avg,
      bySpecialist: db.prepare(`
        SELECT specialist, COUNT(*) as count, AVG(duration_hours) as avg_duration
        FROM tasks
        WHERE specialist IS NOT NULL
        GROUP BY specialist
        ORDER BY count DESC
      `).all(),
      byType: db.prepare(`
        SELECT type, COUNT(*) as count, AVG(duration_hours) as avg_duration
        FROM tasks
        WHERE type IS NOT NULL
        GROUP BY type
        ORDER BY count DESC
      `).all()
    };
  }
};

/**
 * Command operations
 */
export const CommandDB = {
  log(command, status = 'success', sessionId = null, metadata = {}) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO commands (command, status, executed_at, session_id, model, thinking_budget, duration_ms)
      VALUES (?, ?, datetime('now'), ?, ?, ?, ?)
    `);

    return stmt.run(
      command,
      status,
      sessionId,
      metadata.model || null,
      metadata.thinking_budget || null,
      metadata.duration_ms || null
    );
  },

  getStats() {
    const db = getDatabase();
    return {
      total: db.prepare('SELECT COUNT(*) as count FROM commands').get().count,
      byCommand: db.prepare(`
        SELECT command, COUNT(*) as count
        FROM commands
        GROUP BY command
        ORDER BY count DESC
        LIMIT 20
      `).all(),
      byModel: db.prepare(`
        SELECT model, COUNT(*) as count, AVG(duration_ms) as avg_duration
        FROM commands
        WHERE model IS NOT NULL
        GROUP BY model
        ORDER BY count DESC
      `).all(),
      recent: db.prepare('SELECT * FROM commands ORDER BY executed_at DESC LIMIT 10').all()
    };
  }
};

/**
 * Error operations
 */
export const ErrorDB = {
  log(error) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO errors (timestamp, command, source, message, error_code, severity, pattern_key, context)
      VALUES (datetime('now'), ?, ?, ?, ?, ?, ?, ?)
    `);

    return stmt.run(
      error.command || null,
      error.source || null,
      error.message,
      error.error_code || null,
      error.severity || 'error',
      error.pattern_key || null,
      error.context ? JSON.stringify(error.context) : null
    );
  },

  getRecent(limit = 50) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM errors ORDER BY timestamp DESC LIMIT ?').all(limit);
  },

  getByPattern(patternKey) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM errors WHERE pattern_key = ? ORDER BY timestamp DESC').all(patternKey);
  },

  getStats() {
    const db = getDatabase();
    return {
      total: db.prepare('SELECT COUNT(*) as count FROM errors').get().count,
      bySeverity: db.prepare(`
        SELECT severity, COUNT(*) as count
        FROM errors
        GROUP BY severity
      `).all(),
      byPattern: db.prepare(`
        SELECT pattern_key, COUNT(*) as count
        FROM errors
        WHERE pattern_key IS NOT NULL
        GROUP BY pattern_key
        ORDER BY count DESC
        LIMIT 20
      `).all()
    };
  }
};

/**
 * Workflow state operations
 */
export const StateDB = {
  get() {
    const db = getDatabase();
    const state = db.prepare('SELECT * FROM workflow_state WHERE id = 1').get();

    // Convert integers to booleans
    return {
      ...state,
      session_active: Boolean(state.session_active),
      uncommitted_changes: Boolean(state.uncommitted_changes),
      kanban_synced: Boolean(state.kanban_synced)
    };
  },

  update(fields) {
    const db = getDatabase();

    // Convert booleans to integers
    const sanitized = { ...fields };
    if ('session_active' in sanitized) sanitized.session_active = sanitized.session_active ? 1 : 0;
    if ('uncommitted_changes' in sanitized) sanitized.uncommitted_changes = sanitized.uncommitted_changes ? 1 : 0;
    if ('kanban_synced' in sanitized) sanitized.kanban_synced = sanitized.kanban_synced ? 1 : 0;

    const keys = Object.keys(sanitized);
    const values = Object.values(sanitized);

    const setClause = keys.map(k => `${k} = ?`).join(', ');
    const stmt = db.prepare(`
      UPDATE workflow_state
      SET ${setClause}, last_updated = datetime('now')
      WHERE id = 1
    `);

    return stmt.run(...values);
  }
};

/**
 * Close database connection
 */
export function closeDatabase() {
  if (db) {
    db.close();
    db = null;
  }
}

/**
 * Metadata operations
 */
export const MetadataDB = {
  get(key) {
    const db = getDatabase();
    const row = db.prepare('SELECT value FROM metadata WHERE key = ?').get(key);
    return row ? row.value : null;
  },

  set(key, value) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO metadata (key, value, updated_at)
      VALUES (?, ?, datetime('now'))
      ON CONFLICT(key) DO UPDATE SET
        value = excluded.value,
        updated_at = datetime('now')
    `);
    return stmt.run(key, value.toString());
  },

  getAll() {
    const db = getDatabase();
    const rows = db.prepare('SELECT key, value FROM metadata').all();
    return Object.fromEntries(rows.map(r => [r.key, r.value]));
  }
};

/**
 * Pattern usage operations
 * Track pattern extraction and usage for ROI calculation
 */
export const PatternDB = {
  /**
   * Log pattern extraction or usage
   */
  logUsage(data) {
    const db = getDatabase();
    const stmt = db.prepare(`
      INSERT INTO pattern_usage (
        pattern_name, task_id, session_id, time_saved_hours, confidence, source, used_at
      )
      VALUES (?, ?, ?, ?, ?, ?, datetime('now'))
    `);

    return stmt.run(
      data.pattern_name,
      data.task_id || null,
      data.session_id || null,
      data.time_saved_hours || null,
      data.confidence || null,
      data.source || null
    );
  },

  /**
   * Get ROI statistics for pattern system
   */
  getROI() {
    const db = getDatabase();

    const totalSaved = db.prepare(`
      SELECT
        COALESCE(SUM(time_saved_hours), 0) as total_hours_saved,
        COUNT(*) as total_uses,
        AVG(confidence) as avg_confidence
      FROM pattern_usage
      WHERE time_saved_hours IS NOT NULL
    `).get();

    const byPattern = db.prepare(`
      SELECT
        pattern_name,
        COUNT(*) as use_count,
        COALESCE(SUM(time_saved_hours), 0) as hours_saved,
        AVG(confidence) as avg_confidence,
        MAX(used_at) as last_used
      FROM pattern_usage
      GROUP BY pattern_name
      ORDER BY hours_saved DESC
    `).all();

    const bySource = db.prepare(`
      SELECT
        source,
        COUNT(*) as use_count,
        COALESCE(SUM(time_saved_hours), 0) as hours_saved,
        AVG(confidence) as avg_confidence
      FROM pattern_usage
      WHERE source IS NOT NULL
      GROUP BY source
      ORDER BY hours_saved DESC
    `).all();

    return {
      total_hours_saved: totalSaved.total_hours_saved,
      total_uses: totalSaved.total_uses,
      avg_confidence: totalSaved.avg_confidence,
      by_pattern: byPattern,
      by_source: bySource
    };
  },

  getMostUsed(limit = 10) {
    const db = getDatabase();
    return db.prepare(`
      SELECT
        pattern_name,
        COUNT(*) as use_count,
        COALESCE(SUM(time_saved_hours), 0) as total_hours_saved,
        AVG(confidence) as avg_confidence,
        source,
        MAX(used_at) as last_used,
        MIN(created_at) as first_used
      FROM pattern_usage
      GROUP BY pattern_name
      ORDER BY use_count DESC
      LIMIT ?
    `).all(limit);
  },

  getStats() {
    const db = getDatabase();

    const totalPatterns = db.prepare(`
      SELECT COUNT(DISTINCT pattern_name) as count
      FROM pattern_usage
    `).get().count;

    const totalExtractions = db.prepare(`
      SELECT COUNT(*) as count
      FROM pattern_usage
    `).get().count;

    const totalTimeSaved = db.prepare(`
      SELECT COALESCE(SUM(time_saved_hours), 0) as total
      FROM pattern_usage
      WHERE time_saved_hours IS NOT NULL
    `).get().total;

    const avgConfidence = db.prepare(`
      SELECT AVG(confidence) as avg
      FROM pattern_usage
      WHERE confidence IS NOT NULL
    `).get().avg;

    const recentUsage = db.prepare(`
      SELECT
        pattern_name,
        source,
        time_saved_hours,
        used_at
      FROM pattern_usage
      ORDER BY used_at DESC
      LIMIT 10
    `).all();

    return {
      total_patterns: totalPatterns,
      total_extractions: totalExtractions,
      total_time_saved_hours: totalTimeSaved,
      avg_confidence: avgConfidence,
      recent_usage: recentUsage
    };
  }
};

/**
 * Default export
 */
export default {
  getDatabase,
  SessionDB,
  TaskDB,
  CommandDB,
  ErrorDB,
  StateDB,
  PatternDB,
  MetadataDB,
  closeDatabase
};
