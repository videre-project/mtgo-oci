#!/bin/bash
set -e

# Repository URL for MTGOSDK
REPO_URL="https://github.com/videre-project/MTGOSDK.git"
WORKSPACE_DIR="/workspace"

# Check if the workspace is empty or missing project files
if [ ! -d "$WORKSPACE_DIR/.git" ] && [ ! -f "$WORKSPACE_DIR/SDK.sln" ]; then
    echo "Workspace appears empty. Cloning MTGOSDK repository..."
    # Clone into a temporary directory first if workspace is not empty but lacks the project
    if [ "$(ls -A $WORKSPACE_DIR)" ]; then
        echo "Workspace not empty, cloning to a temporary location and merging..."
        TEMP_DIR=$(mktemp -d)
        git clone "$REPO_URL" "$TEMP_DIR"
        cp -an "$TEMP_DIR/." "$WORKSPACE_DIR/"
        rm -rf "$TEMP_DIR"
    else
        git clone "$REPO_URL" "$WORKSPACE_DIR"
    fi
    echo "Clone complete."
fi

# Execute the passed command
exec "$@"
