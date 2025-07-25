# SwiftHadoopStreaming WordCount Example

This example demonstrates how to run Swift-based MapReduce programs with Hadoop Streaming on Linux using Docker.

## Overview

The WordCount example consists of:
- **WordCountMapper**: Processes input lines and emits word-count pairs
- **WordCountReducer**: Aggregates word counts from the mapper
- **Hadoop Integration**: Uses Hadoop Streaming JAR to orchestrate the MapReduce job

## Prerequisites

- Docker installed and running
- Basic understanding of MapReduce concepts

**Architecture:**
- **Swift Version**: 6.1
- **Hadoop Version**: 3.4.0
- **Java Version**: OpenJDK 11
- **Container OS**: Ubuntu 22.04 (Jammy)

## Quick Start

### 1. Build the Docker Image

```bash
docker build -t swifthadoopstreaming -f docker/Dockerfile .
```

This builds a Docker image with:
- Swift 6.1 runtime
- Hadoop 3.4.0
- All Swift executables compiled for Linux

### 2. Create Input Data

Create a tab-separated input file (Hadoop streaming format):

```bash
cat > hadoop_input.txt << 'EOF'
1	hello world hadoop streaming
2	hello world hadoop streaming
3	big data processing with swift
4	hadoop streaming example using swift
5	hello swift world of big data
6	hadoop streaming jar testing
7	swift mapper and reducer programs
EOF
```

**Important**: Input must be tab-separated with format `key\tvalue` per line.

### 3. Run the Complete MapReduce Job

```bash
docker run --rm -v $(pwd)/hadoop_input.txt:/tmp/hadoop_input.txt swifthadoopstreaming bash -c "
# Set correct JAVA_HOME for the container
export JAVA_HOME=\$(dirname \$(dirname \$(readlink -f \$(which java))))

# Run Hadoop streaming job
hadoop jar \$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \\
    -input /tmp/hadoop_input.txt \\
    -output /tmp/wordcount_output \\
    -mapper '/app/Examples/WordCount/.build/release/WordCountMapper' \\
    -reducer '/app/Examples/WordCount/.build/release/WordCountReducer' \\
    -cmdenv PATH=\$PATH

# Display results
echo '=== WordCount Results ==='
cat /tmp/wordcount_output/part-00000
"
```

### 4. Expected Output

The job will produce sorted word counts:

```
and	2
big	2
data	2
example	1
hadoop	4
hello	2
jar	1
mapper	1
of	1
processing	1
programs	1
reducer	1
streaming	3
swift	5
testing	1
together	1
using	1
with	1
working	1
world	2
```

## Step-by-Step Breakdown

### Testing Individual Components

#### Test the Mapper Alone

```bash
docker run --rm swifthadoopstreaming bash -c "
echo -e '1\thello world\n2\thello hadoop' | /app/Examples/WordCount/.build/release/WordCountMapper
"
```

Expected output:
```
hello	1
world	1
hello	1
hadoop	1
```

#### Test the Full Pipeline (Mapper + Reducer)

```bash
docker run --rm swifthadoopstreaming bash -c "
echo -e '1\thello world\n2\thello hadoop\n3\tworld of data' | 
/app/Examples/WordCount/.build/release/WordCountMapper | 
sort | 
/app/Examples/WordCount/.build/release/WordCountReducer
"
```

Expected output:
```
data	1
hadoop	1
hello	2
of	1
world	2
```

### Understanding the Data Flow

1. **Input Format**: Each line contains `key\tvalue` (tab-separated)
2. **Mapper**: 
   - Reads tab-separated lines
   - Splits values into words
   - Emits `word\t1` for each word
3. **Hadoop**: 
   - Sorts mapper output by key
   - Groups same keys together
4. **Reducer**:
   - Receives grouped `word\t[1,1,1,...]`
   - Sums the counts
   - Emits `word\ttotal_count`

## Docker Container Commands

The container provides several built-in commands:

```bash
# Build all Swift packages
docker run --rm swifthadoopstreaming build

# Run core tests
docker run --rm swifthadoopstreaming test-core

# Start interactive bash session
docker run --rm -it swifthadoopstreaming bash

# Run PhotoDupes example (different use case)
docker run --rm swifthadoopstreaming local-test <manifest-file>
```

## Troubleshooting

### Common Issues

1. **Input Format**: Ensure input is tab-separated (`\t`), not spaces
2. **Java Path**: The container automatically sets `JAVA_HOME` 
3. **Output Directory**: Hadoop requires output directory to not exist
4. **Permissions**: All executables are pre-built with correct permissions

### Debugging

Enable verbose Hadoop logging:
```bash
# Add -D mapreduce.job.user.classpath.first=true for more verbose output
hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -D mapreduce.job.user.classpath.first=true \
    -input /tmp/input.txt \
    -output /tmp/output \
    -mapper '/path/to/mapper' \
    -reducer '/path/to/reducer'
```

Check container logs:
```bash
docker run --rm swifthadoopstreaming bash -c "
echo 'debug test' | /app/Examples/WordCount/.build/release/WordCountMapper 2>&1
"
```
