#!/bin/bash
#
# notify-user.sh - Send notifications to user via Slack webhook
#
# Usage: ./scripts/notify-user.sh "Your message here"
#
# The webhook URL should be stored in .slack-webhook-url at the project root.
#

set -e

# Find project root (where .slack-webhook-url should be)
find_webhook_file() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.slack-webhook-url" ]; then
            echo "$dir/.slack-webhook-url"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Check for message argument
if [ -z "$1" ]; then
    echo "Usage: $0 \"message\""
    echo "  Sends a notification to the configured Slack channel."
    exit 1
fi

MESSAGE="$1"

# Find webhook URL file
WEBHOOK_FILE=$(find_webhook_file) || {
    echo "Error: .slack-webhook-url not found in project hierarchy."
    echo ""
    echo "To set up Slack notifications:"
    echo "  1. Create a Slack incoming webhook at https://api.slack.com/messaging/webhooks"
    echo "  2. Run: echo \"YOUR_WEBHOOK_URL\" > .slack-webhook-url"
    echo ""
    exit 1
}

# Read webhook URL
WEBHOOK_URL=$(cat "$WEBHOOK_FILE" | tr -d '[:space:]')

if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: .slack-webhook-url is empty."
    exit 1
fi

# Validate URL format
if [[ ! "$WEBHOOK_URL" =~ ^https://hooks\.slack\.com/ ]]; then
    echo "Error: Invalid Slack webhook URL format."
    echo "URL should start with: https://hooks.slack.com/"
    exit 1
fi

# Escape for JSON
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

ESCAPED_MESSAGE=$(escape_json "$MESSAGE")
JSON_PAYLOAD="{\"text\": \"$ESCAPED_MESSAGE\"}"

# Send to Slack
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" \
    "$WEBHOOK_URL")

if [ "$HTTP_RESPONSE" -eq 200 ]; then
    echo "Notification sent."
else
    echo "Error: Failed to send notification. HTTP status: $HTTP_RESPONSE"
    exit 1
fi
