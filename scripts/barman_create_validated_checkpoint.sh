#!/bin/bash
# Script 13: Create validated checkpoint with Barman
# ONLY run after board validation ("v13 OK")
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Barman Create Validated Checkpoint ==="
echo "Date: $(date)"
echo ""
echo "⚠️  This should ONLY be run AFTER board validation!"
echo ""

read -p "Has the board validated v13? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "Aborted. Wait for board validation before creating checkpoint."
    exit 1
fi

BACKUP_NAME="v13_validated_$(date +%Y%m%d)"

# Create validated checkpoint via Barman
echo "Creating validated checkpoint: $BACKUP_NAME"
ssh production-consolidation "barman backup odoo_server --name='$BACKUP_NAME'"

# Show backup details
echo ""
echo "Showing backup details..."
ssh production-consolidation "barman show-backup odoo_server latest"

# Verify Barman status
echo ""
echo "Verifying Barman status..."
ssh production-consolidation "barman check odoo_server"

echo ""
echo "✅ Validated checkpoint created"
echo "  Checkpoint name: $BACKUP_NAME"
echo "  Location: production-consolidation (Barman)"
echo ""
echo "Migration v12→v13 is now complete and validated!"
