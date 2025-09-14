#!/usr/bin/env bash
read -p "Specify path to Blender Python script (e.g., /var/www/1.py): " BLENDER_SCRIPT
if [ -f "$BLENDER_SCRIPT" ]; then echo "$BLENDER_SCRIPT" > "/usr/local/bin/.blender_script"; log "Blender script path stored."; else warn "Blender script not found at $BLENDER_SCRIPT"; fi
cat > "/usr/local/bin/renderbpy" <<'EOC'
#!/bin/bash
BPY_FILE="/usr/local/bin/.blender_script"
if [ -f "$BPY_FILE" ]; then BPY=$(cat "$BPY_FILE"); if [ -f "$BPY" ]; then echo "Running Blender script: $BPY"; blender --background --python "$BPY"; else echo "Stored Blender script path does not exist."; fi; else echo "No Blender script stored. Re-run bootstrap."; fi
EOC
chmod +x "/usr/local/bin/renderbpy"
