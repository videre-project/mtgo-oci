#!/bin/sh

PROJECT="$1"
[ "$#" -ge 1 ] && shift
OUTPUT_DIR="${1:-./dist/win-x64}"
[ "$#" -ge 1 ] && shift

dotnet restore
dotnet publish "$PROJECT" --self-contained \
  -r win-x64 -p:RestoreLockedMode=false \
  -o "$OUTPUT_DIR"

if [ ! -f "$OUTPUT_DIR/$PROJECT.exe" ]; then
  echo "No $PROJECT.exe found in $OUTPUT_DIR"
  exit 1
fi

wine "$OUTPUT_DIR/$PROJECT.exe" "$@"
