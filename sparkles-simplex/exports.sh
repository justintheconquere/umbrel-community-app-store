export APP_SIMPLEX_SMP_IP="10.21.38.10"
export APP_SIMPLEX_XFTP_IP="10.21.38.11"
export APP_SIMPLEX_TOR_IP="10.21.38.12"
export APP_SIMPLEX_WEB_IP="10.21.38.13"

# Generated once, persisted in this app's exports env file, and reused on
# every start after that. This is the password to document into
# smp-server.ini (key: password, [AUTH] section) so the relay stays private.
APP_SIMPLEX_ENV_FILE="${EXPORTS_APP_DIR}/.env"

if [[ ! -f "${APP_SIMPLEX_ENV_FILE}" ]]; then
	APP_SIMPLEX_SMP_PASSWORD=$(openssl rand -hex 16)

	echo "export APP_SIMPLEX_SMP_PASSWORD='${APP_SIMPLEX_SMP_PASSWORD}'" > "${APP_SIMPLEX_ENV_FILE}"
fi

. "${APP_SIMPLEX_ENV_FILE}"
