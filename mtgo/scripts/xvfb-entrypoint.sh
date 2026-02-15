#!/bin/bash
set -e

# Disable Wine logging and set .NET runtime path
export WINEDEBUG=-all
export DOTNET_ROOT=C:\\dotnet

# Configuration
X_DISPLAY=${DISPLAY:-:99}
RESOLUTION=${RESOLUTION:-1280x1024x24}

# Only start Xvfb if we are on display :99 (default headless)
if [ "$X_DISPLAY" = ":99" ]; then
    # cleanup stale lock files
    rm -f /tmp/.X${X_DISPLAY#:}*

    echo "Starting Xvfb on display $X_DISPLAY with resolution $RESOLUTION"
    if [ "$DEBUG" = "true" ]; then
        Xvfb $X_DISPLAY -screen 0 $RESOLUTION > /tmp/xvfb.log 2>&1 &
    else
        Xvfb $X_DISPLAY -screen 0 $RESOLUTION &
    fi
    XVFB_PID=$!

    # Wait for Xvfb to start
    for i in {1..50}; do
        if xdpyinfo -display $X_DISPLAY >/dev/null 2>&1; then
            echo "Xvfb is ready."
            break
        fi
        sleep 0.1
    done

    # Start VNC if requested
    if [ "$START_VNC" = "true" ]; then
        echo "Starting x11vnc..."
        if [ "$DEBUG" = "true" ]; then
            x11vnc -display $X_DISPLAY -forever -shared -nopw -bg -xkb -rfbport 5900 > /tmp/x11vnc.log 2>&1
        else
            x11vnc -display $X_DISPLAY -forever -shared -nopw -bg -xkb -rfbport 5900
        fi
    fi

    # Enable Wine Virtual Desktop for better window management if requested (default: true for headless)
    WINE_VIRTUAL_DESKTOP=${WINE_VIRTUAL_DESKTOP:-true}
    if [ "$WINE_VIRTUAL_DESKTOP" = "true" ]; then
        echo "Enabling Wine Virtual Desktop (Resolution: ${RESOLUTION%x*})"
        wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer" /v "Desktop" /t REG_SZ /d "Default" /f >/dev/null 2>&1
        wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer\\Desktops" /v "Default" /t REG_SZ /d "${RESOLUTION%x*}" /f >/dev/null 2>&1
    fi

    # Disable automatic winedbg on crash to prevent orphan processes
    wine reg add "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /v "Auto" /t REG_SZ /d "0" /f >/dev/null 2>&1

    # Trap signals for cleanup
    trap "kill $XVFB_PID" SIGINT SIGTERM

    # # Auto-install MTGO if missing (default: true)
    # AUTO_INSTALL_MTGO=${AUTO_INSTALL_MTGO:-true}
    # if [ "$AUTO_INSTALL_MTGO" = "true" ]; then
    #     MTGO_EXE=$(find "$WINEPREFIX/drive_c/users/wine/AppData/Local/Apps/2.0" -name "MTGO.exe" | head -n 1)
    #     if [ -z "$MTGO_EXE" ]; then
    #         echo "MTGO not found. Starting automatic installation..."
    #         install-mtgo.sh
    #     fi
    # fi
fi

# Execute the passed command
exec "$@"
