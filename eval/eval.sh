#!/usr/bin/env bash
# Evaluate agent.py on GSM8K.
#   bash eval/eval.sh          — dev set (for experimentation)
#   bash eval/eval.sh --test   — FULL test set (for submission)
#   bash eval/eval.sh --ids 0,3,5  — specific problem indices (for debugging)
set -euo pipefail

DATA="data/dev.jsonl"
IDS=""
for arg in "$@"; do
    case "$arg" in
        --test) DATA="data/test.jsonl" ;;
        --ids) shift; IDS="$1" ;;
        --ids=*) IDS="${arg#--ids=}" ;;
    esac
    shift 2>/dev/null || true
done

if [ ! -f "$DATA" ]; then
    echo "ERROR: $DATA not found. Run: bash prepare.sh" >&2
    exit 1
fi

# Filter by IDs if specified
if [ -n "$IDS" ]; then
    TMPDATA=$(mktemp)
    python3 -c "
import sys
ids = set(int(i) for i in '$IDS'.split(','))
with open('$DATA') as f:
    for i, line in enumerate(f):
        if i in ids:
            sys.stdout.write(line)
" > "$TMPDATA"
    DATA="$TMPDATA"
fi

TOTAL=$(wc -l < "$DATA")
CORRECT=0

echo "Evaluating $TOTAL problems from $DATA..." >&2

while IFS= read -r line; do
    question=$(echo "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)['question'])")
    expected=$(echo "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)['answer'])")

    got=$(echo "$question" | python3 agent.py 2>/dev/null || echo "ERROR")

    normalize() {
        echo "$1" | tr -d ',' | sed 's/\.0*$//' | xargs
    }

    got_norm=$(normalize "$got")
    exp_norm=$(normalize "$expected")

    if [ "$got_norm" = "$exp_norm" ]; then
        CORRECT=$((CORRECT + 1))
    fi

done < "$DATA"

ACCURACY=$(python3 -c "print(f'{$CORRECT / $TOTAL:.6f}')")

echo "---"
echo "accuracy:         $ACCURACY"
echo "correct:          $CORRECT"
echo "total:            $TOTAL"
