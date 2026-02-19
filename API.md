# OpenClaw Trace API

Base URL: `http://127.0.0.1:3141`

## Endpoints

### GET /api/data
Returns complete dashboard data (agents, heartbeats, budget, trends).

**Response:**
```json
{
  "agents": [...],
  "dailySummary": [...],
  "budget": {...},
  "trendData": [...]
}
```

---

### GET /api/agents
List all agents with summary statistics.

**Response:**
```json
[
  {
    "id": "promo-assistant-reddit",
    "name": "Reddit Assistant",
    "emoji": "🤖",
    "model": "sonnet-4-5",
    "totalCost": 0.1234,
    "totalErrors": 2,
    "heartbeatCount": 45,
    "lastRun": 1707756800000,
    "avgCacheHit": 72,
    "contextUsed": 45000,
    "contextLimit": 200000
  }
]
```

---

### GET /api/agent/:id
Get detailed information for a specific agent.

**Parameters:**
- `:id` - Agent ID (e.g., `promo-assistant-reddit`)

**Example:**
```bash
curl http://127.0.0.1:3141/api/agent/promo-assistant-reddit
```

**Response:**
Full agent object with all heartbeats and statistics.

---

### GET /api/heartbeats
Query heartbeats with filters.

**Query Parameters:**
- `agent` - Filter by agent ID (optional)
- `limit` - Number of heartbeats to return (default: 10)
- `errors` - Set to `true` to only show heartbeats with errors
- `minCost` - Minimum cost threshold (e.g., `0.001`)

**Examples:**
```bash
# Get latest 5 heartbeats for Reddit agent
curl "http://127.0.0.1:3141/api/heartbeats?agent=promo-assistant-reddit&limit=5"

# Get heartbeats with errors
curl "http://127.0.0.1:3141/api/heartbeats?errors=true"

# Get expensive heartbeats (cost > $0.01)
curl "http://127.0.0.1:3141/api/heartbeats?minCost=0.01&limit=20"
```

**Response:**
```json
[
  {
    "agent": "promo-assistant-reddit",
    "agentName": "Reddit Assistant",
    "startTime": "2026-02-12T10:30:00Z",
    "endTime": "2026-02-12T10:31:45Z",
    "durationMs": 105000,
    "cost": 0.0234,
    "steps": 8,
    "errors": 0,
    "cacheHitRate": 75,
    "context": 48000,
    "summary": "Found 3 trending posts, commented on 2",
    "wasteFlags": []
  }
]
```

---

### GET /api/latest
Get the most recent heartbeat for a specific agent.

**Query Parameters:**
- `agent` - Agent ID (required)
- `errors_only` - Set to `true` to show only steps with errors (optional)

**Examples:**
```bash
# Get full latest heartbeat
curl "http://127.0.0.1:3141/api/latest?agent=promo-assistant-threads"

# Get only error steps from latest heartbeat
curl "http://127.0.0.1:3141/api/latest?agent=promo-assistant-threads&errors_only=true"
```

**Response:**
Full heartbeat object with all steps and details (or only error steps if filtered).

---

### GET /api/heartbeat
Get a specific heartbeat by index (matches UI hash navigation).

**Query Parameters:**
- `agent` - Agent ID (required)
- `index` or `hb` - Heartbeat index (0 = latest, 1 = second-to-latest, etc.)
- `errors_only` - Set to `true` to show only steps with errors (optional)

**Examples:**
```bash
# Get latest heartbeat (same as /api/latest)
curl "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&index=0"

# Get second-to-latest heartbeat (matches UI #agent=promo-assistant-reddit&hb=1)
curl "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&hb=1"

# Get third heartbeat, showing only error steps
curl "http://127.0.0.1:3141/api/heartbeat?agent=promo-assistant-reddit&index=2&errors_only=true"
```

**Response:**
Full heartbeat object with all steps and details (or only error steps if filtered).

When `errors_only=true`, the response includes:
- `filteredToErrors: true` - Indicates filtering is active
- `totalSteps` - Original total number of steps before filtering

**Note:** This endpoint uses the same indexing as the UI hash navigation:
- `http://127.0.0.1:3141/#agent=promo-assistant-reddit&hb=0` → `/api/heartbeat?agent=promo-assistant-reddit&hb=0`

---

### GET /api/budget
Get current budget status and projections.

**Example:**
```bash
curl http://127.0.0.1:3141/api/budget
```

**Response:**
```json
{
  "daily": 5.00,
  "monthly": 100.00,
  "todayCost": 2.34,
  "avg7Days": 3.12,
  "projectedMonthly": 93.60,
  "dailyPct": 47,
  "monthlyPct": 94,
  "status": "ok"
}
```

**Status values:**
- `ok` - Under 70% of daily budget
- `warning` - 70-90% of daily budget
- `over` - Over 90% of daily budget

---

### GET /api/daily
Get daily cost breakdown.

**Query Parameters:**
- `days` - Number of days to return (default: 7)

**Example:**
```bash
curl "http://127.0.0.1:3141/api/daily?days=14"
```

**Response:**
```json
[
  {
    "date": "2026-02-12",
    "cost": 2.34,
    "heartbeats": 45,
    "byAgent": {
      "promo-assistant-reddit": 0.89,
      "promo-assistant-threads": 1.45
    }
  }
]
```

---

### GET /api/stats
Get overall system statistics.

**Example:**
```bash
curl http://127.0.0.1:3141/api/stats
```

**Response:**
```json
{
  "totalAgents": 10,
  "totalCost": 45.67,
  "totalHeartbeats": 892,
  "totalErrors": 23,
  "avgCostPerHeartbeat": 0.0512,
  "budget": {...},
  "dailySummary": [...]
}
```

---

### GET /api/export
Export heartbeat data as CSV or JSON.

**Query Parameters:**
- `format` - `json` or `csv` (default: json)
- `days` - Number of days to export (default: 7)

**Examples:**
```bash
# Export last 7 days as CSV
curl "http://127.0.0.1:3141/api/export?format=csv" -o tokens.csv

# Export last 30 days as JSON
curl "http://127.0.0.1:3141/api/export?format=json&days=30" -o tokens.json
```

---

## Agent Usage Examples

### Check if agent should run (budget check)

```bash
#!/bin/bash
budget=$(curl -s http://127.0.0.1:3141/api/budget)
status=$(echo $budget | jq -r '.status')

if [ "$status" = "over" ]; then
  echo "Budget exceeded, skipping run"
  exit 1
fi
```

### Get latest heartbeat summary

```bash
curl -s "http://127.0.0.1:3141/api/latest?agent=promo-assistant-reddit" | jq '{
  cost: .totalCost,
  errors: .errorCount,
  duration: .durationMs,
  summary: .summary
}'
```

### Monitor error rate

```bash
errors=$(curl -s "http://127.0.0.1:3141/api/heartbeats?agent=promo-assistant-threads&limit=10&errors=true" | jq 'length')
echo "Recent errors: $errors"
```

### Track daily spending

```bash
curl -s "http://127.0.0.1:3141/api/daily?days=1" | jq '.[0] | {
  date,
  cost,
  heartbeats,
  agents: (.byAgent | keys)
}'
```
