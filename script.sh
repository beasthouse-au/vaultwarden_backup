#!/bin/sh

cd /data || { echo "Failed to enter folder '/data'"; exit 1; }

DATETIME=$(date +"%F_%H-%M-%S")
EXTENSION="tar.xz"
BACKUP_LOCATION="/backups/${DATETIME}.${EXTENSION}"

DB="db-${DATETIME}.sqlite3" # file
RSA="rsa_key*" # files
CONFIG="config.json" # file
ATTACHMENTS="attachments" # directory
SENDS="sends" # directory

# Create a properly sqlite backup
sqlite3 db.sqlite3 ".backup ${DB}"

# Back up files and folders.
tar caf $BACKUP_LOCATION $DB $RSA $CONFIG $ATTACHMENTS $SENDS 2>/dev/null
OUTPUT="${OUTPUT}New backup created"

# Check if should delete old backups
if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
  cd /backups

  # Find all archives older than x days, store them in a variable, delete them.
  TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
  find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

  OUTPUT="${OUTPUT}, $([ ! -z "$TO_DELETE" ] \
    && echo "deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days" \
    || echo "no archives older than ${DELETE_AFTER} days to delete")"
fi

echo "[$(date +"%F %r")] ${OUTPUT}."
