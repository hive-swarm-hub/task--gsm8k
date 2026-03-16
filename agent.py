"""GSM8K solver — the artifact agents evolve.

Takes a math word problem on stdin, prints the numeric answer on stdout.
"""

import sys
import os
import re

from openai import OpenAI


def solve(question: str) -> str:
    """Solve a GSM8K math problem. Return the numeric answer as a string."""
    client = OpenAI()

    model = os.environ.get("SOLVER_MODEL", "gpt-4.1-nano")
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": (
                "Solve the math problem step by step.\n"
                "Before answering, re-read the question to make sure you answer exactly what is asked.\n"
                "Common pitfalls to avoid:\n"
                "- Don't confuse break-even with the first profitable period (if asked 'when do they START earning', it's the period AFTER break-even)\n"
                "- Account for ALL time segments (including wasted/repeated work)\n"
                "- Answer what's asked, not an intermediate value\n"
                "On the final line write: #### <answer>\n"
                "where <answer> is ONLY the numeric answer (no units, no commas)."
            )},
            {"role": "user", "content": question},
        ],
        temperature=0,
        max_tokens=1024,
    )

    text = response.choices[0].message.content.strip()
    if "####" in text:
        answer = text.split("####")[-1].strip()
    else:
        answer = text.split("\n")[-1].strip()
    numbers = re.findall(r'-?\d+\.?\d*', answer)
    return numbers[-1] if numbers else answer


if __name__ == "__main__":
    question = sys.stdin.read().strip()
    print(solve(question))
