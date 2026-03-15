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
            {"role": "system", "content": "Solve the math problem step by step. Show your work, then give the final answer on the last line as: #### <number>"},
            {"role": "user", "content": question},
        ],
        temperature=0,
        max_tokens=512,
    )

    answer = response.choices[0].message.content.strip()
    # extract answer after #### delimiter
    if "####" in answer:
        answer = answer.split("####")[-1].strip()
    # extract just the number
    numbers = re.findall(r'-?\d+[\d,]*\.?\d*', answer)
    if numbers:
        return numbers[-1].replace(",", "")
    return answer


if __name__ == "__main__":
    question = sys.stdin.read().strip()
    print(solve(question))
