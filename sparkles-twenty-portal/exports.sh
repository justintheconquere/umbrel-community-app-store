export APP_TWENTY_PORTAL_IP="10.21.31.10"
export APP_TWENTY_PORTAL_DB_IP="10.21.31.11"

# Secrets are generated once and persisted in this app's exports env file
# (same pattern as the official Monero app). Never commit real values.
TWENTY_PORTAL_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${TWENTY_PORTAL_ENV_FILE}" ]]; then
	GENERATED_DB_PASSWORD="$(openssl rand -hex 32)"
	GENERATED_NEXTAUTH_SECRET="$(openssl rand -hex 32)"
	{
		echo "export APP_TWENTY_PORTAL_DB_PASSWORD='${GENERATED_DB_PASSWORD}'"
		echo "export APP_TWENTY_PORTAL_NEXTAUTH_SECRET='${GENERATED_NEXTAUTH_SECRET}'"
	} > "${TWENTY_PORTAL_ENV_FILE}"
fi

. "${TWENTY_PORTAL_ENV_FILE}"
