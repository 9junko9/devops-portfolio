#!/usr/bin/env bash
# Script de sauvegarde PostgreSQL
set -euo pipefail


TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DB_NAME}_${TIMESTAMP}.sql"

PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"
echo "Sauvegarde enregistrée dans $BACKUP_FILE"
