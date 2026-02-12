# Error-Only Filtering Feature

## Overview
Added ability to filter heartbeat steps to show only those with errors, both via API and UI.

## API Usage

### Get Latest Heartbeat (Errors Only)
```bash
curl "http://127.0.0.1:3141/api/latest?agent=promo-assistant-reddit&errors_only=true"
```

**Response:**
```json
{
  "startTime": "2026-02-12T09:31:23.005Z",
  "totalCost": 0.4967,
  "filteredToErrors": true,
  "totalSteps": 12,
  "steps": [
    // Only steps with errors (empty if no errors)
  ]
}
```

### Get Specific Heartbeat (Errors Only)
```bash
# Matches UI: #agent=promo-assistant-reddit&hb=1
curl "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&hb=1&errors_only=true"
```

### Get Agent Data (Errors Only in All Heartbeats)
```bash
curl "http://127.0.0.1:3141/api/agent/promo-assistant-reddit?errors_only=true"
```

## Helper Functions

```bash
source ~/.openclaw/canvas/dashboard-helper.sh

# Get only error steps from latest heartbeat
dashboard_latest_errors_only "promo-assistant-reddit"

# Get only error steps from specific heartbeat
dashboard_get_hb_errors "promo-assistant-reddit" 2
```

## UI Buttons

Each heartbeat now has two API copy buttons:

1. **📋 API** - Copy full API URL with all steps
   - Example: `http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&hb=0`

2. **⚠ API** - Copy API URL with errors_only filter
   - Example: `http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&hb=0&errors_only=true`

### How to Use UI Buttons

1. Open the dashboard: http://127.0.0.1:3141
2. Click on any agent
3. Each heartbeat row shows two buttons:
   - Click **📋 API** to copy the full API URL
   - Click **⚠ API** to copy the errors-only API URL
4. Button shows "✓ Copied" for 2 seconds after copying

## Response Format

### Normal Response (errors_only=false or omitted)
```json
{
  "totalCost": 0.4967,
  "steps": [
    {
      "time": "2026-02-12T09:31:30.308Z",
      "cost": 0.2222,
      "toolCalls": [...],
      "toolResults": [...]
    }
    // ... all steps
  ]
}
```

### Filtered Response (errors_only=true)
```json
{
  "totalCost": 0.4967,
  "filteredToErrors": true,
  "totalSteps": 12,
  "steps": [
    // Only steps where toolResults contain isError: true
  ]
}
```

## When Steps Have No Errors

If a heartbeat has no errors and `errors_only=true`:
```json
{
  "totalCost": 0.4967,
  "filteredToErrors": true,
  "totalSteps": 12,
  "steps": []  // Empty array
}
```

## Integration Examples

### Check for Errors in Latest Run
```bash
#!/bin/bash
AGENT="promo-assistant-reddit"

# Get error steps only
error_steps=$(curl -s "http://127.0.0.1:3141/api/latest?agent=$AGENT&errors_only=true" | jq '.steps | length')

if [ "$error_steps" -gt 0 ]; then
  echo "⚠️  Found $error_steps error steps in latest run"
  # Get error details
  curl -s "http://127.0.0.1:3141/api/latest?agent=$AGENT&errors_only=true" | \
    jq -r '.steps[] | .toolResults[] | select(.isError) | .preview'
else
  echo "✓ No errors in latest run"
fi
```

### Compare Error Rate Across Heartbeats
```bash
for i in 0 1 2 3 4; do
  errors=$(curl -s "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-threads&hb=$i&errors_only=true" | jq '.steps | length')
  total=$(curl -s "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-threads&hb=$i" | jq '.steps | length')
  echo "Heartbeat #$i: $errors/$total steps with errors"
done
```

### Agent Self-Debugging
Add to agent's HEARTBEAT.md:
```markdown
## Error Check

At start of heartbeat:
```bash
error_count=$(curl -s "http://127.0.0.1:3141/api/latest?agent=YOUR_AGENT_ID&errors_only=true" | jq '.steps | length')

if [ "$error_count" -gt 0 ]; then
  echo "⚠️  Previous run had $error_count error steps"
  # Review errors and adjust strategy
fi
```
```

## Features Summary

- ✅ Filter heartbeat steps to errors only
- ✅ Works with all heartbeat endpoints
- ✅ UI buttons to copy API URLs
- ✅ Helper bash functions
- ✅ Preserves original step count in response
- ✅ Clean, focused error analysis
