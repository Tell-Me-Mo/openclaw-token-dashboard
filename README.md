# OpenClaw Trace

**End-to-end tracing and observability for OpenClaw multi-agent systems**

An extension for OpenClaw that provides comprehensive visibility into agent execution traces, token consumption, costs, and performance across all your agents.

![Dashboard Preview](https://img.shields.io/badge/OpenClaw-Extension-blue)

### Main Dashboard View
<img width="1541" height="921" alt="image" src="https://github.com/user-attachments/assets/3ccb1a4c-66a4-4ac3-af5a-651a3561f5ec" />


*Overview of agent performance with cost and context growth charts. Shows sidebar with all agents, stats cards, and expandable heartbeat rows.*

### Detailed Heartbeat Analysis
<img width="1531" height="664" alt="image" src="https://github.com/user-attachments/assets/f0ee25ec-27d5-428f-b698-b9d1efd79104" />


*Expanded heartbeat view showing cost per step, tool usage breakdown, cost breakdown, and detailed step-by-step execution with full tool call/result inspection.*

## Features

- 📊 **Real-time monitoring** - Live agent status, auto-refresh, cross-agent overview
- 💰 **Budget tracking** - Daily/monthly limits with projected costs and alerts
- 📈 **Historical analysis** - 7-day trends, per-heartbeat drill-down, context growth
- ⚡ **Optimization tools** - Cache hit rates, waste detection, actionable hints
- 🔍 **A/B comparison** - Side-by-side heartbeat comparison with delta calculations
- 🎛️ **Collapsible sidebar** - Toggle agent list for more screen space
- 📊 **Rich charts** - Cost, context, and tool usage visualizations
- 🔍 **Step inspection** - Full tool call/result details with expandable views
- 📤 **API access** - Programmatic access to all metrics via REST API

## Prerequisites

- **[OpenClaw](https://github.com/nicholasgriffintn/openclaw)** installed and configured at `~/.openclaw`
- **Node.js** v14+ (already required by OpenClaw)
- At least one agent session (`.jsonl` files in `~/.openclaw/agents/*/sessions/`)

## Quick Start

```bash
npx openclaw-trace
```

No installation needed — runs directly from npm on macOS, Linux, and Windows.

Open **http://localhost:3141** in your browser.

## Usage

```bash
npx openclaw-trace          # run in foreground
npx openclaw-trace --bg     # run as background daemon
npx openclaw-trace --stop   # stop background daemon
```

### Global Install (optional)

```bash
npm install -g openclaw-trace
openclaw-trace
openclaw-trace --bg
openclaw-trace --stop
```

### Navigation

- **Sidebar Toggle** - Click ☰ button to hide/show the agent sidebar for more screen space
- **Sidebar** - Click any agent to view its details
- **Overview** - Default view showing all agents and 7-day trend
- **Agent View** - Session cost, heartbeats, cache stats, and full drill-down
- **Compare Mode** - Click "Compare" button in header → select 2 heartbeats → view delta
- **API Buttons** - Each heartbeat has 📋 API and ⚠ API buttons to copy URLs for programmatic access

## API

REST API available at `http://localhost:3141/api/`:

| Endpoint | Description |
|---|---|
| `/api/agents` | List all agents with stats |
| `/api/agent/:id` | Get specific agent details |
| `/api/latest?agent=X` | Get latest heartbeat |
| `/api/heartbeat?agent=X&hb=N` | Get specific heartbeat by index |
| `/api/heartbeats?agent=X&errors=true` | Query heartbeats with filters |
| `/api/budget` | Get current budget status |
| `/api/daily?days=N` | Get daily cost breakdown |
| `/api/stats` | Overall system statistics |

Add `&errors_only=true` to any heartbeat endpoint to get only steps with errors.

See [API.md](API.md) for complete documentation.

## Configuration

### Budget Settings

Create `~/.openclaw/canvas/budget.json`:

```json
{
  "daily": 10.00,
  "monthly": 200.00
}
```

### Port Configuration

To change the default port (3141), edit `openclaw-trace.js`:

```javascript
const PORT = 3141;  // Change to your preferred port
```

## How It Works

The dashboard reads OpenClaw's session JSONL files from:
```
~/.openclaw/agents/*/sessions/sessions.json
~/.openclaw/agents/*/sessions/*.jsonl
```

It parses:
- Token usage (`input`, `output`, `cacheRead`, `cacheWrite`)
- Costs per step (from Claude API usage metadata)
- Tool calls (browser, read, write, bash, etc.)
- Errors and timing data

**No external dependencies** — single file, pure Node.js stdlib + embedded HTML/CSS/JS.

## Troubleshooting

### Dashboard won't start
```bash
npx openclaw-trace --stop   # stop any existing instance
npx openclaw-trace           # start fresh
```

### No data showing
- Ensure OpenClaw agents have run at least once
- Check `~/.openclaw/agents/*/sessions/` contains `.jsonl` files
- Verify `~/.openclaw/openclaw.json` exists with agent definitions

### Budget bar not showing
- Create `~/.openclaw/canvas/budget.json` with valid JSON
- Ensure at least one heartbeat exists for today

## Contributing

Contributions welcome! Please open an issue or PR at https://github.com/Tell-Me-Mo/openclaw-trace

## License

MIT License - see [LICENSE](LICENSE) for details.
