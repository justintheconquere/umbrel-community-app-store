export APP_BITCART_IP="10.21.34.10"
export APP_BITCART_API_IP="10.21.34.11"
export APP_BITCART_WORKER_IP="10.21.34.12"
export APP_BITCART_DAEMON_XMR_IP="10.21.34.13"
export APP_BITCART_ADMIN_IP="10.21.34.14"
export APP_BITCART_STORE_IP="10.21.34.15"
export APP_BITCART_DB_IP="10.21.34.16"
export APP_BITCART_REDIS_IP="10.21.34.17"
export APP_BITCART_PORT="3001"
# Internal JSON-RPC port of Bitcart's XMR daemon service (the api/worker
# services talk to the daemon here; it is never published on the host).
# VERIFY: XMR daemon default port in Bitcart 0.10.x (per-coin daemon ports
# are assigned sequentially in daemons/base.py).
export APP_BITCART_XMR_DAEMON_PORT="5005"

# Secrets are generated on first run and persisted in this app's exports env
# file (same pattern as the official Monero app). No real secrets live in the
# app store repo. Note: Bitcart has no env-based admin account — the admin
# user is created in the UI on first run and registration then auto-disables.
APP_BITCART_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${APP_BITCART_ENV_FILE}" ]]; then
	if [[ -z ${APP_BITCART_DB_PASSWORD+x} ]]; then
		APP_BITCART_DB_PASSWORD="$(openssl rand -hex 24)"
	fi
	if [[ -z ${APP_BITCART_DAEMON_RPC_PASSWORD+x} ]]; then
		APP_BITCART_DAEMON_RPC_PASSWORD="$(openssl rand -hex 24)"
	fi

	{
		echo "export APP_BITCART_DB_PASSWORD='${APP_BITCART_DB_PASSWORD}'"
		echo "export APP_BITCART_DAEMON_RPC_PASSWORD='${APP_BITCART_DAEMON_RPC_PASSWORD}'"
	} > "${APP_BITCART_ENV_FILE}"
fi

. "${APP_BITCART_ENV_FILE}"
