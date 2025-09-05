# Makefile for Hadoop Streaming UrlCount (Python-only)

# Wikipedia pages to fetch (change if your instructor provides different ones)
WIKI1 := https://en.wikipedia.org/wiki/Apache_Hadoop
WIKI2 := https://en.wikipedia.org/wiki/MapReduce

# Try to auto-locate the Hadoop Streaming jar
HSTREAM := $(shell ls $$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar 2>/dev/null | head -n1)
ifeq ($(HSTREAM),)
HSTREAM := $(shell hadoop classpath --glob | tr ':' '\n' | grep -m1 'hadoop-streaming.*\.jar')
endif

.PHONY: prepare fetch-input clean-output stream stream-test filesystem upload-hdfs stream-hdfs stream-hdfs-time results-local results-hdfs

# 1) Download inputs (HTML) into ./input
fetch-input:
	@mkdir -p input
	@echo ">> Downloading Wikipedia pages into ./input ..."
	@if command -v curl >/dev/null 2>&1; then \
	  echo ">> Using curl"; \
	  curl -L -sS --compressed -A "Mozilla/5.0 (lab-2-convert-wordcount-to-urlcount-nikitha-kr)" "$(WIKI1)" -o input/wiki1.html; \
	  curl -L -sS --compressed -A "Mozilla/5.0 (ab-2-convert-wordcount-to-urlcount-nikitha-kr)" "$(WIKI2)" -o input/wiki2.html; \
	else \
	  echo ">> Using wget"; \
	  wget -q --user-agent="Mozilla/5.0 (ab-2-convert-wordcount-to-urlcount-nikitha-kr)" -O input/wiki1.html "$(WIKI1)"; \
	  wget -q --user-agent="Mozilla/5.0 (ab-2-convert-wordcount-to-urlcount-nikitha-kr)" -O input/wiki2.html "$(WIKI2)"; \
	fi
	@echo ">> Done. Files:"; ls -lh input

# Alias expected by some instructions
prepare: fetch-input
	@echo ">> To use HDFS, run: make filesystem && make upload-hdfs"

# Clean local and (if present) HDFS outputs
clean-output:
	- hdfs dfs -rm -r -f output 2>/dev/null || true
	- rm -rf output || true
	- hdfs dfs -rm -r -f /user/$$USER/output 2>/dev/null || true

# 2) Quick local sanity test (no Hadoop): mapper -> sort -> reducer
stream-test:
	cat input/* | python3 Mapper.py | sort | python3 Reducer.py | sort | sed -n '1,200p'

# 3) Hadoop Streaming on local FS: input=./input, output=./output
stream: clean-output
	hadoop jar "$(HSTREAM)" \
	  -D mapreduce.job.name="URLCount Streaming (local)" \
	  -files Mapper.py,Reducer.py \
	  -mapper "python3 Mapper.py" \
	  -reducer "python3 Reducer.py" \
	  -input input \
	  -output output
	@$(MAKE) results-local

results-local:
	@echo ">> Results (sorted, local):"; \
	  cat output/part-* | sort | sed -n '1,200p' || true

# 4) HDFS helpers (for Dataproc or local HDFS)
filesystem:
	hdfs dfs -mkdir -p /user/$$USER/input || true

upload-hdfs:
	hdfs dfs -mkdir -p /user/$$USER/input || true
	hdfs dfs -put -f input/* /user/$$USER/input

# 5) Hadoop Streaming on HDFS
stream-hdfs:
	hdfs dfs -rm -r -f /user/$$USER/output || true
	hadoop jar "$(HSTREAM)" \
	  -D mapreduce.job.name="URLCount Streaming (HDFS)" \
	  -files Mapper.py,Reducer.py \
	  -mapper "python3 Mapper.py" \
	  -reducer "python3 Reducer.py" \
	  -input /user/$$USER/input \
	  -output /user/$$USER/output
	@$(MAKE) results-hdfs

# 6) Same as above, but prints wall-clock time
stream-hdfs-time:
	hdfs dfs -rm -r -f /user/$$USER/output || true
	time hadoop jar "$(HSTREAM)" \
	  -D mapreduce.job.name="URLCount Streaming (HDFS timed)" \
	  -files Mapper.py,Reducer.py \
	  -mapper "python3 Mapper.py" \
	  -reducer "python3 Reducer.py" \
	  -input /user/$$USER/input \
	  -output /user/$$USER/output
	@$(MAKE) results-hdfs

results-hdfs:
	@echo ">> Results (sorted, HDFS):"; \
	  hdfs dfs -cat /user/$$USER/output/part-* | sort | sed -n '1,200p' || true
