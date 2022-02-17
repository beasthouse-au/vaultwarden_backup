#!/bin/sh

SCRIPT_CMD="./script.sh"
LOGS_FILE="./log.log"

# If passed "manual", run script once ($1 = First argument passed).
if [ "$1" = "manual" ]; then
  echo "[$(date +"%F %r")] Running one-time."
  $SCRIPT_CMD
  exit 0
fi

# Clear cron jobs.
echo "" | crontab -
echo "[$(date +"%F %r")] Cron jobs cleared."

# Add script to cron jobs.
(crontab -l 2>/dev/null; echo "$CRON_TIME $SCRIPT_CMD >> $LOGS_FILE 2>&1") | crontab -
echo "[$(date +"%F %r")] Added script to cron jobs."

# Keeps terminal open and writes logs.
echo "[$(date +"%F %r")] Running automatically (${CRON_TIME})." > "$LOGS_FILE"
tail -F "$LOGS_FILE"
