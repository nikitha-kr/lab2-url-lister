#!/usr/bin/env python3
import sys

current_key = None
current_sum = 0

def flush(k, s):
    # Only output if the TOTAL is strictly greater than 5
    if k is not None and s > 5:
        print(f"{k}\t{s}")

for raw in sys.stdin:
    line = raw.rstrip("\n")
    if not line:
        continue
    try:
        k, v = line.split("\t", 1)
        v = int(v)
    except ValueError:
        continue

    if k == current_key:
        current_sum += v
    else:
        flush(current_key, current_sum)
        current_key, current_sum = k, v

flush(current_key, current_sum)
