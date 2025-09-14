#!/usr/bin/env bash
detect_and_update(){ dir="$1"; cd "$dir" || return; if [ -f "package.json" ]; then log "Detected Node.js project in $dir"; elif [ -f "requirements.txt" ]; then log "Detected Python project in $dir"; elif [ -f "go.mod" ]; then log "Detected Go project in $dir"; elif [ -f "composer.json" ]; then log "Detected PHP project in $dir"; else log "No language detected in $dir"; fi; }
for dir in /var/www/*; do [ -d "$dir" ] && detect_and_update "$dir"; done
if [ -f "/var/www/project.go/main.go" ]; then cd /var/www/project.go; if ! command -v project &>/dev/null; then warn "Binary 'project' not found. Building..."; go build -o project main.go; fi; log "Running project.go..."; ./project &; else warn "No /var/www/project.go found."; fi
