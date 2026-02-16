# MCP Quick Start (Serena + Context7 + shadcn)

## 1) Serena

Add to ~/.codex/config.toml:

[mcp_servers.serena]
command = "uvx"
args = ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "codex"]

Restart Codex.
Then run activation sequence:
- serena.activate_project
- serena.check_onboarding_performed
- serena.initial_instructions

---

## 2) Context7

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]

Restart Codex.
Use for official documentation lookups.

---

## 3) shadcn MCP (apps/web only)

[mcp_servers.shadcn-ui]
command = "npx"
args = ["shadcn@latest", "mcp"]

Ensure components.json has registry configured.

Restart Codex.

---

Verify MCPs using:
codex mcp list
