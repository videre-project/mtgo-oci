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

echo "--- Building $PROJECT_OR_SLN (Framework-Dependent) ---"
dotnet build "$PROJECT_OR_SLN"

# Get the project name to look for the matching executable
# If the input contains a path, take the filename. Then strip any C# project/solution extension.
PROJECT_NAME=$(basename "$PROJECT_OR_SLN" | sed -E 's/\.(csproj|sln|fsproj|vbproj)$//')

# Search for the executable in the most common output paths
if [ -d "bin" ]; then
    # Prioritize exact matches for .exe or .dll (for tests)
    EXE_PATH=$(find bin -name "${PROJECT_NAME}.exe" -o -name "${PROJECT_NAME}.dll" | head -n 1)
    # Fallback to any executable if the exact match wasn't found
    if [ -z "$EXE_PATH" ]; then
        EXE_PATH=$(find bin -name "*.exe" | head -n 1)
    fi
fi

if [ -z "$EXE_PATH" ]; then
    BASE_DIR=""
    if [ -d "$PROJECT_OR_SLN" ]; then
        BASE_DIR="$PROJECT_OR_SLN"
    elif [ -f "$PROJECT_OR_SLN" ]; then
        BASE_DIR=$(dirname "$PROJECT_OR_SLN")
    fi

    if [ -n "$BASE_DIR" ] && [ -d "$BASE_DIR/bin" ]; then
        # Prioritize exact matches for .exe or .dll (for tests)
        EXE_PATH=$(find "$BASE_DIR/bin" -name "${PROJECT_NAME}.exe" -o -name "${PROJECT_NAME}.dll" | head -n 1)
        # Fallback to any executable if the exact match wasn't found
        if [ -z "$EXE_PATH" ]; then
            EXE_PATH=$(find "$BASE_DIR/bin" -name "*.exe" | head -n 1)
        fi
    fi
fi

if [ -f "$EXE_PATH" ]; then
    echo "--- Running $EXE_PATH via Wine ---"
    # If it's a DLL, we run it via the windows dotnet host
    if [[ "$EXE_PATH" == *.dll ]]; then
        wine "C:\\dotnet\\dotnet.exe" "$EXE_PATH" "$@"
    else
        wine "$EXE_PATH" "$@"
    fi
else
    echo "Error: Could not find executable for $PROJECT_OR_SLN"
    exit 1
fi
