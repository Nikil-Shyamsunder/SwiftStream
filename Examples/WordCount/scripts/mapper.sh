#!/bin/bash

# WordCount Mapper Wrapper Script for Hadoop Streaming
# This script wraps the Swift WordCountMapper executable for use with Hadoop Streaming

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the Swift executable
MAPPER_EXECUTABLE="$SCRIPT_DIR/../.build/release/WordCountMapper"

# Check if the executable exists
if [ ! -f "$MAPPER_EXECUTABLE" ]; then
    echo "Error: WordCountMapper executable not found at $MAPPER_EXECUTABLE" >&2
    echo "Please build the project first with: swift build -c release" >&2
    exit 1
fi

# Execute the Swift mapper
exec "$MAPPER_EXECUTABLE"