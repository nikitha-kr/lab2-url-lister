#!/usr/bin/env python3
import sys, re

# Extract the value inside href="..."
HREF_RE = re.compile(r'href\s*=\s*"([^"]+)"', re.IGNORECASE)

for line in sys.stdin:
    for url in HREF_RE.findall(line):
        # Emit key<TAB>value (required by Hadoop Streaming)
        print(f"{url}\t1")
