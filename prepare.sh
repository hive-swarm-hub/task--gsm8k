#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading GSM8K test set..."
python3 << 'PY'
from datasets import load_dataset
import json, pathlib
ds = load_dataset('openai/gsm8k', 'main', split='test')
out = pathlib.Path('data/test.jsonl')
with out.open('w') as f:
    for row in ds:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({"question": row["question"], "answer": final}) + '\n')
print(f'Wrote {len(ds)} problems to {out}')
PY
echo "Done."
