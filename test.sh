0 0 * * * certbot renew
0 0 * * 0 apt-get update && apt-get upgrade -y && apt-get autoremove -y
0 0 * * * systemctl restart apache2 DAILY CHANGE THIS
#!/bin/bash
find /path/to/backups -type f -mtime +30 -exec rm {} \;
0 0 1 * * /path/to/test.sh
