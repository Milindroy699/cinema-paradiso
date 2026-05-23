#!/bin/bash
cd "$(dirname "$0")"

# Start WebSocket relay server in background
node sync-server.js &
SERVER_PID=$!
sleep 1

# Start Cloudflare tunnel and capture the URL
echo "Starting tunnel... (takes ~5 seconds)"
cloudflared tunnel --protocol http2 --url http://localhost:8765 2>&1 | while IFS= read -r line; do
  if [[ "$line" == *"trycloudflare.com"* ]]; then
    TUNNEL_HOST=$(echo "$line" | grep -o '[a-z-]*\.trycloudflare\.com')
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  AUDIENCE URL (share this):"
    echo "  https://milindroy699.github.io/cinema-paradiso/?ws=wss://$TUNNEL_HOST"
    echo ""
    echo "  YOUR CONTROLLER URL (phone):"
    echo "  https://milindroy699.github.io/cinema-paradiso/?remote=ctrl1&ws=wss://$TUNNEL_HOST"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Press Ctrl+C to stop the sync server when done."
    echo ""
  fi
done

kill $SERVER_PID 2>/dev/null
