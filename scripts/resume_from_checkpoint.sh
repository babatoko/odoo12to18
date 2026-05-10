#!/bin/bash
# Script 9: Resume migration from checkpoint (OPTION B)
# Continues migration without re-executing completed end-migration scripts
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

echo "=== Resume Migration from Checkpoint ==="
echo "Date: $(date)"
echo ""
echo "This will resume migration from where it stopped,"
echo "without re-executing already completed end-migration scripts."
echo ""

read -p "Continue? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

LOGFILE="/logs/migration_v13_resume_$(date +%Y%m%d_%H%M%S).log"

echo "Resuming migration..."
echo "Logfile: $LOGFILE"

# Resume migration
docker exec odoo_migration python3 /opt/openupgrade/odoo-bin \
  -c /etc/odoo/odoo.conf \
  -d production_db \
  --stop-after-init \
  --log-level=info \
  2>&1 | tee "$LOGFILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Migration resumed and completed successfully"
    echo ""
    echo "Next: Analyze logs with ./scripts/analyze_migration_logs.sh $LOGFILE"
else
    echo "❌ Migration resume failed"
    echo "Review logs: $LOGFILE"
    exit $EXIT_CODE
fi
