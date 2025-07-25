#!/bin/bash

# Script to run WordCount MapReduce job on Hadoop cluster
# This script sets up input data, runs the job, and shows results

set -e

# Configuration
HADOOP_STREAMING_JAR="/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar"
INPUT_DIR="/user/wordcount/input"
OUTPUT_DIR="/user/wordcount/output"
LOCAL_INPUT_FILE="../input.txt"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== WordCount MapReduce Job ==="

# 1. Clean up existing output directory
echo "1. Cleaning up existing output directory..."
if hadoop fs -test -d "$OUTPUT_DIR" 2>/dev/null; then
    hadoop fs -rm -r "$OUTPUT_DIR"
fi

# 2. Create input directory if it doesn't exist
echo "2. Setting up input directory..."
hadoop fs -mkdir -p "$INPUT_DIR"

# 3. Copy input file to HDFS
echo "3. Copying input file to HDFS..."
hadoop fs -put -f "$LOCAL_INPUT_FILE" "$INPUT_DIR/"

# 4. List input files
echo "4. Input files in HDFS:"
hadoop fs -ls "$INPUT_DIR"

# 5. Run the MapReduce job
echo "5. Running WordCount MapReduce job..."
hadoop jar "$HADOOP_STREAMING_JAR" \
    -files "$SCRIPT_DIR/mapper.sh,$SCRIPT_DIR/reducer.sh" \
    -mapper "./mapper.sh" \
    -reducer "./reducer.sh" \
    -input "$INPUT_DIR" \
    -output "$OUTPUT_DIR"

# 6. Show results
echo "6. WordCount results:"
hadoop fs -cat "$OUTPUT_DIR/part-00000" | head -20

echo ""
echo "=== Job completed successfully! ==="