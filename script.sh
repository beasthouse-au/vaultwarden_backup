#!/bin/sh

DATETIME=$(date +"%F_%H-%M-%S")
EXTENSION="tar.xz"
BACKUP_FOLDER="/backups"
BACKUP_FILE="$BACKUP_FOLDER/vaultwarden.${DATETIME}.${EXTENSION}"

APP_DATA="/mnt/user/appdata/vaultwarden"     # where the app is instaled at
DB="$APP_DATA/db.sqlite3"           # file
RSA="$APP_DATA/rsa_key*"            # files
CONFIG="$APP_DATA/config.json"      # file
ATTACHMENTS="$APP_DATA/attachments" # directory
SENDS="$APP_DATA/sends"             # directory

TMP_BACKUP="/tmp/bkp.db" # needs write permission

# Create a properly sqlite backup
sqlite3 $DB ".backup $TMP_BACKUP"

# Backup files and folders
# tar command explained
#    c = create a new archive
#    I = compression algorithm options
#        xz compresstion with multi-thread enabled (-T0)
#    f = specify file name
#    --transform = use sed replace EXPRESSION to transform files (inside the tar)
#        "s,<find>,<replace>," format
#        we are removing the "/tmp" ($TMPDIR) and "/appdata" ($APPDATA) from the archive
#        the goal is to make a flat archive
#    --absolute-names = don't strip leading '/'s from file names
#        it is needed to apply our transform sed rule
#    --ignore-failed-read = do not exit with nonzero on unreadable files
#        if something goes wrong it will not stop the tar, but you should always verify that
#    $VAR = chain of files (variables) to archieve
tar -cI "xz -T0" -f $BACKUP_FILE \
  --transform "s,$TMP_BACKUP,$DB,;s,$APP_DATA/,," \
  --absolute-names --ignore-failed-read \
  $TMP_BACKUP $RSA $CONFIG $ATTACHMENTS $SENDS

echo "New backup created \n$BACKUP_FILE"

# Check if should delete old backups
if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
  cd $BACKUP_FOLDER

  # Find all archives older than x days, store them in a variable, delete them
  TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
  find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

  if [ ! -z "$TO_DELETE" ]; then
    echo "Deleted $(echo "$TO_DELETE" | wc -l) archives older than $DELETE_AFTER days"
  else
    echo "No archives older than $DELETE_AFTER days to delete"
  fi
fi
