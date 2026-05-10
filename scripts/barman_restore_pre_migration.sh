#!/bin/bash
# Script 5: Restore pre-migration backup with Barman
# Used in case of rollback needed (OPTION C)
#
# Usage: ./barman_restore_pre_migration.sh <backup_id>
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_id>"
    echo ""
    echo "To find backup_id, run:"
    echo "  ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 'barman list-backup odoo-production | grep pre_migration_v13'"
    exit 1
fi

BACKUP_ID="$1"
TARGET_PATH="/var/lib/postgresql/13/migration_v13"

echo "=== Barman Restore Pre-Migration Backup ==="
echo "Date: $(date)"
echo "Backup ID: $BACKUP_ID"
echo "Target path: $TARGET_PATH"

# Restore via Barman
echo "Restoring backup..."
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman recover odoo-production $BACKUP_ID $TARGET_PATH --remote-ssh-command 'ssh postgres@odoo_migration_server'"

echo "✅ Backup restored successfully"
echo "  Backup ID: $BACKUP_ID"
echo "  Restored to: $TARGET_PATH"
