#!/bin/bash
# Script 8: Fix and retry specific module (OPTION A)
# Reruns migration for a specific module after fixing data
#
# Usage: ./fix_and_retry_module.sh <module_name>
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

if [ -z "$1" ]; then
    echo "Usage: $0 <module_name>"
    echo "Example: $0 account"
    echo ""
    echo "Before running this script:"
    echo "1. Identify the module with errors in logs"
    echo "2. Fix the data issues (SQL corrections)"
    echo "3. Then rerun migration for this module only"
    exit 1
fi

MODULE_NAME="$1"

echo "=== Fix and Retry Module: $MODULE_NAME ==="
echo "Date: $(date)"
echo ""
echo "⚠️  Make sure you have fixed the data issues before continuing!"
read -p "Have you fixed the data issues? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "Aborted. Fix data issues first, then run this script again."
    exit 1
fi

LOGFILE="/logs/migration_v13_retry_${MODULE_NAME}_$(date +%Y%m%d_%H%M%S).log"

echo "Retrying migration for module: $MODULE_NAME"
echo "Logfile: $LOGFILE"

# Retry migration for specific module
docker exec odoo_migration python3 /opt/openupgrade/odoo-bin \
  -c /etc/odoo/odoo.conf \
  -d production_db \
  -u "$MODULE_NAME" \
  --stop-after-init \
  --log-level=info \
  2>&1 | tee "$LOGFILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Module $MODULE_NAME migration completed successfully"
    echo ""
    echo "Next: Check if other modules need fixing, or proceed to Phase B"
else
    echo "❌ Module $MODULE_NAME migration failed"
    echo "Review logs: $LOGFILE"
    exit $EXIT_CODE
fi
