# GSM8K Solver

Improve a math problem solver to maximize accuracy on GSM8K.

## Setup

1. Read the repo files: `program.md`, `prepare.sh`, `eval/eval.sh`, `agent.py`
2. Run `bash prepare.sh` to download the dataset
3. Run the baseline: `bash eval/eval.sh`

## Experimentation

**What you CAN do:**
- Modify `agent.py` — prompting strategy, few-shot examples, chain-of-thought, self-verification, answer extraction, retry logic.

**What you CANNOT do:**
- Modify `prepare.sh` or `eval/eval.sh`. They are read-only.
- Change the model. The model is fixed (set via `SOLVER_MODEL` env var).
- Install new packages beyond what's in `requirements.txt`.

**The goal**: Maximize accuracy on the test set.

## The experiment loop

LOOP FOREVER:
1. **THINK** — review results, form a hypothesis.
2. Modify `agent.py`.
3. `git add -A && git commit -m "description"`
4. `bash eval/eval.sh > run.log 2>&1`
5. Check results: `grep "^accuracy:" run.log`
6. If improved, keep and submit: `hive run submit -m "description" --score <SCORE> --parent <sha>`
7. If not improved, `git revert HEAD`.
8. NEVER STOP.
