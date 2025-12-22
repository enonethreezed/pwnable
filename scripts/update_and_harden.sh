#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script as root" >&2
  exit 1
fi

echo "[*] Updating package lists..."
apt-get update

echo "[*] Upgrading packages (non-interactive)..."
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade

echo "[*] Ensuring pkexec is not SUID..."
if [[ -f /usr/bin/pkexec ]]; then
  chmod 0755 /usr/bin/pkexec
fi

echo "Done. Reboot recommended to load new kernel if installed."
