#!/bin/bash
# wine-shell: A bash subshell with Wine-aware aliases

SHELL_RC=$(mktemp)
cat > "$SHELL_RC" <<'BASHRC'
source /etc/bash.bashrc
source ~/.bashrc
export WINEDEBUG=-all
export DOTNET_ROOT=C:\\dotnet
alias run='wine-run'
alias wine-dotnet='wine C:\\dotnet\\dotnet.exe'
echo "----------------------------------------------------"
echo "  Wine Shell Initialized"
echo "  'dotnet build' -> Produces framework-dependent binaries"
echo "  'run' -> Runs 'wine-run' (Build + Wine Run)"
echo "  'wine-dotnet' -> Runs the native Windows .NET SDK in Wine"
echo "----------------------------------------------------"
BASHRC

/bin/bash --rcfile "$SHELL_RC" -i
rm "$SHELL_RC"
