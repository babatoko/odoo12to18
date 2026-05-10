#!/bin/bash
# Script 6: Run Phase A - OpenUpgrade Migration
# Uses OpenUpgrade fork to migrate from v12 to v13
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Phase A: OpenUpgrade Migration v12→v13 ==="
echo "Date: $(date)"

LOGFILE="./logs/migration_v13_phase_a_$(date +%Y%m%d_%H%M%S).log"
mkdir -p ./logs

echo "Starting migration with OpenUpgrade fork..."
echo "Logfile: $LOGFILE"

# Run migration with OpenUpgrade
docker exec odoo_migration python3 /opt/openupgrade/odoo-bin \
  -c /etc/odoo/odoo.conf \
  -d entretien-maconnais \
  -u all \
  --stop-after-init \
  --log-level=info \
  2>&1 | tee "$LOGFILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Phase A migration completed successfully"
    echo "  Logfile: $LOGFILE"
    echo ""
    echo "Next: Run ./scripts/analyze_migration_logs.sh $LOGFILE"
else
    echo "❌ Phase A migration failed with exit code $EXIT_CODE"
    echo "  Logfile: $LOGFILE"
    echo ""
    echo "Next: Analyze logs to identify errors"
    exit $EXIT_CODE
fi
