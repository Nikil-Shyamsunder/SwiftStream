#!/usr/bin/env bash
set -euo pipefail

cmd="$1"
shift

case $cmd in
    bash)
        exec /bin/bash "$@"
        ;;
    local-test)
        if [ $# -eq 0 ]; then
            echo "Usage: local-test <manifest-file>"
            exit 1
        fi
        exec photodupes local-test "$@"
        ;;
    hadoop-job)
        if [ $# -lt 2 ]; then
            echo "Usage: hadoop-job <input> <output>"
            exit 1
        fi
        input="$1"
        output="$2"
        shift 2
        
        echo "Running Hadoop Streaming job..."
        echo "Input: $input"
        echo "Output: $output"
        
        exec hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
            -input "$input" \
            -output "$output" \
            -mapper "photodupes map" \
            -reducer "photodupes reduce" \
            -cmdenv PATH="$PATH" \
            "$@"
        ;;
    test-core)
        echo "Running SwiftStream core tests..."
        cd /app/Core
        exec swift test
        ;;
    test-photodupes)
        echo "Running PhotoDupes tests..."
        cd /app/Examples/PhotoDupes
        exec swift test
        ;;
    build)
        echo "Building SwiftStream..."
        cd /app/Core
        swift build -c release
        echo "Building PhotoDupes..."
        cd /app/Examples/PhotoDupes
        swift build -c release
        echo "Build complete!"
        ;;
    *)
        echo "Unknown command: $cmd"
        echo "Available commands:"
        echo "  bash                    - Start bash shell"
        echo "  local-test <manifest>   - Run local PhotoDupes test"
        echo "  hadoop-job <in> <out>   - Run Hadoop streaming job"
        echo "  test-core               - Run SwiftStream tests"
        echo "  test-photodupes         - Run PhotoDupes tests"
        echo "  build                   - Build all packages"
        exit 1
        ;;
esac