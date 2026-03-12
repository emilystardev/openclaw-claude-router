# Claude Code Router

A lightweight local proxy that routes [Claude Code](https://docs.anthropic.com/en/claude-code) API requests to [OpenRouter](https://openrouter.ai), letting you use free or alternative model backends instead of Anthropic's API directly.

## How It Works

```
Claude Code → http://127.0.0.1:3456 → OpenRouter → model of your choice
```

Claude Code thinks it's talking to the Anthropic API. The router intercepts requests and forwards them to OpenRouter, injecting your OpenRouter API key.

## Prerequisites

- Node.js 18+
- An [OpenRouter API key](https://openrouter.ai/keys) (free tier available)

## Setup

```bash
# 1. Clone the repo
git clone https://github.com/emilystardev/openclaw-claude-router
cd openclaw-claude-router

# 2. Add your API key
cp .env.example .env
# Edit .env and set OPENROUTER_API_KEY=sk-or-v1-...

# 3. Start the proxy
bash start.sh

# 4. Point Claude Code at the proxy
export ANTHROPIC_API_KEY="any-string-is-ok"
export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"

# 5. Run Claude Code normally
claude
```

## Model Routing

Edit `config.json` to control which OpenRouter model handles each task category:

| Category | Default Model |
|----------|---------------|
| default / coding / strong | `qwen/qwen3-coder-480b-a35b-instruct:free` |
| fast / debug | `stepfun/step-3.5-flash:free` |
| thinking | `openai/gpt-oss-120b:free` |
| search / planning | `nvidia/nemotron-3-super:free` |
| review | `qwen/qwen3-coder-32b:free` |

The `cascade` list is the fallback chain if the primary model is unavailable.

See [OpenRouter models](https://openrouter.ai/models) for the full list of available models.

## Management

```bash
bash start.sh    # Start the proxy in background
bash stop.sh     # Stop the proxy
bash status.sh   # Check status and view quick actions

tail -f ~/.claude-code-router/proxy.log  # Live logs
```

## OpenClaw Integration

If you're using OpenClaw, add this to your `openclaw.json`:

```json
"env": {
  "ANTHROPIC_AUTH_TOKEN": "any-string",
  "ANTHROPIC_BASE_URL": "http://127.0.0.1:3456"
}
```

## Security Notes

- The proxy binds to `127.0.0.1` only — not exposed to the network
- Never commit your `.env` file (it's in `.gitignore`)
- Rotate your OpenRouter key at [openrouter.ai/keys](https://openrouter.ai/keys) if compromised

## License

MIT
