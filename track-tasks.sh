#!/usr/bin/env bash

# DirectApp Task Tracker
# A simple CLI tool to track implementation tasks and enforce validation
#
# Requirements:
# - jq (JSON processor)
# - bash 4.0+
#
# Usage: ./track-tasks.sh <command> [args]

set -euo pipefail

# Configuration
TRACKER_FILE="task-tracker.json"
BACKUP_DIR=".task-backups"
LOG_FILE="task-tracker.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Utility functions
log() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR:${NC} $*" >&2 | tee -a "$LOG_FILE"
    exit 1
}

success() {
    echo -e "${GREEN}✓${NC} $*" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

# Check dependencies
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed. Install it with: sudo apt install jq"
    fi
}

# Ensure tracker file exists
ensure_tracker_exists() {
    if [[ ! -f "$TRACKER_FILE" ]]; then
        error "Tracker file not found. Run './track-tasks.sh init' first."
    fi
}

# Create backup
backup_tracker() {
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/tracker-$(date +'%Y%m%d-%H%M%S').json"
    cp "$TRACKER_FILE" "$backup_file"
    log "Backup created: $backup_file"
}

# Initialize tracker from segmentation
cmd_init() {
    if [[ -f "$TRACKER_FILE" ]]; then
        read -p "Tracker file exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Initialization cancelled"
            return 0
        fi
        backup_tracker
    fi

    log "Initializing task tracker from segmentation..."

    # Check if segmentation file exists
    if [[ ! -f "PHASE_SEGMENTATION_COMPLETE.json" ]]; then
        error "PHASE_SEGMENTATION_COMPLETE.json not found"
    fi

    # Create initial tracker structure
    jq -n \
        --slurpfile seg PHASE_SEGMENTATION_COMPLETE.json \
        '{
            metadata: {
                project: "DirectApp Implementation",
                created: (now | strftime("%Y-%m-%d")),
                last_updated: (now | strftime("%Y-%m-%d")),
                version: "1.0"
            },
            phases: [],
            blockers: [],
            metrics: {
                total_tasks: 0,
                completed: 0,
                in_progress: 0,
                pending: 0,
                completion_percentage: 0
            }
        }' > "$TRACKER_FILE"

    # Extract Phase 1 tasks from segmentation
    local phase1_tasks=$(jq -r '
        .phase_breakdown[0].improvements[] |
        .atomic_tasks[] |
        {
            task_id: .task_id,
            improvement_id: .improvement_id,
            title: .title,
            description: .description,
            status: "pending",
            assigned_to: .assigned_to,
            priority: .priority,
            estimated_effort: .estimated_effort,
            actual_effort: null,
            started_at: null,
            completed_at: null,
            entry_criteria: .entry_criteria,
            exit_criteria: .exit_criteria,
            validation_checklist: .validation_checklist,
            dependencies: .dependencies,
            blocks: .blocks,
            rollback_plan: .rollback_plan,
            entry_criteria_validated: false,
            exit_criteria_validated: false,
            tests_passed: false,
            validation_report: null
        }
    ' PHASE_SEGMENTATION_COMPLETE.json | jq -s '.')

    # Add Phase 1 to tracker
    jq --argjson tasks "$phase1_tasks" \
        '.phases += [{
            phase_id: "phase-1",
            phase_name: "Phase 1: Critical Fixes & Quick Wins",
            status: "pending",
            start_date: null,
            target_end_date: "2025-11-15",
            actual_end_date: null,
            tasks: $tasks
        }]' "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    # Update metrics
    update_metrics

    success "Task tracker initialized with Phase 1 tasks"
    cmd_status
}

# Update metrics
update_metrics() {
    ensure_tracker_exists

    local total=$(jq '[.phases[].tasks[]] | length' "$TRACKER_FILE")
    local completed=$(jq '[.phases[].tasks[] | select(.status == "completed")] | length' "$TRACKER_FILE")
    local in_progress=$(jq '[.phases[].tasks[] | select(.status == "in_progress")] | length' "$TRACKER_FILE")
    local pending=$(jq '[.phases[].tasks[] | select(.status == "pending")] | length' "$TRACKER_FILE")
    local percentage=0

    if [[ $total -gt 0 ]]; then
        percentage=$(awk "BEGIN {printf \"%.1f\", ($completed / $total) * 100}")
    fi

    jq --argjson total "$total" \
       --argjson completed "$completed" \
       --argjson in_progress "$in_progress" \
       --argjson pending "$pending" \
       --argjson percentage "$percentage" \
       '.metrics = {
           total_tasks: $total,
           completed: $completed,
           in_progress: $in_progress,
           pending: $pending,
           completion_percentage: $percentage
       } | .metadata.last_updated = (now | strftime("%Y-%m-%d"))' \
       "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
}

# List tasks
cmd_list() {
    ensure_tracker_exists

    local phase_filter="${1:-}"
    local status_filter="${2:-}"
    local assignee_filter="${3:-}"

    local jq_filter='.phases[].tasks[]'

    if [[ -n "$phase_filter" ]]; then
        jq_filter=".phases[] | select(.phase_id == \"phase-$phase_filter\") | .tasks[]"
    fi

    if [[ -n "$status_filter" ]]; then
        jq_filter="$jq_filter | select(.status == \"$status_filter\")"
    fi

    if [[ -n "$assignee_filter" ]]; then
        jq_filter="$jq_filter | select(.assigned_to | contains(\"$assignee_filter\"))"
    fi

    echo -e "\n${BOLD}Task List${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    jq -r "$jq_filter |
        \"\\(.task_id) | \\(.status | ascii_upcase) | \\(.priority | ascii_upcase) | \\(.title) | \\(.assigned_to)\"" \
        "$TRACKER_FILE" | while IFS='|' read -r task_id status priority title assignee; do

        local color="$NC"
        case "$status" in
            *COMPLETED*) color="$GREEN" ;;
            *IN_PROGRESS*) color="$YELLOW" ;;
            *PENDING*) color="$CYAN" ;;
        esac

        printf "${BOLD}%-15s${NC} ${color}%-12s${NC} %-10s %-50s %-15s\n" \
            "$task_id" "$status" "$priority" "$title" "$assignee"
    done

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Show task details
cmd_show() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh show <task_id>"
    fi

    local task=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\")" "$TRACKER_FILE")

    if [[ -z "$task" ]]; then
        error "Task not found: $task_id"
    fi

    echo -e "\n${BOLD}Task Details: $task_id${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "$task" | jq -r '
        "Title:           \(.title)",
        "Status:          \(.status | ascii_upcase)",
        "Priority:        \(.priority | ascii_upcase)",
        "Assigned To:     \(.assigned_to)",
        "Estimated:       \(.estimated_effort)",
        "Actual:          \(.actual_effort // "N/A")",
        "",
        "Description:",
        "  \(.description)",
        "",
        "Dependencies:    \(.dependencies | join(", ") // "None")",
        "Blocks:          \(.blocks | join(", ") // "None")",
        "",
        "Entry Criteria: (\(.entry_criteria | length) items)",
        (.entry_criteria[] | "  • \(.)"),
        "",
        "Exit Criteria: (\(.exit_criteria | length) items)",
        (.exit_criteria[] | "  • \(.)"),
        "",
        "Validation Checklist: (\(.validation_checklist | length) items)",
        (.validation_checklist[] | "  • \(.)")
    '

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Validate entry criteria
cmd_validate_entry() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh validate-entry <task_id>"
    fi

    local task=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\")" "$TRACKER_FILE")

    if [[ -z "$task" ]]; then
        error "Task not found: $task_id"
    fi

    echo -e "\n${BOLD}Entry Criteria Validation: $task_id${NC}\n"

    local all_valid=true
    local criteria_count=$(echo "$task" | jq -r '.entry_criteria | length')

    for i in $(seq 0 $((criteria_count - 1))); do
        local criterion=$(echo "$task" | jq -r ".entry_criteria[$i]")
        echo -e "${BOLD}[$((i + 1))/${criteria_count}]${NC} $criterion"

        read -p "  Validated? (y/n): " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            all_valid=false
            warning "  Criterion not met!"
        else
            success "  Criterion validated"
        fi
    done

    if $all_valid; then
        success "\nAll entry criteria validated! Task can be started."
        return 0
    else
        error "\nNot all entry criteria met. Cannot start task."
    fi
}

# Validate exit criteria
cmd_validate_exit() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh validate-exit <task_id>"
    fi

    local task=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\")" "$TRACKER_FILE")

    if [[ -z "$task" ]]; then
        error "Task not found: $task_id"
    fi

    echo -e "\n${BOLD}Exit Criteria Validation: $task_id${NC}\n"

    local all_valid=true
    local criteria_count=$(echo "$task" | jq -r '.exit_criteria | length')

    for i in $(seq 0 $((criteria_count - 1))); do
        local criterion=$(echo "$task" | jq -r ".exit_criteria[$i]")
        echo -e "${BOLD}[$((i + 1))/${criteria_count}]${NC} $criterion"

        read -p "  Validated? (y/n): " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            all_valid=false
            warning "  Criterion not met!"
        else
            success "  Criterion validated"
        fi
    done

    if $all_valid; then
        success "\nAll exit criteria validated!"
        return 0
    else
        error "\nNot all exit criteria met. Cannot complete task."
    fi
}

# Check dependencies
check_dependencies_met() {
    local task_id="$1"

    local deps=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .dependencies[]?" "$TRACKER_FILE")

    if [[ -z "$deps" ]]; then
        return 0  # No dependencies
    fi

    local all_complete=true
    while IFS= read -r dep; do
        local dep_status=$(jq -r ".phases[].tasks[] | select(.task_id == \"$dep\") | .status" "$TRACKER_FILE")

        if [[ "$dep_status" != "completed" ]]; then
            warning "Dependency not met: $dep (status: $dep_status)"
            all_complete=false
        fi
    done <<< "$deps"

    if $all_complete; then
        return 0
    else
        return 1
    fi
}

# Start task
cmd_start() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh start <task_id>"
    fi

    backup_tracker

    log "Starting task: $task_id"

    # Check if task exists
    local task_exists=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .task_id" "$TRACKER_FILE")
    if [[ -z "$task_exists" ]]; then
        error "Task not found: $task_id"
    fi

    # Check current status
    local current_status=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .status" "$TRACKER_FILE")
    if [[ "$current_status" == "completed" ]]; then
        error "Task already completed: $task_id"
    elif [[ "$current_status" == "in_progress" ]]; then
        error "Task already in progress: $task_id"
    fi

    # Check dependencies
    if ! check_dependencies_met "$task_id"; then
        error "Dependencies not met for task: $task_id"
    fi

    # Validate entry criteria
    echo ""
    if ! cmd_validate_entry "$task_id"; then
        return 1
    fi

    # Update task status
    jq --arg task_id "$task_id" \
       --arg timestamp "$(date -Iseconds)" \
       '(.phases[].tasks[] | select(.task_id == $task_id)) |=
        (.status = "in_progress" |
         .started_at = $timestamp |
         .entry_criteria_validated = true)' \
       "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    update_metrics

    success "\nTask started: $task_id"
    info "Started at: $(date)"

    # Show next available tasks
    echo ""
    info "Next available tasks:"
    local next_tasks=$(jq -r ".phases[].tasks[] |
        select(.status == \"pending\" and
               ([.dependencies[]] | all(. as \$dep | any(.phases[].tasks[]; .task_id == \$dep and .status == \"completed\")))) |
        .task_id" "$TRACKER_FILE" || echo "")

    if [[ -n "$next_tasks" ]]; then
        echo "$next_tasks" | head -3
    else
        info "No other tasks available"
    fi
}

# Complete task
cmd_complete() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh complete <task_id>"
    fi

    backup_tracker

    log "Completing task: $task_id"

    # Check if task exists and is in progress
    local current_status=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .status" "$TRACKER_FILE")
    if [[ -z "$current_status" ]]; then
        error "Task not found: $task_id"
    elif [[ "$current_status" != "in_progress" ]]; then
        error "Task not in progress: $task_id (current status: $current_status)"
    fi

    # Validate exit criteria
    echo ""
    if ! cmd_validate_exit "$task_id"; then
        return 1
    fi

    # Calculate actual effort
    local started_at=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .started_at" "$TRACKER_FILE")
    local estimated=$(jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .estimated_effort" "$TRACKER_FILE")

    echo ""
    read -p "Actual effort (e.g., 2h, 30m) [$estimated]: " actual_effort
    actual_effort="${actual_effort:-$estimated}"

    # Update task status
    jq --arg task_id "$task_id" \
       --arg timestamp "$(date -Iseconds)" \
       --arg actual_effort "$actual_effort" \
       '(.phases[].tasks[] | select(.task_id == $task_id)) |=
        (.status = "completed" |
         .completed_at = $timestamp |
         .actual_effort = $actual_effort |
         .exit_criteria_validated = true |
         .tests_passed = true)' \
       "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    update_metrics

    success "\nTask completed: $task_id"
    info "Completed at: $(date)"
    info "Actual effort: $actual_effort (estimated: $estimated)"

    # Show unblocked tasks
    local unblocked=$(jq -r --arg task_id "$task_id" \
        ".phases[].tasks[] | select(.dependencies[] == \$task_id and .status == \"pending\") | .task_id" \
        "$TRACKER_FILE" || echo "")

    if [[ -n "$unblocked" ]]; then
        echo ""
        success "Tasks now available:"
        echo "$unblocked"
    fi
}

# Rollback task
cmd_rollback() {
    ensure_tracker_exists

    local task_id="${1:-}"
    if [[ -z "$task_id" ]]; then
        error "Usage: ./track-tasks.sh rollback <task_id>"
    fi

    backup_tracker

    log "Rolling back task: $task_id"

    # Show rollback plan
    echo -e "\n${BOLD}Rollback Plan:${NC}"
    jq -r ".phases[].tasks[] | select(.task_id == \"$task_id\") | .rollback_plan |
        \"Type: \\(.type)\nTime: \\(.time_to_rollback)\n\nSteps:\n\" +
        (.steps | to_entries | map(\"  \\(.key + 1). \\(.value)\") | join(\"\n\"))" \
        "$TRACKER_FILE"

    echo ""
    read -p "Proceed with rollback? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Rollback cancelled"
        return 0
    fi

    # Reset task to pending
    jq --arg task_id "$task_id" \
       '(.phases[].tasks[] | select(.task_id == $task_id)) |=
        (.status = "pending" |
         .started_at = null |
         .completed_at = null |
         .actual_effort = null |
         .entry_criteria_validated = false |
         .exit_criteria_validated = false |
         .tests_passed = false)' \
       "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    update_metrics

    success "Task rolled back: $task_id"
}

# Show status
cmd_status() {
    ensure_tracker_exists

    local metrics=$(jq -r '.metrics' "$TRACKER_FILE")
    local phase=$(jq -r '.phases[0]' "$TRACKER_FILE")

    echo -e "\n${BOLD}DirectApp Implementation Status${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "$metrics" | jq -r '
        "Total Tasks:     \(.total_tasks)",
        "Completed:       \(.completed) (\(.completion_percentage)%)",
        "In Progress:     \(.in_progress)",
        "Pending:         \(.pending)"
    '

    echo ""
    echo "$phase" | jq -r '
        "Current Phase:   \(.phase_name)",
        "Status:          \(.status | ascii_upcase)",
        "Target End:      \(.target_end_date)"
    '

    echo -e "\n${BOLD}Progress Bar:${NC}"
    local percentage=$(echo "$metrics" | jq -r '.completion_percentage')
    local filled=$(awk "BEGIN {printf \"%.0f\", $percentage / 2}")
    local empty=$((50 - filled))

    printf "["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %.1f%%\n" "$percentage"

    # Next tasks
    echo -e "\n${BOLD}Next Available Tasks:${NC}"
    jq -r '.phases[].tasks[] |
        select(.status == "pending") |
        "\(.task_id): \(.title) (\(.assigned_to))"' \
        "$TRACKER_FILE" | head -5

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Show blockers
cmd_blockers() {
    ensure_tracker_exists

    echo -e "\n${BOLD}Blocking Dependencies${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local blockers_output=""

    blockers_output=$(jq -r '.phases[].tasks[] | select(.status == "pending") |
        {task_id: .task_id, title: .title, dependencies: .dependencies}' \
        "$TRACKER_FILE" | jq -s '.' | jq -r '.[] |
        .task_id as $tid |
        .title as $title |
        .dependencies[] as $dep |
        "\($tid)|\($title)|\($dep)"' | while IFS='|' read -r task_id title dep; do

        local dep_status=$(jq -r ".phases[].tasks[] | select(.task_id == \"$dep\") | .status" "$TRACKER_FILE")

        if [[ "$dep_status" != "completed" ]]; then
            echo -e "${RED}✗${NC} $task_id: ${BOLD}$title${NC}"
            echo -e "  Blocked by: $dep (status: $dep_status)"
        fi
    done)

    if [[ -z "$blockers_output" ]]; then
        success "No blocking dependencies!"
    else
        echo "$blockers_output"
    fi

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Phase report
cmd_phase_report() {
    ensure_tracker_exists

    local phase_num="${1:-1}"
    local phase=$(jq -r ".phases[] | select(.phase_id == \"phase-$phase_num\")" "$TRACKER_FILE")

    if [[ -z "$phase" ]]; then
        error "Phase not found: phase-$phase_num"
    fi

    echo -e "\n${BOLD}Phase $phase_num Report${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "$phase" | jq -r '
        "Name:            \(.phase_name)",
        "Status:          \(.status | ascii_upcase)",
        "Target End:      \(.target_end_date)",
        ""
    '

    local total=$(echo "$phase" | jq '[.tasks[]] | length')
    local completed=$(echo "$phase" | jq '[.tasks[] | select(.status == "completed")] | length')
    local in_progress=$(echo "$phase" | jq '[.tasks[] | select(.status == "in_progress")] | length')
    local pending=$(echo "$phase" | jq '[.tasks[] | select(.status == "pending")] | length')

    echo "Total Tasks:     $total"
    echo "Completed:       $completed"
    echo "In Progress:     $in_progress"
    echo "Pending:         $pending"

    local percentage=0
    if [[ $total -gt 0 ]]; then
        percentage=$(awk "BEGIN {printf \"%.1f\", ($completed / $total) * 100}")
    fi
    echo "Progress:        $percentage%"

    echo -e "\n${BOLD}Tasks by Status:${NC}"
    echo "$phase" | jq -r '.tasks[] |
        "\(.status | ascii_upcase): \(.task_id) - \(.title)"' | sort

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Show metrics
cmd_metrics() {
    ensure_tracker_exists
    cmd_status
}

# Show help
cmd_help() {
    cat << EOF

${BOLD}DirectApp Task Tracker${NC}

${BOLD}USAGE:${NC}
    ./track-tasks.sh <command> [args]

${BOLD}COMMANDS:${NC}

  ${BOLD}Task Management:${NC}
    init                          Initialize tracker from segmentation
    list [--phase N] [--status S] [--assignee A]
                                  List tasks (filtered)
    show <task_id>                Show task details
    start <task_id>               Start a task (validates entry criteria)
    complete <task_id>            Complete a task (validates exit + tests)
    rollback <task_id>            Rollback a failed task

  ${BOLD}Validation:${NC}
    validate-entry <task_id>      Check entry criteria
    validate-exit <task_id>       Check exit criteria

  ${BOLD}Reporting:${NC}
    status                        Show daily status report
    blockers                      Show blocking dependencies
    phase-report <phase_num>      Show phase completion summary
    metrics                       Show overall project metrics

  ${BOLD}Other:${NC}
    help                          Show this help message

${BOLD}EXAMPLES:${NC}
    ./track-tasks.sh init
    ./track-tasks.sh list
    ./track-tasks.sh list --phase 1 --status pending
    ./track-tasks.sh show IMP-001-T1
    ./track-tasks.sh start IMP-001-T1
    ./track-tasks.sh complete IMP-001-T1
    ./track-tasks.sh status
    ./track-tasks.sh phase-report 1

${BOLD}FILES:${NC}
    $TRACKER_FILE         Main tracker data
    $BACKUP_DIR/          Automatic backups
    $LOG_FILE             Command log

EOF
}

# Main command dispatcher
main() {
    check_dependencies

    local command="${1:-help}"
    shift || true

    case "$command" in
        init)           cmd_init "$@" ;;
        list)           cmd_list "$@" ;;
        show)           cmd_show "$@" ;;
        start)          cmd_start "$@" ;;
        complete)       cmd_complete "$@" ;;
        rollback)       cmd_rollback "$@" ;;
        validate-entry) cmd_validate_entry "$@" ;;
        validate-exit)  cmd_validate_exit "$@" ;;
        status)         cmd_status "$@" ;;
        blockers)       cmd_blockers "$@" ;;
        phase-report)   cmd_phase_report "$@" ;;
        metrics)        cmd_metrics "$@" ;;
        help|--help|-h) cmd_help ;;
        *)              error "Unknown command: $command. Run './track-tasks.sh help' for usage." ;;
    esac
}

main "$@"
