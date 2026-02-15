#!/bin/bash
# wine-run: Build using Linux SDK and run using Wine

export WINEDEBUG=${WINEDEBUG:--all}
export DOTNET_ROOT=C:\\dotnet

echo "--- Environment: DISPLAY=$DISPLAY, WINEDEBUG=$WINEDEBUG ---"

PROJECT_OR_SLN="$1"
shift || true

if [ -z "$PROJECT_OR_SLN" ]; then
  PROJECT_OR_SLN="."
fi

echo "--- Building $PROJECT_OR_SLN (win-x64, Framework-Dependent) ---"
dotnet build "$PROJECT_OR_SLN"

# Search for the executable in the most common output paths
if [ -d "bin" ]; then
    EXE_PATH=$(find bin -name "*.exe" | grep "win-x64" | head -n 1)
fi

if [ -z "$EXE_PATH" ]; then
    if [ -f "$PROJECT_OR_SLN" ]; then
        BASE_DIR=$(dirname "$PROJECT_OR_SLN")
        if [ -d "$BASE_DIR/bin" ]; then
            EXE_PATH=$(find "$BASE_DIR/bin" -name "*.exe" | grep "win-x64" | head -n 1)
        fi
    fi
fi

if [ -f "$EXE_PATH" ]; then
    echo "--- Running $EXE_PATH via Wine ---"
    wine "$EXE_PATH" "$@"
else
    echo "Error: Could not find win-x64 executable for $PROJECT_OR_SLN"
    exit 1
fi
