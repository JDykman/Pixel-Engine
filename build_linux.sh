#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# This prevents the script from continuing after a failure.
set -e

# Get the absolute path of the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Define the output directory and file path for clarity and reuse
OUTPUT_DIR="$SCRIPT_DIR/build/linux_debug"
OUTPUT_FILE="$OUTPUT_DIR/game"

echo "Creating build directory..."
mkdir -p "$OUTPUT_DIR"

echo "Building project with Odin..."
odin build "$SCRIPT_DIR/src" -debug -collection:engine="$SCRIPT_DIR/src/engine" -collection:user="$SCRIPT_DIR/src" -out:"$OUTPUT_FILE"

echo "Making executable..."
chmod +x "$OUTPUT_FILE"

# This line will only be reached if all previous commands succeed
echo "✅ Build successful: $OUTPUT_FILE"