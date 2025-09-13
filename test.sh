# Update package lists daily
0 3 * * * apt-get update -y

# Weekly full upgrade & cleanup
0 4 * * 0 apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

# Run a rootkit check weekly (requires rkhunter)
30 2 * * 0 rkhunter --update && rkhunter --check --sk

# Check for world-writable files (logs to /var/log/cron-audit.log)
0 5 * * 0 find / -xdev -type f -perm -0002 -print >> /var/log/cron-audit.log
# Daily restart Apache to avoid memory leaks
0 0 * * * systemctl restart apache2

# Weekly reload configs (less disruptive than restart)
0 2 * * 1 apache2ctl graceful

# Backup all enabled vhost configs once a week
0 1 * * 6 tar -czf /backups/apache-configs-$(date +\%F).tar.gz /etc/apache2/sites-enabled
# Rotate logs older than 14 days
0 2 * * * find /var/log -type f -mtime +14 -delete

# Clean tmp files older than 7 days
0 3 * * * find /tmp -type f -atime +7 -delete

# Monthly DB backup (assuming MySQL/MariaDB)
0 2 1 * * mysqldump -u root -p'SECUREPASSWORD' --all-databases | gzip > /backups/db-$(date +\%F).sql.gz
# Send random fortune to syslog every hour
0 * * * * /usr/games/fortune | logger -t fortune

# Play "rickroll" in console once a week at Friday 4:20 PM 😏
20 16 * * 5 echo "Never gonna give you up 🎶" | wall

# Daily cow saying server status
0 9 * * * echo "Uptime Report:" && uptime | cowsay | logger -t cowsay

# GitHub auto-push system motd updates
0 7 * * * cp /etc/motd /root/server-motd.txt && cd /root/github-repo && git add . && git commit -m "Auto-update MOTD $(date)" && git push
# Write server uptime & load to a log file every hour
0 * * * * echo "$(date) | $(uptime)" >> /var/log/uptime.log

# Check disk space and mail if over 80%
0 6 * * * df -h | awk '$5+0 >= 80 {print $0}' | mail -s "Disk Space Alert" admin@yourdomain.com
