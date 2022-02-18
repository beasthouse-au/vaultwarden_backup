#!/bin/sh

DATETIME=$(date +"%F_%H-%M-%S")
EXTENSION="tar.xz"
BACKUP_FILE="/backups/${DATETIME}.${EXTENSION}"
TMP_BACKUP="/tmp/bkp.db" # needs write permission

DB="/data/db.sqlite3" # file
RSA="/data/rsa_key*" # files
CONFIG="/data/config.json" # file
ATTACHMENTS="/data/attachments" # directory
SENDS="/data/sends" # directory

# Create a properly sqlite backup
sqlite3 $DB ".backup $TMP_BACKUP"

# Backup files and folders
tar -caf $BACKUP_FILE \
  --transform "s,$TMP_BACKUP,$DB,;s,/data/,," \
  --absolute-names --ignore-failed-read \
  $TMP_BACKUP $RSA $CONFIG $ATTACHMENTS $SENDS

OUTPUT="${OUTPUT}New backup created"

# Check if should delete old backups
if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
  cd /backups

  # Find all archives older than x days, store them in a variable, delete them
  TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
  find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

  OUTPUT="${OUTPUT}, $([ ! -z "$TO_DELETE" ] \
    && echo "deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days" \
    || echo "no archives older than ${DELETE_AFTER} days to delete")"
fi

echo "[$(date +"%F %r")] ${OUTPUT}."
