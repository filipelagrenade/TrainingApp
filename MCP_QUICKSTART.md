# MCP Quick Start (Serena + Context7 + shadcn)

## 1) Serena

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.serena]
command = "uvx"
args = ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "codex"]
```

Restart Codex, then run:
- `serena.activate_project`
- `serena.check_onboarding_performed`
- `serena.initial_instructions`

---

## 2) Context7

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
```

Restart Codex.
Use Context7 for official documentation lookups when required.

---

## 3) shadcn MCP (`web/` only)

```toml
[mcp_servers.shadcn-ui]
command = "npx"
args = ["shadcn@latest", "mcp"]
```

Ensure `components.json` has a registry configured.

Restart Codex.

---

## Verify MCP Servers

```bash
codex mcp list
```
