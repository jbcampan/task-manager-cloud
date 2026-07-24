#!/bin/sh
set -e

DB_PASSWORD_ENCODED=$(node -e "console.log(encodeURIComponent(process.env.DB_PASSWORD))")

export DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD_ENCODED}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

# No arguments: start the server as usual (ECS service).
# Arguments given: run them instead (used for one-off ECS tasks, e.g.
# Prisma migrations, via the "command" override in a RunTask call).
if [ "$#" -eq 0 ]; then
  exec node dist/main.js
else
  exec "$@"
fi