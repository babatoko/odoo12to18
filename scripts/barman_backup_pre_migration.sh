#!/bin/bash
# Script 4: Create pre-migration backup with Barman
# Uses infrastructure on production-consolidation
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Barman Pre-Migration Backup ==="
echo "Date: $(date)"

BACKUP_NAME="pre_migration_v13_$(date +%Y%m%d_%H%M%S)"

# Create backup via Barman on production-consolidation
echo "Creating backup: $BACKUP_NAME"
ssh production-consolidation "barman backup odoo_server --name='$BACKUP_NAME'"

# Show backup details
echo "Backup created, showing details..."
ssh production-consolidation "barman show-backup odoo_server latest"

echo "✅ Pre-migration backup completed"
echo "  Backup name: $BACKUP_NAME"
echo "  Location: production-consolidation (Barman)"
