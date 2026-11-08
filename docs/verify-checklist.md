# Pre-install VERIFY checklist

Every app in this store was packaged and validated in the repo (manifests,
ports, pinning, compose structure). The items below could **not** be fully
verified without installing, which this repo deliberately never does —
clear the items for an app before installing that app. Each item is also
marked `VERIFY` inline in the file it concerns.

## All apps
- Secrets are generated on the box by `exports.sh` at first start; confirm
  the app's `.env` appeared in its data dir and contains values.
- Dependent apps read the Monero app's exports (`APP_MONERO_NODE_IP`,
  `APP_MONERO_RPC_PORT`, `APP_MONERO_RPC_USER`, `APP_MONERO_RPC_PASS`).
  Confirm those variable names exist on the installed Monero app version;
  if only the combined `APP_MONERO_RPC_AUTH` is exposed, split it into
  user:pass where the compose files say so.

## sparkles-twenty
- Worker command `yarn worker:prod` follows the official compose; watch
  first-start logs.
- Migration: follow `docs/twenty-migration-runbook.md`; Arcane DinD volume
  paths are marked VERIFY-ON-BOX there.

## sparkles-twenty-portal
- **Image coordinates unverified**: `ghcr.io/lilremark/twentycrmclientportal:v2.0.0`.
  Upstream may publish elsewhere or require building from source.
- Set a real `NEXTAUTH_URL` domain before any public exposure; security
  review before customer data (third-party code, invite-only auth is the
  only gate).

## sparkles-btcpay-monero
- BTCPay pinned to **2.4.7** on purpose: ≤2.4.1 carries CVE-2026-119757
  (hot-wallet drain, fixed in 2.4.2).
- Verify the exact current tag of `btcpayserver/monero` (0.18.5.1 used)
  and the tx-notify callback script path inside it (`/monero/on-new-tx.sh`).
- Wallet RPC logs in to the node with user:pass from the Monero exports
  (NOT the hashed rpcauth string in `APP_MONERO_RPC_AUTH`).
- After install: point `pay.voodoobazaar.com` in the existing cloudflared
  tunnel to `localhost:23000`, create the admin account immediately, then
  install plugins (Monero, Vendor Pay, FileSeller, Dynamic Reports,
  Nostr/Shopstr, ServerMessage) from the BTCPay plugin UI.

## sparkles-bitcart
- `just` task names in the 0.10.2.0 image (`just api`, `just worker`,
  `just daemon xmr`); whether it reads `BITCART_CRYPTOS` or
  `ENABLED_CRYPTOS` (both are set); `ROOT_PATH` for the /api subpath.
- XMR daemon default port (5005 assumed via one shared env var — one-line
  fix if wrong) and whether the XMR daemon accepts credentials embedded
  in `XMR_SERVER`. Never fall back to a public node.
- Admin/store image tags (0.8.0.0) and internal port (80 assumed); Caddy
  subpath routing for the admin SPA vs Bitcart's official proxy.

## sparkles-localai
- Dockerfile: verify the exact quay.io tag for the v4.12.1 CUDA 13 ffmpeg
  variant, and that the CPU backend's glibc loader is findable in the
  image (the build fails loudly if not — a failed CI run is the check).
- After the GHCR image exists, install and benchmark against the known
  numbers (~140 tok/s qwen3.8; ~1s long-prompt) before swapping endpoints.

## sparkles-chrome
- Verify `lscr.io/linuxserver/chrome:142.0.7444.175` exists (fallback:
  linuxserver/chromium).

## sparkles-gluetun
- Verify `qmcgaw/gluetun:v3.40.0`. WireGuard key + addresses are empty
  placeholders by design — set them on the box only, never in this repo.

## sparkles-simplex
- Verify `simplexchat/smp-server` / `xftp-server` v6.4.1 tags (latest v6.x),
  the `-init` flag syntax, the ini password key, and the XFTP data path.

## sparkles-conduit
- Verify the Docker Hub tag format `matrixconduit/matrix-conduit:v0.10.15`
  (v-prefix uncertain).
- Set `CONDUIT_SERVER_NAME` to the real domain BEFORE first start — a
  Matrix server name can never be changed afterwards.

## sparkles-strfry
- `dockurr/strfry` is `:latest` (documented PIN EXCEPTION — upstream has
  no version tags). Pin by digest at first install.
- Enable the write-policy npub allowlist in `strfry.conf` before routing
  the public wss hostname to it.

## sparkles-goose (experimental)
- Verify against current aaif-goose/goose releases: version (v1.16.0
  used), musl asset name, archive layout, `goose serve` flags.

## sparkles-haveno / sparkles-haveno-seednode (experimental)
- **Biggest open item in the store:** upstream publishes no amd64 image.
  The only daemon image (`havenodex/haveno-daemon`, digest-pinned in the
  compose) is ARM64-only (2024-10). An amd64 image likely has to be built
  from haveno-dex/haveno or haveno-reto source and both compose files
  re-pinned — treat these two apps as scaffolding until then.
- Seednode binary presence (`haveno-seednode`) and price node image are
  unverified; the price node service ships disabled on purpose.
- Confirm which network the final image joins (upstream defaults to
  stagenet; the live network is RetoSwap) before any funds.
- Check current Haveno/RetoSwap security releases before real funds.

## sparkles-arch-phosh (experimental)
- Verify/pin the `theasp/novnc` tag (currently `:latest` with a PIN
  EXCEPTION note) and phoc's session config path in current Arch packages.
