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

echo "--- Building $PROJECT_OR_SLN ---"
# Build natively on Linux to maintain ergonomics and lock file compatibility.
dotnet build "$PROJECT_OR_SLN"

# Get the project name to look for the matching binary
# Determine the project name to look for the matching binary.
# If a .sln is provided, we need to find the actual .csproj it builds to get the correct binary name.
if [[ "$PROJECT_OR_SLN" == *.sln ]]; then
    # Find the first .csproj in the directory (assuming standard single-project solution or taking the first one)
    # This is a heuristic; for multi-project solutions, we might want to be more specific, but this covers the flexible rename case.
    FOUND_CS=$(find "$(dirname "$PROJECT_OR_SLN")" -name "*.csproj" | head -n 1)
    if [ -n "$FOUND_CS" ]; then
        PROJECT_NAME=$(basename "$FOUND_CS" .csproj)
        PROJECT_DIR=$(dirname "$FOUND_CS")
    else
        PROJECT_NAME=$(basename "$PROJECT_OR_SLN" .sln)
    fi
elif [[ -d "$PROJECT_OR_SLN" ]]; then
     # If it's a directory, look for a .csproj inside
    FOUND_CS=$(find "$PROJECT_OR_SLN" -maxdepth 2 -name "*.csproj" | head -n 1)
    if [ -n "$FOUND_CS" ]; then
        PROJECT_NAME=$(basename "$FOUND_CS" .csproj)
        PROJECT_DIR=$(dirname "$FOUND_CS")
    else
        PROJECT_NAME=$(basename "$PROJECT_OR_SLN")
    fi
else
    # Fallback for direct .csproj input
    PROJECT_NAME=$(basename "$PROJECT_OR_SLN" | sed -E 's/\.(csproj|sln|fsproj|vbproj)$//')
fi

# Search for the binary in common output paths
find_binary() {
    local base="$1"
    # Prioritize exact matches for .exe (if built with RID)
    local found=$(find "$base" -name "${PROJECT_NAME}.exe" | head -n 1)
    if [ -z "$found" ]; then
        # Fallback to .dll (portable app built without RID)
        found=$(find "$base" -name "${PROJECT_NAME}.dll" | head -n 1)
    fi
    # Secondary fallback to any executable in the tree
    if [ -z "$found" ]; then
        found=$(find "$base" -maxdepth 5 -name "*.exe" | head -n 1)
    fi
    echo "$found"
}

EXE_PATH=""
if [ -d "bin" ]; then
    EXE_PATH=$(find_binary "bin")
fi

if [ -z "$EXE_PATH" ]; then
    BASE_DIR=""
    if [ -d "$PROJECT_OR_SLN" ]; then
        BASE_DIR="$PROJECT_OR_SLN"
    elif [ -f "$PROJECT_OR_SLN" ]; then
        BASE_DIR=$(dirname "$PROJECT_OR_SLN")
    fi

    if [ -n "$BASE_DIR" ] && [ -d "$BASE_DIR/bin" ]; then
        EXE_PATH=$(find_binary "$BASE_DIR/bin")
    fi
fi

if [ -z "$EXE_PATH" ]; then
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR/bin" ]; then
        EXE_PATH=$(find_binary "$PROJECT_DIR/bin")
    fi
fi

if [ -f "$EXE_PATH" ]; then
    # Ensure we use an absolute Unix path first
    ABS_EXE_PATH=$(realpath "$EXE_PATH")
    DIR_NAME=$(dirname "$ABS_EXE_PATH")
    
    # Convert Unix paths to Windows paths for Wine
    WIN_EXE_PATH=$(winepath -w "$ABS_EXE_PATH")
    WIN_DIR_NAME=$(winepath -w "$DIR_NAME")

    echo "--- Running $ABS_EXE_PATH via Wine ---"
    
    # Use 'wine cmd /c' to ensure environment variables like PATH and DOTNET_ROOT are handled correctly
    # We also 'cd' into the directory to help the host resolve dependencies.
    if [[ "$ABS_EXE_PATH" == *.dll ]]; then
        # For DLLs, run via the Windows .NET host
        wine cmd /c "cd /d $WIN_DIR_NAME && C:\\dotnet\\dotnet.exe $WIN_EXE_PATH" "$@"
    else
        # For native .exes, run directly
        wine cmd /c "cd /d $WIN_DIR_NAME && $WIN_EXE_PATH" "$@"
    fi
else
    echo "Error: Could not find executable for $PROJECT_OR_SLN"
    exit 1
fi
