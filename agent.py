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

    response = client.chat.completions.create(
        model=os.environ.get("SOLVER_MODEL", "gpt-4.1-nano"),
        messages=[
            {"role": "system", "content": (
                "You are a math tutor. Solve the problem step by step.\n"
                "Show your work clearly, then on the final line write:\n"
                "#### <answer>\n"
                "where <answer> is ONLY the numeric answer (no units, no commas)."
            )},
            {"role": "user", "content": question},
        ],
        temperature=0,
        max_tokens=1024,
    )

    text = response.choices[0].message.content.strip()
    # try to extract answer after ####
    if "####" in text:
        answer = text.split("####")[-1].strip()
    else:
        answer = text.split("\n")[-1].strip()
    # extract just the number
    numbers = re.findall(r'-?\d+\.?\d*', answer)
    return numbers[-1] if numbers else answer


if __name__ == "__main__":
    question = sys.stdin.read().strip()
    print(solve(question))
