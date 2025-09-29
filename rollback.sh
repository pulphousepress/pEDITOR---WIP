#!/bin/bash
# rollback.sh - Replace modified files with backups created at la_peditor_backup/
BASEDIR="$(dirname "$0")"
BACKUP="/path/to/your/backup/la_peditor_backup" # EDIT THIS to your real backup path
if [ ! -d "$BACKUP" ]; then
  echo "Backup not found at $BACKUP. Aborting."
  exit 1
fi
echo "Restoring files from backup to $BASEDIR..."
cp -r "$BACKUP/." "$BASEDIR/"
echo "Restore complete."
