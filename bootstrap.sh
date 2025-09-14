#!/usr/bin/env bash
# Universal Sysadmin Bootstrapper (Core + Setup)
set -e
RED="\033[1;31m"; GREEN="\033[1;32m"; YELLOW="\033[1;33m"; BLUE="\033[1;34m"; NC="\033[0m"
log(){ echo -e "${BLUE}[INFO]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1"; }
install_if_missing(){ for pkg in "$@"; do if ! command -v "$pkg" &>/dev/null; then warn "$pkg not found. Installing..."; apt-get install -y "$pkg"; else log "$pkg already installed."; fi; done; }
install_if_missing neofetch cowsay fortune python3 python3-pip mailutils golang blender npm composer git
pip3 install fauxgl || true
HOMESTEAD_PATH="/usr/local/bin"; mkdir -p "$HOMESTEAD_PATH"
DAILY_REBOOT_FILE="$HOMESTEAD_PATH/.daily_reboot"; DAILY_REBOOT_ENABLED=0
[ -f "$DAILY_REBOOT_FILE" ] && DAILY_REBOOT_ENABLED=$(cat "$DAILY_REBOOT_FILE")
