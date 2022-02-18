#!/bin/sh

SCRIPT_CMD="/app/script.sh"

# If passed "manual", run script once ($1 = First argument passed).
if [ "$1" = "manual" ]; then
  echo "[$(date +"%F %r")] Running one-time."
  $SCRIPT_CMD
  exit 0
fi

# Add script to cron jobs.
echo "$CRON_TIME $SCRIPT_CMD" | crontab -
echo "[$(date +"%F %r")] Added script to cron jobs."

# Starts cronjob in foreground
echo "[$(date +"%F %r")] Running automatically (${CRON_TIME})."
crond -f
