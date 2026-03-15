"""GSM8K solver — the artifact agents evolve.

Takes a math word problem on stdin, prints the numeric answer on stdout.
"""

import sys
import os
import re

from openai import OpenAI


SYSTEM = """You are a math tutor. Solve the problem step by step.
After each step, write the intermediate result.
At the very end, write the final numeric answer after ####.

Example:
Q: Tom has 5 apples. He buys 3 more and gives away 2. How many does he have?
Step 1: Tom starts with 5 apples.
Step 2: He buys 3 more: 5 + 3 = 8.
Step 3: He gives away 2: 8 - 2 = 6.
#### 6"""


def solve(question: str) -> str:
    """Solve a GSM8K math problem. Return the numeric answer as a string."""
    client = OpenAI()

    response = client.chat.completions.create(
        model=os.environ.get("SOLVER_MODEL", "gpt-4.1-nano"),
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": question},
        ],
        temperature=0,
        max_tokens=1024,
    )

    text = response.choices[0].message.content.strip()
    if "####" in text:
        after = text.split("####")[-1].strip()
        numbers = re.findall(r'-?\d[\d,]*\.?\d*', after)
        if numbers:
            return numbers[0].replace(",", "")
    numbers = re.findall(r'-?\d[\d,]*\.?\d*', text)
    return numbers[-1].replace(",", "") if numbers else text


if __name__ == "__main__":
    question = sys.stdin.read().strip()
    print(solve(question))
