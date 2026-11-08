export APP_TWENTY_IP="10.21.30.10"
export APP_TWENTY_DB_IP="10.21.30.11"
export APP_TWENTY_REDIS_IP="10.21.30.12"
export APP_TWENTY_WORKER_IP="10.21.30.13"

# Secrets are generated once and persisted in this app's exports env file
# (same pattern as the official Monero app). Never commit real values.
TWENTY_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${TWENTY_ENV_FILE}" ]]; then
	GENERATED_APP_SECRET="$(openssl rand -hex 32)"
	GENERATED_DB_PASSWORD="$(openssl rand -hex 32)"
	{
		echo "export APP_TWENTY_APP_SECRET='${GENERATED_APP_SECRET}'"
		echo "export APP_TWENTY_DB_PASSWORD='${GENERATED_DB_PASSWORD}'"
	} > "${TWENTY_ENV_FILE}"
fi

. "${TWENTY_ENV_FILE}"
