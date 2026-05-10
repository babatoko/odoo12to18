#!/bin/bash
# Script 4: Create pre-migration backup with Barman
# Uses infrastructure on 178.105.49.214
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Barman Pre-Migration Backup ==="
echo "Date: $(date)"

BACKUP_NAME="pre_migration_v13_$(date +%Y%m%d_%H%M%S)"

# Create backup via Barman on 178.105.49.214
echo "Creating backup: $BACKUP_NAME"
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman backup odoo-production --name='$BACKUP_NAME'"

# Show backup details
echo "Backup created, showing details..."
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman show-backup odoo-production latest"

echo "✅ Pre-migration backup completed"
echo "  Backup name: $BACKUP_NAME"
echo "  Location: 178.105.49.214 (Barman)"
