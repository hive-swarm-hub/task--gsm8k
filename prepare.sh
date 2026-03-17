#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading GSM8K..."
python3 -c "
from datasets import load_dataset
import json, pathlib, random

random.seed(42)

train = list(load_dataset('openai/gsm8k', 'main', split='train'))
random.shuffle(train)
dev_out = pathlib.Path('data/dev.jsonl')
with dev_out.open('w') as f:
    for row in train[:150]:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({'question': row['question'], 'answer': final}) + '
')

test = list(load_dataset('openai/gsm8k', 'main', split='test'))
random.shuffle(test)
test_out = pathlib.Path('data/test.jsonl')
with test_out.open('w') as f:
    for row in test[:150]:
        final = row['answer'].split('####')[-1].strip().replace(',', '')
        f.write(json.dumps({'question': row['question'], 'answer': final}) + '
')

print(f'Dev:  150 problems -> {dev_out}')
print(f'Test: 150 problems -> {test_out}')
"
echo "Done."
