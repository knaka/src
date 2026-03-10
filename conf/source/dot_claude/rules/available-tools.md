# Available CLI Tools

The following tools are installed via Mise and available on PATH:

## Data / Text Processing
- `jq` — JSON processor
- `yq` — YAML/JSON processor
- `yj` — YAML/TOML/JSON/HCL converter
- `fx` — Interactive JSON viewer
- `htmlq` — HTML processor (like jq for HTML)

## Development
- `gh` — GitHub CLI
- `rg` (ripgrep) — Fast grep
- `fd` — Fast find
- `bat` — cat with syntax highlighting
- `delta` — Enhanced git diff viewer
- `shellcheck` — Shell script linter

## Runtimes
- `node` (v24), `npm`, `npx`
- `python` (3.14), `pip`

## Instructions

If a task would benefit from a common CLI tool not listed above, suggest installing it to the user via Mise (e.g., `mise use -g <tool>`).
