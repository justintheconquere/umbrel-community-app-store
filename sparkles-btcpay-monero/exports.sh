export APP_BTCPAY_MONERO_IP="10.21.33.10"
export APP_BTCPAY_MONERO_DB_IP="10.21.33.11"
export APP_BTCPAY_MONERO_WALLET_IP="10.21.33.12"
export APP_BTCPAY_MONERO_PORT="23000"

# Secrets are generated on first run and persisted in this app's exports env
# file (same pattern as the official Monero app). No real secrets live in the
# app store repo.
APP_BTCPAY_MONERO_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${APP_BTCPAY_MONERO_ENV_FILE}" ]]; then
	if [[ -z ${APP_BTCPAY_MONERO_DB_PASSWORD+x} ]]; then
		APP_BTCPAY_MONERO_DB_PASSWORD="$(openssl rand -hex 24)"
	fi

	echo "export APP_BTCPAY_MONERO_DB_PASSWORD='${APP_BTCPAY_MONERO_DB_PASSWORD}'" > "${APP_BTCPAY_MONERO_ENV_FILE}"
fi

. "${APP_BTCPAY_MONERO_ENV_FILE}"
