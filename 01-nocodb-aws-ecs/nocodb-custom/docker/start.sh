#!/bin/sh

echo "Starting NocoDB in production mode..."

exec pnpm --filter=nocodb start
