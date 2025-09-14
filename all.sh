#!/usr/bin/env bash
# ======================All in one file===============================
# Universal Sysadmin Bootstrapper (Ultimate Full + Game/Blender)
# ====================================================================
set -e
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"
log(){ echo -e "${BLUE}[INFO]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1"; }
install_if_missing(){ for pkg in "$@"; do if ! command -v "$pkg" &>/dev/null; then warn "$pkg not found. Installing..."; apt-get install -y "$pkg"; else log "$pkg already installed."; fi; done; }
install_if_missing neofetch cowsay fortune python3 python3-pip mailutils golang blender npm composer git
pip3 install fauxgl || true
HOMESTEAD_PATH="/usr/local/bin"
mkdir -p "$HOMESTEAD_PATH"
DAILY_REBOOT_FILE="$HOMESTEAD_PATH/.daily_reboot"
DAILY_REBOOT_ENABLED=0
[ -f "$DAILY_REBOOT_FILE" ] && DAILY_REBOOT_ENABLED=$(cat "$DAILY_REBOOT_FILE")
toggle_daily_reboot(){ if [ "$DAILY_REBOOT_ENABLED" -eq 1 ]; then echo 0 > "$DAILY_REBOOT_FILE"; DAILY_REBOOT_ENABLED=0; log "Daily reboot disabled"; else echo 1 > "$DAILY_REBOOT_FILE"; DAILY_REBOOT_ENABLED=1; log "Daily reboot enabled"; fi; update_motd; }
if [ -f "/var/www/project.go/main.go" ]; then cd /var/www/project.go; if ! command -v project &>/dev/null; then warn "Binary 'project' not found. Building..."; go build -o project main.go; fi; log "Running project.go..."; ./project &; else warn "No /var/www/project.go found."; fi
detect_and_update(){ dir="$1"; cd "$dir" || return; if [ -f "package.json" ]; then log "Detected Node.js project in $dir"; elif [ -f "requirements.txt" ]; then log "Detected Python project in $dir"; elif [ -f "go.mod" ]; then log "Detected Go project in $dir"; elif [ -f "composer.json" ]; then log "Detected PHP project in $dir"; else log "No language detected in $dir"; fi; }
for dir in /var/www/*; do [ -d "$dir" ] && detect_and_update "$dir"; done
read -p "Specify path to your game server (.x86_64): " GAMESERVER_PATH
if [ -f "$GAMESERVER_PATH" ]; then chmod +x "$GAMESERVER_PATH"; echo "$GAMESERVER_PATH" > "$HOMESTEAD_PATH/.gameserver_path"; log "Game server path stored."; else warn "Game server not found at $GAMESERVER_PATH"; fi
cat > "$HOMESTEAD_PATH/gameserver" <<'EOC'
#!/bin/bash
GS_FILE="/usr/local/bin/.gameserver_path"
if [ -f "$GS_FILE" ]; then GS=$(cat "$GS_FILE"); if [ -f "$GS" ]; then echo "Starting game server: $GS"; chmod +x "$GS"; "$GS" &; else echo "Stored game server path does not exist."; fi; else echo "No game server path stored. Re-run bootstrap."; fi
EOC
chmod +x "$HOMESTEAD_PATH/gameserver"
read -p "Specify path to Blender Python script (e.g., /var/www/1.py): " BLENDER_SCRIPT
if [ -f "$BLENDER_SCRIPT" ]; then echo "$BLENDER_SCRIPT" > "$HOMESTEAD_PATH/.blender_script"; log "Blender script path stored."; else warn "Blender script not found at $BLENDER_SCRIPT"; fi
cat > "$HOMESTEAD_PATH/renderbpy" <<'EOC'
#!/bin/bash
BPY_FILE="/usr/local/bin/.blender_script"
if [ -f "$BPY_FILE" ]; then BPY=$(cat "$BPY_FILE"); if [ -f "$BPY" ]; then echo "Running Blender script: $BPY"; blender --background --python "$BPY"; else echo "Stored Blender script path does not exist."; fi; else echo "No Blender script stored. Re-run bootstrap."; fi
EOC
chmod +x "$HOMESTEAD_PATH/renderbpy"
update_motd(){ MOTD_FILE="/etc/motd"; GS_STATUS="❌"; BPY_STATUS="❌"; [ -f "$HOMESTEAD_PATH/.gameserver_path" ] && [ -f "$(cat $HOMESTEAD_PATH/.gameserver_path)" ] && GS_STATUS="✅"; [ -f "$HOMESTEAD_PATH/.blender_script" ] && [ -f "$(cat $HOMESTEAD_PATH/.blender_script)" ] && BPY_STATUS="⏱"; DAILY_REBOOT_TEXT="disabled"; [ -f "$DAILY_REBOOT_FILE" ] && [ "$(cat $DAILY_REBOOT_FILE)" -eq 1 ] && DAILY_REBOOT_TEXT="enabled"; { echo -e "${GREEN}Welcome to $(hostname)${NC}"; echo -e "Date: $(date)"; echo -e "Uptime: $(uptime -p)"; echo -e "Load: $(uptime | awk -F'load average:' '{print $2}')"; echo -e "Disk: $(df -h / | awk 'NR==2 {print $5}') used"; echo -e ""; echo -e "${BLUE}Custom Commands:${NC}"; echo -e "  ${YELLOW}sysinfo${NC}   -> neofetch"; echo -e "  ${YELLOW}diskalert${NC} -> Check disk space"; echo -e "  ${YELLOW}updateall${NC} -> System + language updates"; echo -e "  ${YELLOW}devtools${NC}  -> Stripe/PayPal installer"; echo -e "  ${YELLOW}gameserver${NC} -> Launch stored game server (${GS_STATUS})"; echo -e "  ${YELLOW}renderbpy${NC}  -> Run stored Blender render (${BPY_STATUS})"; echo -e "  ${YELLOW}toggle_reboot${NC} -> Enable/disable daily reboot (currently: ${DAILY_REBOOT_TEXT})"; echo -e ""; echo -e "${BLUE}Homesteading:${NC} Use ${YELLOW}$HOMESTEAD_PATH${NC} as root path for custom executables. Add scripts here and chmod +x."; echo -e "${BLUE}Tips:${NC} Create your own commands: place executable in $HOMESTEAD_PATH, chmod +x, add manually to MOTD."; } > "$MOTD_FILE"; log "MOTD updated."; }
update_motd
if ! grep -q "neofetch" /etc/profile; then echo "neofetch" >> /etc/profile; fi
CRON_FILE="/etc/cron.d/sysadmin-bootstrap"
cat > "$CRON_FILE" <<'EOF'
0 3 * * * root apt-get update -y
0 4 * * 0 root apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y
30 2 * * 0 root rkhunter --update && rkhunter --check --sk
0 5 * * 0 root find / -xdev -type f -perm -0002 -print >> /var/log/cron-audit.log
0 0 * * * root systemctl restart apache2
0 2 * * 1 root apache2ctl graceful
0 1 * * 6 root tar -czf /backups/apache-configs-$(date +\%F).tar.gz /etc/apache2/sites-enabled
0 2 * * * root find /var/log -type f -mtime +14 -delete
0 3 * * * root find /tmp -type f -atime +7 -delete
0 2 1 * * root mysqldump -u root -p'SECUREPASSWORD' --all-databases | gzip > /backups/db-$(date +\%F).sql.gz
0 * * * * root /usr/games/fortune | logger -t fortune
20 16 * * 5 root echo "Never gonna give you up 🎶" | wall
0 9 * * * root echo "Uptime Report:" && uptime | cowsay | logger -t cowsay
0 7 * * * root cp /etc/motd /root/server-motd.txt && cd /root/github-repo && git add . && git commit -m "Auto-update MOTD $(date)" && git push
0 * * * * root echo "$(date) | $(uptime)" >> /var/log/uptime.log
0 6 * * * root df -h | awk '$5+0 >= 80 {print $0}' | mail -s "Disk Space Alert" admin@yourdomain.com
0 6 * * * root /usr/local/bin/bootstrap.sh motd
EOF
log "Cron jobs written to $CRON_FILE"
cat > "$HOMESTEAD_PATH/sysinfo" <<'EOC'
#!/bin/bash
neofetch
EOC
cat > "$HOMESTEAD_PATH/diskalert" <<'EOC'
#!/bin/bash
df -h | awk '$5+0 >= 80 {print "Disk Alert:", $0}'
EOC
cat > "$HOMESTEAD_PATH/updateall" <<'EOC'
#!/bin/bash
apt-get update -y && apt-get upgrade -y
for dir in /var/www/*; do if [ -d "$dir" ]; then cd "$dir"; if [ -f "package.json" ]; then npm update; fi; if [ -f "requirements.txt" ]; then pip install -r requirements.txt --upgrade; fi; if [ -f "go.mod" ]; then go get -u ./...; fi; if [ -f "composer.json" ]; then composer update; fi; fi; done
EOC
cat > "$HOMESTEAD_PATH/devtools" <<'EOC'
#!/bin/bash
echo "Choose an option:"
echo "1) Install Stripe webhook (PHP composer)"
echo "2) Install PayPal IPN (PHP composer)"
echo "3) Exit"
read -p "Enter choice [1-3]: " choice
case $choice in
1) [ -f "composer.json" ] && composer require stripe/stripe-php || echo "No composer.json in current directory."; ;;
2) [ -f "composer.json" ] && composer require paypal/ipn || echo "No composer.json in current directory."; ;;
3) echo "Bye";;
*) echo "Invalid choice";;
esac
EOC
cat > "$HOMESTEAD_PATH/toggle_reboot" <<'EOC'
#!/bin/bash
/usr/local/bin/bootstrap.sh toggle_reboot
EOC
chmod +x "$HOMESTEAD_PATH/"*
log "Custom commands installed and bootstrap complete."
