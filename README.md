# Sparkles — Justin's Umbrel Community App Store

A personal Umbrel Community App Store. Add it in umbrelOS:
**App Store → Community App Stores → add** `https://github.com/justintheconquere/umbrel-community-app-store`

Every app id is prefixed with the store id `sparkles`, each app lives in a
folder named exactly after its id, its listing is `<id>/umbrel-app.yml`, and
its services are in `<id>/docker-compose.yml`. Internal references follow
Umbrel's form — `app_proxy` points at `<app-id>_<service-name>_1`.

Nothing in this repo is installed automatically. Installing an app from the
store, on the machine, is always a manual step in the umbrelOS UI.

## Apps

| App | What it is | Exposure |
| --- | --- | --- |
| `sparkles-twenty` | Twenty CRM (v2.56.1) — replaces the Arcane deploy; see `docs/twenty-migration-runbook.md` | Umbrel auth / Tailscale only |
| `sparkles-twenty-portal` | Customer portal for Twenty (invite-only, own auth) | Public via Cloudflare Tunnel, after security review |
| `sparkles-backrest` | Backrest (restic) backups to the external 1TB USB drive | Umbrel auth only |
| `sparkles-btcpay-monero` | BTCPay Server, Monero only, for Voodoo Bazaar (`pay.voodoobazaar.com`) | Public via Cloudflare Tunnel, own auth |
| `sparkles-bitcart` | Bitcart, XMR-only, for side-by-side evaluation vs BTCPay | Public via Cloudflare Tunnel when testing |
| `sparkles-localai` | LocalAI v4.12.1, CUDA 13 backend baked in for the RTX 5090 | Umbrel auth only |
| `sparkles-chrome` | Real Chrome in the browser, persistent profile + downloads | Umbrel auth only |
| `sparkles-gluetun` | Gluetun VPN client + HTTP proxy for other apps to use | Umbrel auth only |
| `sparkles-simplex` | SimpleX SMP + XFTP relay (Tor + optional clearnet) | Direct ports / Tor |
| `sparkles-conduit` | Conduit Matrix homeserver (AssureBay portal) | Public via Cloudflare Tunnel, own protocol |
| `sparkles-strfry` | strfry Nostr relay (Voodoo Bazaar identity / Shopstr) | Public via Cloudflare Tunnel (wss) |
| `sparkles-goose` | Goose agent runtime, headless, pointed at LocalAI/Ollama | Umbrel auth only, never public |
| `sparkles-haveno` | Haveno client daemon (testing) | Tor P2P, API internal |
| `sparkles-haveno-seednode` | Haveno seed node (+ price node slot) for a private network | Tor P2P |
| `sparkles-arch-phosh` | Arch Linux + Phosh phone shell in the browser | Umbrel auth only |
| `sparkles-hello-world` | Template reference app (from the store template) | — |

Shared infrastructure is consumed, not duplicated: the BTCPay, Bitcart and
Haveno apps depend on the official Umbrel **Monero** app (its `exports.sh`
provides the node IP, RPC port and RPC login); LocalAI is the one GPU stack.

## Conventions

- Images are pinned to exact version tags (documented exceptions are marked
  `PIN EXCEPTION` / `VERIFY` in the compose file — clear those before
  installing that app).
- App data lives in `${APP_DATA_DIR}` bind mounts, never named volumes.
- Secrets are generated on the machine at first start by each app's
  `exports.sh` and persisted in the app data — never committed here.
- Custom images (`sparkles-localai`, `sparkles-arch-phosh`) are built by
  GitHub Actions from `docker/` and published to GHCR; they are never built
  on the Umbrel box.

## Validation

Every push runs `.github/workflows/validate.yml`, which checks manifest
shape, the `sparkles-` prefix, unique ports, image pinning and the
`app_proxy` host pattern. Run it locally with `python3 scripts/validate.py`.
