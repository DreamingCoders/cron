#!/usr/bin/env bash
read -p "Specify path to your game server (.x86_64): " GAMESERVER_PATH
if [ -f "$GAMESERVER_PATH" ]; then chmod +x "$GAMESERVER_PATH"; echo "$GAMESERVER_PATH" > "/usr/local/bin/.gameserver_path"; log "Game server path stored."; else warn "Game server not found at $GAMESERVER_PATH"; fi
cat > "/usr/local/bin/gameserver" <<'EOC'
#!/bin/bash
GS_FILE="/usr/local/bin/.gameserver_path"
if [ -f "$GS_FILE" ]; then GS=$(cat "$GS_FILE"); if [ -f "$GS" ]; then echo "Starting game server: $GS"; chmod +x "$GS"; "$GS" &; else echo "Stored game server path does not exist."; fi; else echo "No game server path stored. Re-run bootstrap."; fi
EOC
chmod +x "/usr/local/bin/gameserver"
