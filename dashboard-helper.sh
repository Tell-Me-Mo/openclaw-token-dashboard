#!/bin/bash
# Token Dashboard Helper Functions
# Source this file in your agent scripts: source ~/.openclaw/canvas/dashboard-helper.sh

DASHBOARD_API="http://127.0.0.1:3141/api"

# Check if budget is OK to run
# Returns 0 if OK, 1 if over budget
dashboard_check_budget() {
  local status=$(curl -s "$DASHBOARD_API/budget" | jq -r '.status // "error"')
  case "$status" in
    ok|warning) return 0 ;;
    over|error) return 1 ;;
  esac
}

# Get budget percentage used today
dashboard_budget_pct() {
  curl -s "$DASHBOARD_API/budget" | jq -r '.dailyPct // 0'
}

# Get latest heartbeat for agent
# Usage: dashboard_latest_hb "promo-assistant-reddit"
dashboard_latest_hb() {
  local agent_id="$1"
  curl -s "$DASHBOARD_API/latest?agent=$agent_id"
}

# Get specific heartbeat by index (0 = latest, 1 = second-to-latest, etc.)
# Usage: dashboard_get_hb "promo-assistant-reddit" 2
dashboard_get_hb() {
  local agent_id="$1"
  local index="${2:-0}"
  curl -s "$DASHBOARD_API/heartbeat?agent=$agent_id&index=$index"
}

# Get only error steps from latest heartbeat
# Usage: dashboard_latest_errors_only "promo-assistant-reddit"
dashboard_latest_errors_only() {
  local agent_id="$1"
  curl -s "$DASHBOARD_API/latest?agent=$agent_id&errors_only=true"
}

# Get only error steps from specific heartbeat
# Usage: dashboard_get_hb_errors "promo-assistant-reddit" 1
dashboard_get_hb_errors() {
  local agent_id="$1"
  local index="${2:-0}"
  curl -s "$DASHBOARD_API/heartbeat?agent=$agent_id&index=$index&errors_only=true"
}

# Get latest heartbeat cost
# Usage: dashboard_latest_cost "promo-assistant-reddit"
dashboard_latest_cost() {
  local agent_id="$1"
  curl -s "$DASHBOARD_API/latest?agent=$agent_id" | jq -r '.totalCost // 0'
}

# Get latest heartbeat error count
# Usage: dashboard_latest_errors "promo-assistant-reddit"
dashboard_latest_errors() {
  local agent_id="$1"
  curl -s "$DASHBOARD_API/latest?agent=$agent_id" | jq -r '.errorCount // 0'
}

# Get agent summary
# Usage: dashboard_agent_info "promo-assistant-reddit"
dashboard_agent_info() {
  local agent_id="$1"
  curl -s "$DASHBOARD_API/agent/$agent_id"
}

# Get recent heartbeats with errors
# Usage: dashboard_recent_errors "promo-assistant-reddit" 10
dashboard_recent_errors() {
  local agent_id="$1"
  local limit="${2:-10}"
  curl -s "$DASHBOARD_API/heartbeats?agent=$agent_id&errors=true&limit=$limit"
}

# Get expensive heartbeats (above threshold)
# Usage: dashboard_expensive_hbs 0.01 20
dashboard_expensive_hbs() {
  local min_cost="${1:-0.01}"
  local limit="${2:-10}"
  curl -s "$DASHBOARD_API/heartbeats?minCost=$min_cost&limit=$limit"
}

# Get today's cost
dashboard_today_cost() {
  curl -s "$DASHBOARD_API/daily?days=1" | jq -r '.[0].cost // 0'
}

# Get today's heartbeat count
dashboard_today_count() {
  curl -s "$DASHBOARD_API/daily?days=1" | jq -r '.[0].heartbeats // 0'
}

# Get all agents list
dashboard_list_agents() {
  curl -s "$DASHBOARD_API/agents"
}

# Get overall stats
dashboard_stats() {
  curl -s "$DASHBOARD_API/stats"
}

# Check if agent has recent errors (last 5 heartbeats)
# Returns 0 if no errors, 1 if errors found
dashboard_has_errors() {
  local agent_id="$1"
  local error_count=$(curl -s "$DASHBOARD_API/heartbeats?agent=$agent_id&errors=true&limit=5" | jq 'length')
  [ "$error_count" -gt 0 ] && return 1 || return 0
}

# Pretty print budget status
dashboard_budget_status() {
  local budget=$(curl -s "$DASHBOARD_API/budget")
  echo "Budget Status:"
  echo "  Today: \$$(echo $budget | jq -r '.todayCost') / \$$(echo $budget | jq -r '.daily') ($(echo $budget | jq -r '.dailyPct')%)"
  echo "  Projected Monthly: \$$(echo $budget | jq -r '.projectedMonthly') / \$$(echo $budget | jq -r '.monthly')"
  echo "  Status: $(echo $budget | jq -r '.status')"
}

# Pretty print agent stats
dashboard_agent_stats() {
  local agent_id="$1"
  local info=$(curl -s "$DASHBOARD_API/agent/$agent_id")
  echo "Agent: $(echo $info | jq -r '.name')"
  echo "  Total Cost: \$$(echo $info | jq -r '.totalCost')"
  echo "  Heartbeats: $(echo $info | jq -r '.heartbeats | length')"
  echo "  Errors: $(echo $info | jq -r '.totalErrors')"
  echo "  Cache Hit: $(echo $info | jq -r '.avgCacheHit')%"
  echo "  Context: $(echo $info | jq -r '.totalTokens') / $(echo $info | jq -r '.contextTokens')"
}

# Example usage guard
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  echo "Token Dashboard Helper Functions"
  echo "Usage: source $0"
  echo ""
  echo "Available functions:"
  echo "  dashboard_check_budget          - Check if budget allows running (exit 0 = OK)"
  echo "  dashboard_budget_pct            - Get budget % used today"
  echo "  dashboard_latest_hb AGENT       - Get latest heartbeat JSON"
  echo "  dashboard_get_hb AGENT INDEX    - Get specific heartbeat by index (0=latest)"
  echo "  dashboard_latest_errors_only AGENT - Get only error steps from latest heartbeat"
  echo "  dashboard_get_hb_errors AGENT INDEX - Get only error steps from specific heartbeat"
  echo "  dashboard_latest_cost AGENT     - Get latest heartbeat cost"
  echo "  dashboard_latest_errors AGENT   - Get latest heartbeat error count"
  echo "  dashboard_agent_info AGENT      - Get agent summary"
  echo "  dashboard_recent_errors AGENT [LIMIT] - Get recent error heartbeats"
  echo "  dashboard_expensive_hbs [MIN_COST] [LIMIT] - Get expensive heartbeats"
  echo "  dashboard_today_cost            - Get today's total cost"
  echo "  dashboard_today_count           - Get today's heartbeat count"
  echo "  dashboard_list_agents           - List all agents"
  echo "  dashboard_stats                 - Get overall statistics"
  echo "  dashboard_has_errors AGENT      - Check if agent has recent errors (exit 1 = yes)"
  echo "  dashboard_budget_status         - Pretty print budget status"
  echo "  dashboard_agent_stats AGENT     - Pretty print agent stats"
  echo ""
  echo "Example:"
  echo "  if dashboard_check_budget; then"
  echo "    echo 'Budget OK, running agent...'"
  echo "  else"
  echo "    echo 'Budget exceeded, skipping'"
  echo "  fi"
fi
