#!/bin/bash
set -e

# Download MTGO installer
echo "Downloading MTGO installer..."
wget -O /home/wine/mtgo_setup.exe https://mtgo.patch.daybreakgames.com/patch/mtg/live/client/setup.exe

# Run installer
echo "Running MTGO installer..."
wine /home/wine/mtgo_setup.exe

echo "Installation complete. You can now run 'mtgo' to launch the game."
