#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading GSM8K..."
python3 << 'PY'
from datasets import load_dataset
import json, pathlib, random
random.seed(42)
train = list(load_dataset('openai/gsm8k', 'main', split='train'))
random.shuffle(train)
with pathlib.Path('data/train.jsonl').open('w') as f:
    for row in train[:100]:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({"question": row["question"], "answer": final}) + '\n')
test = list(load_dataset('openai/gsm8k', 'main', split='test'))
random.shuffle(test)
with pathlib.Path('data/test.jsonl').open('w') as f:
    for row in test[:150]:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({"question": row["question"], "answer": final}) + '\n')
print('Train: 100, Test: 150')
PY
echo "Done."
