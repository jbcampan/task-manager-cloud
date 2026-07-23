#!/bin/sh
set -e

DB_PASSWORD_ENCODED=$(node -e "console.log(encodeURIComponent(process.env.DB_PASSWORD))")

export DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD_ENCODED}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

exec node dist/main.js