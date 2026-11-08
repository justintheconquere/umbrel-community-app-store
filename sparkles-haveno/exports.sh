export APP_HAVENO_DAEMON_IP="10.21.42.10"
export APP_HAVENO_WEB_IP="10.21.42.11"

# Generate the Haveno daemon API password once and persist it, following
# the same pattern the stock Monero app uses for its RPC credentials:
# values are written to a .env file in the app's exports/data dir and
# re-read on every subsequent start, so the password is stable across
# restarts and updates.
HAVENO_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${HAVENO_ENV_FILE}" ]]; then
	if [[ -z "${APP_HAVENO_API_PASSWORD:-}" ]]; then
		APP_HAVENO_API_PASSWORD=$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)
	fi

	echo "export APP_HAVENO_API_PASSWORD='${APP_HAVENO_API_PASSWORD}'" > "${HAVENO_ENV_FILE}"
fi

. "${HAVENO_ENV_FILE}"

export APP_HAVENO_API_PASSWORD
