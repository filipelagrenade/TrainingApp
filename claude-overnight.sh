#!/bin/bash
# claude-overnight.sh - Autonomous overnight Claude runner with handover
#
# Key design principles:
# 1. Each iteration is a FRESH Claude session (no --resume, context is via files)
# 2. Progress tracked by updating task.md checkboxes (Claude marks [x] as it completes)
# 3. Handover file captures context for next iteration
# 4. Git commits preserve code changes between iterations

set -e

CLAUDE_DIR=".claude"
TASK_FILE="$CLAUDE_DIR/task.md"
HANDOVER_FILE="$CLAUDE_DIR/handover.md"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$CLAUDE_DIR/overnight-$TIMESTAMP.log"
MAX_ITERATIONS=10
ITERATION_TIMEOUT=3600  # 1 hour max per iteration

# Ensure .claude directory exists
mkdir -p "$CLAUDE_DIR"

# Validate task file exists
if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: Task file not found at $TASK_FILE"
    echo "Create a task file with your instructions before running."
    exit 1
fi

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
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
            git add -A
            git commit -m "overnight: iteration $1 checkpoint

Auto-commit from claude-overnight.sh at $(date)" --no-verify 2>/dev/null || true
            log "Git checkpoint created for iteration $1"
        else
            log "No changes to commit for iteration $1"
        fi
    fi
}

print_summary() {
    log ""
    log "=========================================="
    log "OVERNIGHT RUN SUMMARY"
    log "=========================================="
    log "Started: $START_TIME"
    log "Ended:   $(date)"
    log "Iterations completed: $COMPLETED_ITERATIONS"
    log "Final status: $FINAL_STATUS"
    log ""
    if [ -f "$HANDOVER_FILE" ]; then
        log "Final handover:"
        log "------------------------------------------"
        cat "$HANDOVER_FILE" >> "$LOG_FILE"
    fi
    log "=========================================="
}

# Build the instruction block that gets appended to every prompt
read -r -d '' INSTRUCTIONS << 'INSTRUCTIONS_EOF' || true
## CRITICAL INSTRUCTIONS FOR AUTONOMOUS OPERATION

1. **Track Progress**: As you complete tasks, UPDATE the task.md file by changing `- [ ]` to `- [x]` for completed items. This is how progress persists between iterations.

2. **Git Commits**: After completing significant work, stage and commit your changes with descriptive messages. The script will also checkpoint, but your commits provide better granularity.

3. **Context Management**: Monitor your context usage. When it drops below 15%:
   - Write a handover file to .claude/handover.md
   - Include STATUS: CONTINUE (or STATUS: COMPLETE if all tasks done)
   - List what you completed, what's next, and any critical context
   - Say "HANDOVER_COMPLETE" and stop working

4. **Handover Format**:
```
STATUS: CONTINUE

## Completed This Session
- [List of accomplishments with file paths]

## Current State
- What's working
- What's broken/incomplete

## Next Steps
1. Immediate next action
2. Subsequent tasks

## Critical Context
- Important gotchas, file paths, decisions made
```

5. **Build Verification**: Before handover, run `cd backend && go build ./...` and `cd frontend && pnpm build` to verify no breakage.

6. **Stay Focused**: Work through tasks in order. Don't skip ahead. Complete one phase before starting the next.
INSTRUCTIONS_EOF

START_TIME=$(date)
COMPLETED_ITERATIONS=0
FINAL_STATUS="INCOMPLETE"

log "=========================================="
log "OVERNIGHT RUN STARTING"
log "=========================================="
log "Time: $START_TIME"
log "Task: $TASK_FILE"
log "Handover: $HANDOVER_FILE"
log "Max iterations: $MAX_ITERATIONS"
log "Timeout per iteration: ${ITERATION_TIMEOUT}s"
log "=========================================="
log ""

for i in $(seq 1 $MAX_ITERATIONS); do
    log "=== Iteration $i of $MAX_ITERATIONS started at $(date) ==="

    # Clear previous handover to detect if new one is written
    rm -f "$HANDOVER_FILE"

    # Build the prompt for this iteration
    if [ $i -eq 1 ]; then
        # First iteration: start fresh with task file
        PROMPT="$(cat "$TASK_FILE")

$INSTRUCTIONS"
    else
        # Subsequent iterations: read from backed up handover
        PREV_HANDOVER="$CLAUDE_DIR/handover-iter$((i-1))-$TIMESTAMP.md"
        if [ -f "$PREV_HANDOVER" ]; then
            PROMPT="Continue the work from the previous session.

## Previous Session Handover
$(cat "$PREV_HANDOVER")

## Full Task List (check boxes for completion status)
$(cat "$TASK_FILE")

$INSTRUCTIONS"
        else
            log "ERROR: Previous handover not found at $PREV_HANDOVER"
            FINAL_STATUS="ERROR - No handover from iteration $((i-1))"
            print_summary
            exit 1
        fi
    fi

    # Run Claude with the prompt
    # Write prompt to temp file to avoid "Argument list too long" error
    PROMPT_FILE="$CLAUDE_DIR/.prompt-iter$i.tmp"
    printf '%s' "$PROMPT" > "$PROMPT_FILE"

    log "Starting Claude session..."
    log "Prompt size: $(wc -c < "$PROMPT_FILE") bytes"

    # Use stdin redirection to pass the prompt (avoids command-line length limits)
    if timeout $ITERATION_TIMEOUT bash -c "cat '$PROMPT_FILE' | claude --dangerously-skip-permissions -p -" 2>&1 | tee -a "$LOG_FILE"; then
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

    # Git checkpoint BEFORE backing up handover (so handover reflects committed state)
    git_checkpoint $i

    # Backup handover after iteration
    backup_handover $i

    # Check for completion
    if [ -f "$HANDOVER_FILE" ]; then
        if grep -qi "STATUS:[[:space:]]*COMPLETE" "$HANDOVER_FILE" 2>/dev/null; then
            log ""
            log "=== Task marked COMPLETE at $(date)! ==="
            FINAL_STATUS="COMPLETE"
            print_summary
            exit 0
        else
            log "Handover written with STATUS: CONTINUE"
        fi
    else
        log "WARNING: No handover file written this iteration"
        # Create a minimal handover so next iteration can continue
        cat > "$HANDOVER_FILE" << EOF
STATUS: CONTINUE

## Note
Previous iteration did not write a handover. Check git log and task.md for progress.

## Next Steps
1. Review task.md for uncompleted items
2. Continue from where previous session left off
EOF
        # Backup with regular naming so next iteration finds it
        backup_handover $i
        log "Auto-generated fallback handover for iteration $i"
    fi

    log "Iteration $i complete. Waiting 10s before next iteration..."
    sleep 10
done

log ""
log "=== Hit max iterations ($MAX_ITERATIONS) at $(date) ==="
FINAL_STATUS="MAX_ITERATIONS_REACHED"
print_summary
