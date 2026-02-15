#!/bin/bash
# check-env.sh: Diagnostic script for MTGO headless environment

echo "=== System Information ==="
uname -a
id
echo "DISPLAY=$DISPLAY"

echo ""
echo "=== X Server Status ==="
if pgrep Xvfb > /dev/null; then
    echo "[PASS] Xvfb is running."
    ps aux | grep Xvfb | grep -v grep
else
    echo "[FAIL] Xvfb is NOT running."
fi

if [ -S /tmp/.X11-unix/X${DISPLAY#:} ]; then
    echo "[PASS] X11 socket found at /tmp/.X11-unix/X${DISPLAY#:}"
else
    echo "[FAIL] X11 socket NOT found for display $DISPLAY"
fi

if command -v xdpyinfo > /dev/null; then
    if xdpyinfo -display "$DISPLAY" > /dev/null 2>&1; then
        echo "[PASS] xdpyinfo successfully connected to display $DISPLAY"
    else
        echo "[FAIL] xdpyinfo FAILED to connect to display $DISPLAY"
    fi
else
    echo "[SKIP] xdpyinfo not installed."
fi

echo ""
echo "=== Wine Status ==="
wine --version
echo "WINEPREFIX=$WINEPREFIX"
if [ -d "$WINEPREFIX" ]; then
    echo "[PASS] Wine prefix directory exists."
else
    echo "[FAIL] Wine prefix directory NOT found."
fi

echo ""
echo "=== MTGO Installation Status ==="
MTGO_EXE=$(find "$WINEPREFIX/drive_c/users/wine/AppData/Local/Apps/2.0" -name "MTGO.exe" 2>/dev/null | head -n 1)
if [ -n "$MTGO_EXE" ]; then
    echo "[PASS] MTGO.exe found at: $MTGO_EXE"
else
    echo "[INFO] MTGO.exe NOT found in Wine prefix (expected if tests haven't run)."
fi

APPREF_PATH="/home/wine/.wine/drive_c/users/wine/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Daybreak Game Company LLC/Magic The Gathering Online .appref-ms"
if [ -f "$APPREF_PATH" ]; then
    echo "[PASS] MTGO .appref-ms found."
else
    echo "[INFO] MTGO .appref-ms NOT found (expected if tests haven't run)."
fi

echo ""
echo "=== Network Status ==="
ip addr show | grep 'inet '
# Check if we can reach Daybreak's patch server
if curl -sI http://mtgo.patch.daybreakgames.com/patch/mtg/live/client/MTGO.application > /dev/null; then
    echo "[PASS] Daybreak patch server is reachable."
else
    echo "[FAIL] Daybreak patch server is NOT reachable."
fi
