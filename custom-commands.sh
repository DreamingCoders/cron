#!/usr/bin/env bash
HOMESTEAD_PATH="/usr/local/bin"
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
echo "Choose an option:"; echo "1) Install Stripe webhook (PHP composer)"; echo "2) Install PayPal IPN (PHP composer)"; echo "3) Exit"; read -p "Enter choice [1-3]: " choice; case $choice in 1) [ -f "composer.json" ] && composer require stripe/stripe-php || echo "No composer.json in current directory."; ;; 2) [ -f "composer.json" ] && composer require paypal/ipn || echo "No composer.json in current directory."; ;; 3) echo "Bye";; *) echo "Invalid choice";; esac
EOC
cat > "$HOMESTEAD_PATH/toggle_reboot" <<'EOC'
#!/bin/bash
/usr/local/bin/bootstrap.sh toggle_reboot
EOC
chmod +x "$HOMESTEAD_PATH/"*
log "Custom commands installed."
