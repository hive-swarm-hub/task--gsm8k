#!/usr/bin/env bash
# Download GSM8K dataset with dev/test split. Run once.
set -euo pipefail

mkdir -p data

echo "Downloading GSM8K..."
python3 -c "
from datasets import load_dataset
import json, pathlib

# Dev: 200 problems from train (for experimentation)
train = load_dataset('openai/gsm8k', 'main', split='train[:200]')
dev_out = pathlib.Path('data/dev.jsonl')
with dev_out.open('w') as f:
    for row in train:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({'question': row['question'], 'answer': final}) + '\n')

# Test: full test set (for submission — DO NOT use during experimentation)
test = load_dataset('openai/gsm8k', 'main', split='test')
test_out = pathlib.Path('data/test.jsonl')
with test_out.open('w') as f:
    for row in test:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({'question': row['question'], 'answer': final}) + '\n')

print(f'Dev:  {len(train)} problems -> {dev_out}')
print(f'Test: {len(test)} problems -> {test_out}')
"

echo "Done."
