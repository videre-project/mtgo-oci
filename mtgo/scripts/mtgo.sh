#!/bin/bash
# ClickOnce applications like MTGO are best launched via their bootstrapper
# This handles update checks and correct environment initialization.

SETUP_EXE="/home/wine/mtgo_setup.exe"

if [ ! -f "$SETUP_EXE" ]; then
    echo "MTGO bootstrapper (setup.exe) not found. Run 'install-mtgo.sh' first."
    exit 1
fi

echo "Launching MTGO via bootstrapper..."
wine "$SETUP_EXE" "$@"
