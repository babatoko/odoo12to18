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
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman backup odoo-production --name='$BACKUP_NAME'"

# Show backup details
echo ""
echo "Showing backup details..."
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman show-backup odoo-production latest"

# Verify Barman status
echo ""
echo "Verifying Barman status..."
ssh -i ~/.ssh/hetzner_cpx41_key root@178.105.49.214 "barman check odoo-production"

echo ""
echo "✅ Validated checkpoint created"
echo "  Checkpoint name: $BACKUP_NAME"
echo "  Location: 178.105.49.214 (Barman)"
echo ""
echo "Migration v12→v13 is now complete and validated!"
