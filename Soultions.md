# UrlCount — Output & Plain‑Language Explanation

**How it works:**
- We read the two Wikipedia pages line by line and pick the web addresses that appear inside `href="..."`.
- Every time we see the same address, we add one to its total.
- At the end, we show only the addresses that appear **more than 5 times**.
- We keep the "only show >5" rule for the very end so we don’t hide links that add up across both files.

**How to run (no commands shown):**
- On the cluster master, go to the project folder that contains the Makefile and the two Python files.
- Use the Make targets in this order: **prepare** (downloads the pages) → **filesystem** (creates your HDFS folder) → **upload-hdfs** (copies input to HDFS) → **stream-hdfs** (runs the job).
- If you need timing, run the job from a bash shell and use the shell’s built‑in **time** to see real/user/sys.

> SCREENSHOT OF OUTPUT(./lab2-finish-NIKITHA.png)
