BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CONTAINER_NAME="kti_mysql"
DB_USER="root"
ENV_FILE="./.env.docker"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env.docker not found. Cannot determine database password."
    exit 1
fi

DB_PASS=$(grep -oP '^DB_ROOT_PASSWORD=\K.*' $ENV_FILE | tr -d '"')

if [ -z "$DB_PASS" ]; then
    echo "Error: DB_ROOT_PASSWORD not set in .env.docker"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/kti_backup_${TIMESTAMP}.sql"

echo "Starting database backup to ${BACKUP_FILE}..."

docker exec $CONTAINER_NAME mysqldump -u$DB_USER -p$DB_PASS --all-databases > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
    
    echo "Cleaning up backups older than 7 days..."
    find "$BACKUP_DIR" -type f -name "kti_backup_*.sql" -mtime +7 -exec rm {} \;
else
    echo "Backup failed!"
    rm -f "$BACKUP_FILE"
    exit 1
fi
