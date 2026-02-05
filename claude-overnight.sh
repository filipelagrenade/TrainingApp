#!/bin/bash
# claude-overnight.sh - Autonomous overnight Claude runner with handover
#
# Key design principles:
# 1. ONE PHASE PER ITERATION — keeps context fresh and quality high
# 2. Each iteration is a FRESH Claude session (no --resume, context is via files)
# 3. Progress tracked by updating task.md checkboxes (Claude marks [x] as it completes)
# 4. Handover file captures context for next iteration
# 5. Git commits preserve code changes between iterations
# 6. CLAUDE.md files are injected into every prompt for project context
#
# Usage:
#   ./claude-overnight.sh                    # Use defaults
#   ./claude-overnight.sh --max-iter 10      # Limit to 10 iterations
#   ./claude-overnight.sh --timeout 2700     # 45 min per iteration
#   ./claude-overnight.sh --model sonnet     # Use specific model

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

CLAUDE_DIR=".claude"
TASK_FILE="$CLAUDE_DIR/task.md"
HANDOVER_FILE="$CLAUDE_DIR/handover.md"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$CLAUDE_DIR/overnight-$TIMESTAMP.log"
MAX_ITERATIONS=20
ITERATION_TIMEOUT=2700  # 45 min per phase (shorter iterations = fresher context)
CLAUDE_MODEL=""         # Empty = use default
STALL_THRESHOLD=2       # Max consecutive iterations with no progress before aborting

# ─── Parse Arguments ─────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iter)   MAX_ITERATIONS="$2"; shift 2 ;;
        --timeout)    ITERATION_TIMEOUT="$2"; shift 2 ;;
        --model)      CLAUDE_MODEL="$2"; shift 2 ;;
        --task)       TASK_FILE="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --max-iter N     Maximum iterations (default: 20)"
            echo "  --timeout N      Seconds per iteration (default: 2700 = 45 min)"
            echo "  --model MODEL    Claude model to use (e.g., sonnet, opus)"
            echo "  --task FILE      Path to task file (default: .claude/task.md)"
            echo "  --help, -h       Show this help"
            echo ""
            echo "Note: Each iteration completes ONE phase, then hands over."
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ─── Setup ───────────────────────────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR"

if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: Task file not found at $TASK_FILE"
    echo "Create a task file with your instructions before running."
    exit 1
fi

# ─── Helper Functions ────────────────────────────────────────────────────────

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Collect all CLAUDE.md files in the project for context injection
collect_claude_md_files() {
    local claude_md_content=""
    local count=0
    while IFS= read -r -d '' file; do
        local relative_path="${file#./}"
        claude_md_content+="
--- BEGIN ${relative_path} ---
$(cat "$file")
--- END ${relative_path} ---
"
        count=$((count + 1))
    done < <(find . -name "CLAUDE.md" -not -path "./.git/*" -not -path "./node_modules/*" -print0 2>/dev/null | sort -z)

    log "Found $count CLAUDE.md file(s)"
    echo "$claude_md_content"
}

# Get current task progress counts
get_task_progress() {
    local checked unchecked
    checked=$(grep -c '\- \[x\]' "$TASK_FILE" 2>/dev/null || echo "0")
    unchecked=$(grep -c '\- \[ \]' "$TASK_FILE" 2>/dev/null || echo "0")
    echo "$checked:$unchecked"
}

# Get the next unchecked phase name from task.md
get_next_phase() {
    # Look for pattern: - [ ] **Phase N** — Description
    grep -m1 '^\- \[ \] \*\*Phase' "$TASK_FILE" 2>/dev/null | sed 's/.*\*\*\(Phase [0-9]*\)\*\*.*/\1/' || echo ""
}

# Get total phase counts
get_phase_counts() {
    local completed remaining
    completed=$(grep -c '^\- \[x\] \*\*Phase' "$TASK_FILE" 2>/dev/null || echo "0")
    remaining=$(grep -c '^\- \[ \] \*\*Phase' "$TASK_FILE" 2>/dev/null || echo "0")
    echo "$completed:$remaining"
}

backup_handover() {
    if [ -f "$HANDOVER_FILE" ]; then
        cp "$HANDOVER_FILE" "$CLAUDE_DIR/handover-iter$1-$TIMESTAMP.md"
        log "Backed up handover to handover-iter$1-$TIMESTAMP.md"
    fi
}

git_checkpoint() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        if [ -n "$(git status --porcelain)" ]; then
            # Use .gitignore-aware staging (avoids Windows reserved names like nul)
            git add --all -- ':!nul' ':!NUL' 2>/dev/null || git add -A 2>/dev/null || true
            git commit -m "overnight: iteration $1 checkpoint

Auto-commit from claude-overnight.sh at $(date)" --no-verify 2>/dev/null || true
            log "Git checkpoint created for iteration $1"
        else
            log "No changes to commit for iteration $1"
        fi
    fi
}

print_summary() {
    local progress phase_counts
    progress=$(get_task_progress)
    phase_counts=$(get_phase_counts)
    local checked="${progress%%:*}"
    local unchecked="${progress##*:}"
    local phases_done="${phase_counts%%:*}"
    local phases_left="${phase_counts##*:}"

    log ""
    log "=========================================="
    log "OVERNIGHT RUN SUMMARY"
    log "=========================================="
    log "Started: $START_TIME"
    log "Ended:   $(date)"
    log "Iterations completed: $COMPLETED_ITERATIONS"
    log "Final status: $FINAL_STATUS"
    log "Phases completed: $phases_done"
    log "Phases remaining: $phases_left"
    log "Sub-tasks completed: $checked"
    log "Sub-tasks remaining: $unchecked"
    log ""
    if [ -f "$HANDOVER_FILE" ]; then
        log "Final handover:"
        log "------------------------------------------"
        cat "$HANDOVER_FILE" >> "$LOG_FILE"
    fi
    log "=========================================="
    log "Log file: $LOG_FILE"
}

# ─── Collect Project Context ─────────────────────────────────────────────────

log "Collecting CLAUDE.md files for context injection..."
CLAUDE_MD_CONTEXT="$(collect_claude_md_files)"
if [ -z "$CLAUDE_MD_CONTEXT" ]; then
    log "WARNING: No CLAUDE.md files found in project"
fi

# ─── Build Instructions Block ────────────────────────────────────────────────

read -r -d '' INSTRUCTIONS << 'INSTRUCTIONS_EOF' || true
## CRITICAL INSTRUCTIONS FOR AUTONOMOUS OPERATION

You are running in autonomous overnight mode with ONE PHASE PER ITERATION.

### 1. ONE PHASE ONLY
**CRITICAL: Complete exactly ONE phase per iteration, then write handover and stop.**
- Find the first unchecked `- [ ] **Phase N**` in task.md
- Complete ALL sub-tasks within that phase
- Mark the phase checkbox as done: `- [x] **Phase N**`
- Write handover file
- Say "HANDOVER_COMPLETE" and STOP — do not start the next phase

### 2. Read Project Context First
Before doing ANY work, read the CLAUDE.md files provided above. They contain:
- Project architecture and patterns
- Coding standards and conventions
- Build commands and tech stack
- Communication protocols

### 3. Track Progress RELIGIOUSLY
As you complete EACH sub-task within the phase:
- Change `- [ ]` to `- [x]` for EACH completed sub-task
- Do this IMMEDIATELY after completing each task
- This is the ONLY way progress persists between iterations

### 4. Git Commits
After completing the phase:
- Stage and commit with descriptive conventional commit message
- Use the commit message format specified in the task file if provided

### 5. Build Verification
Before handover, verify builds pass:
- If working on Flutter app: `cd app && flutter build web --release`
- If working on backend: `cd backend && npm run build`
- Fix any build errors before proceeding

### 6. Handover Process (MANDATORY)
After completing ONE phase:
1. Mark the phase checkbox as `[x]` in task.md
2. Write handover to `.claude/handover.md`:

```
STATUS: CONTINUE

## Phase Completed
- Phase N: [phase name]
- All sub-tasks: [X/X completed]

## What Was Done
- [Specific change with file path]
- [Another change with file path]

## Build Status
- Flutter: [passing/failing]
- Backend: [passing/failing if modified]

## Files Modified
| File | Change |
|------|--------|
| path/to/file | What was changed |

## Next Phase
- Phase N+1: [phase name from task.md]
- First sub-task: [what to do first]

## Critical Context
- [Any gotchas or decisions the next iteration must know]
```

3. Say "HANDOVER_COMPLETE" and STOP

### 7. If All Phases Are Complete
When the last phase is done:
1. Run final build verification
2. Write handover with `STATUS: COMPLETE`
3. Say "HANDOVER_COMPLETE"

### 8. Stay Focused
- Do NOT start the next phase — stop after completing one
- Do not refactor or "improve" code outside the current phase
- If you encounter a bug, note it but don't fix unless it blocks your phase
INSTRUCTIONS_EOF

# ─── Build Claude Command ────────────────────────────────────────────────────

build_claude_cmd() {
    local cmd="claude --dangerously-skip-permissions -p -"
    if [ -n "$CLAUDE_MODEL" ]; then
        cmd="claude --dangerously-skip-permissions --model $CLAUDE_MODEL -p -"
    fi
    echo "$cmd"
}

# ─── Main Loop ───────────────────────────────────────────────────────────────

START_TIME=$(date)
COMPLETED_ITERATIONS=0
FINAL_STATUS="INCOMPLETE"
CONSECUTIVE_STALLS=0

log "=========================================="
log "OVERNIGHT RUN STARTING (One Phase Per Iteration)"
log "=========================================="
log "Time: $START_TIME"
log "Task: $TASK_FILE"
log "Handover: $HANDOVER_FILE"
log "Max iterations: $MAX_ITERATIONS"
log "Timeout per iteration: ${ITERATION_TIMEOUT}s ($(( ITERATION_TIMEOUT / 60 )) min)"
log "Model: ${CLAUDE_MODEL:-default}"
log "=========================================="

# Log initial progress
INITIAL_PROGRESS=$(get_task_progress)
INITIAL_PHASES=$(get_phase_counts)
log "Initial progress: ${INITIAL_PHASES%%:*} phases done, ${INITIAL_PHASES##*:} remaining"
log "Sub-tasks: ${INITIAL_PROGRESS%%:*} done, ${INITIAL_PROGRESS##*:} remaining"
log ""

CLAUDE_CMD=$(build_claude_cmd)

for i in $(seq 1 $MAX_ITERATIONS); do
    # Check if there are any phases left
    NEXT_PHASE=$(get_next_phase)
    if [ -z "$NEXT_PHASE" ]; then
        log "=== All phases complete! ==="
        FINAL_STATUS="COMPLETE"
        print_summary
        exit 0
    fi

    log "=== Iteration $i: $NEXT_PHASE ==="
    log "Started at $(date)"

    # Snapshot progress before this iteration
    BEFORE_PROGRESS=$(get_task_progress)
    BEFORE_PHASES=$(get_phase_counts)

    # Clear previous handover to detect if new one is written
    rm -f "$HANDOVER_FILE"

    # Build the prompt for this iteration
    PREV_HANDOVER="$CLAUDE_DIR/handover-iter$((i-1))-$TIMESTAMP.md"

    if [ $i -eq 1 ] || [ ! -f "$PREV_HANDOVER" ]; then
        # First iteration or no handover: use task file directly
        if [ $i -gt 1 ]; then
            log "WARNING: No handover from previous iteration, using recovery mode"
        fi
        RECENT_LOG=$(git log --oneline -10 2>/dev/null || echo "No git history available")

        PROMPT="# Autonomous Overnight Run — Iteration $i

## Target: Complete $NEXT_PHASE ONLY
**Complete this single phase, then write handover and stop.**

## Project Context (CLAUDE.md Files)
$CLAUDE_MD_CONTEXT

## Recent Git History
$RECENT_LOG

## Full Task List
$(cat "$TASK_FILE")

$INSTRUCTIONS

---
BEGIN WORK NOW.
1. Find $NEXT_PHASE in the task list above
2. Complete ALL sub-tasks within that phase
3. Mark sub-tasks as [x] as you complete them
4. When phase is done, mark the phase as [x]
5. Write handover to .claude/handover.md
6. Say HANDOVER_COMPLETE and stop

DO NOT start the next phase. Complete only $NEXT_PHASE."
    else
        # Subsequent iteration with handover
        PROMPT="# Autonomous Overnight Run — Iteration $i

## Target: Complete $NEXT_PHASE ONLY
**Complete this single phase, then write handover and stop.**

## Project Context (CLAUDE.md Files)
$CLAUDE_MD_CONTEXT

## Previous Session Handover
$(cat "$PREV_HANDOVER")

## Full Task List
$(cat "$TASK_FILE")

$INSTRUCTIONS

---
BEGIN WORK NOW.
1. Review the handover above for context
2. Find $NEXT_PHASE in the task list
3. Complete ALL sub-tasks within that phase
4. Mark sub-tasks as [x] as you complete them
5. When phase is done, mark the phase as [x]
6. Write handover to .claude/handover.md
7. Say HANDOVER_COMPLETE and stop

DO NOT start the next phase. Complete only $NEXT_PHASE."
    fi

    # Write prompt to temp file
    PROMPT_FILE="$CLAUDE_DIR/.prompt-iter$i.tmp"
    printf '%s' "$PROMPT" > "$PROMPT_FILE"

    log "Starting Claude session for $NEXT_PHASE..."
    log "Prompt size: $(wc -c < "$PROMPT_FILE") bytes"

    # Run Claude
    if timeout "$ITERATION_TIMEOUT" bash -c "cat '$PROMPT_FILE' | $CLAUDE_CMD" 2>&1 | tee -a "$LOG_FILE"; then
        log "Claude session completed normally"
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            log "WARNING: Claude session timed out after ${ITERATION_TIMEOUT}s"
        else
            log "WARNING: Claude exited with code $EXIT_CODE"
        fi
    fi

    # Clean up temp prompt file
    rm -f "$PROMPT_FILE"

    COMPLETED_ITERATIONS=$i

    # Git checkpoint
    git_checkpoint "$i"

    # Backup handover
    backup_handover "$i"

    # ─── Progress Check ─────────────────────────────────────────────────
    AFTER_PROGRESS=$(get_task_progress)
    AFTER_PHASES=$(get_phase_counts)

    PHASES_BEFORE="${BEFORE_PHASES%%:*}"
    PHASES_AFTER="${AFTER_PHASES%%:*}"

    if [ "$PHASES_AFTER" -gt "$PHASES_BEFORE" ]; then
        log "✓ Phase completed! ($PHASES_BEFORE → $PHASES_AFTER phases done)"
        CONSECUTIVE_STALLS=0
    elif [ "$BEFORE_PROGRESS" != "$AFTER_PROGRESS" ]; then
        log "⚠ Progress made but phase not marked complete"
        CONSECUTIVE_STALLS=0
    else
        CONSECUTIVE_STALLS=$((CONSECUTIVE_STALLS + 1))
        log "WARNING: No progress detected (stall $CONSECUTIVE_STALLS/$STALL_THRESHOLD)"
        if [ "$CONSECUTIVE_STALLS" -ge "$STALL_THRESHOLD" ]; then
            log "ERROR: $STALL_THRESHOLD consecutive stalls — aborting"
            FINAL_STATUS="STALLED"
            print_summary
            exit 1
        fi
    fi

    log "Progress: ${AFTER_PHASES%%:*}/${INITIAL_PHASES##*:} phases, ${AFTER_PROGRESS%%:*} sub-tasks done"

    # ─── Completion Check ────────────────────────────────────────────────
    REMAINING_PHASES="${AFTER_PHASES##*:}"
    if [ "$REMAINING_PHASES" -eq 0 ]; then
        log ""
        log "=== ALL PHASES COMPLETE at $(date)! ==="
        FINAL_STATUS="COMPLETE"
        print_summary
        exit 0
    fi

    # Create recovery handover if none written
    if [ ! -f "$HANDOVER_FILE" ]; then
        log "WARNING: No handover file written, creating recovery handover"
        RECENT_LOG=$(git log --oneline -5 2>/dev/null || echo "No git history")
        cat > "$HANDOVER_FILE" << FALLBACK_EOF
STATUS: CONTINUE

## WARNING: Auto-Generated Recovery Handover
Iteration $i did not write a handover file.

## Recovery Context
### Recent Git Commits
$RECENT_LOG

## Next Steps
1. Find the first unchecked phase in .claude/task.md
2. Complete that phase only
3. Write a proper handover when done
FALLBACK_EOF
        backup_handover "$i"
    fi

    log "Iteration $i complete. Starting next iteration in 5s..."
    sleep 5
done

log ""
log "=== Hit max iterations ($MAX_ITERATIONS) ==="
FINAL_STATUS="MAX_ITERATIONS_REACHED"
print_summary
