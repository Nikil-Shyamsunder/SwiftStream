#!/bin/bash

# WordCount Reducer Wrapper Script for Hadoop Streaming
# This script wraps the Swift WordCountReducer executable for use with Hadoop Streaming

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the Swift executable
REDUCER_EXECUTABLE="$SCRIPT_DIR/../.build/release/WordCountReducer"

# Check if the executable exists
if [ ! -f "$REDUCER_EXECUTABLE" ]; then
    echo "Error: WordCountReducer executable not found at $REDUCER_EXECUTABLE" >&2
    echo "Please build the project first with: swift build -c release" >&2
    exit 1
fi

# Execute the Swift reducer
exec "$REDUCER_EXECUTABLE"