#!/usr/bin/env bash
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
