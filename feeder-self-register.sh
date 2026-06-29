#!/bin/bash
# feeder-self-register.sh — Discover your feeder's personalized map URL
#
# Reads the feeder UUID from /etc/bharat-radar-id and looks up
# its registration status on bharatradar.com.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/bharatradar/feeders/main/feeder-self-register.sh | bash
#   # or run directly on the feeder Pi:
#   sudo ./feeder-self-register.sh

UUID_FILE="/etc/bharat-radar-id"
API_BASE="${BHARATRADAR_API:-https://my.bharatradar.com}"

if [ ! -f "$UUID_FILE" ]; then
    echo "Error: UUID file not found at $UUID_FILE"
    echo "This script must be run on a bharatradar feeder Pi with readsb installed."
    echo ""
    echo "If you are setting up a new feeder, run the installer first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/bharatradar/feeders/main/bharatradar-feeder | sudo bash"
    exit 1
fi

UUID=$(tr -d ' \n\r' < "$UUID_FILE")

if [ -z "$UUID" ]; then
    echo "Error: UUID file is empty at $UUID_FILE"
    exit 1
fi

echo "🔍 Looking up feeder UUID: $UUID"
echo ""

RESPONSE=$(curl -sS "${API_BASE}/api/feeders/lookup?uuid=${UUID}" 2>/dev/null)
CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
    echo "Error: Could not reach ${API_BASE}"
    echo ""
    echo "Your direct map URL (no lookup):"
    echo "  https://map.bharatradar.com/?filter_uuid=${UUID}"
    exit 1
fi

REGISTERED=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('registered', False))" 2>/dev/null)
MAP_URL=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('map_url', ''))" 2>/dev/null)
DISPLAY_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('display_name') or '')" 2>/dev/null)

echo "================================"
if [ "$REGISTERED" = "True" ]; then
    echo "✅ Your feeder IS REGISTERED!"
    if [ -n "$DISPLAY_NAME" ]; then
        echo "   Display name: $DISPLAY_NAME"
    fi
else
    echo "❌ Your feeder is NOT YET REGISTERED."
    echo ""
    echo "To register, visit https://my.bharatradar.com and log in,"
    echo "then go to your profile page and add this station UUID:"
    echo "  $UUID"
    echo ""
    echo "Or use the API (requires auth token):"
    echo "  curl -X POST https://my.bharatradar.com/api/feeders/register \\"
    echo "    -H \"Authorization: Bearer <token>\" \\"
    echo "    -H \"Content-Type: application/json\" \\"
    echo "    -d '{\"station_uuid\": \"$UUID\"}'"
fi
echo ""
echo "📡 Your personalized map URL:"
echo "  $MAP_URL"
echo "================================"
