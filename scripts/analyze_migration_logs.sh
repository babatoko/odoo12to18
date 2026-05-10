#!/bin/bash
# Script 7: Analyze migration logs
# Parse logs to identify errors and modules with issues
#
# Usage: ./analyze_migration_logs.sh <logfile>
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

if [ -z "$1" ]; then
    echo "Usage: $0 <logfile>"
    echo "Example: $0 /logs/migration_v13_phase_a_20260510_100000.log"
    exit 1
fi

LOGFILE="$1"

if [ ! -f "$LOGFILE" ]; then
    echo "Error: Logfile not found: $LOGFILE"
    exit 1
fi

echo "=== Analyzing Migration Logs ==="
echo "Logfile: $LOGFILE"
echo ""

# Count errors
echo "--- Error Summary ---"
ERROR_COUNT=$(grep -i "ERROR" "$LOGFILE" | wc -l)
WARNING_COUNT=$(grep -i "WARNING" "$LOGFILE" | wc -l)
CRITICAL_COUNT=$(grep -i "CRITICAL" "$LOGFILE" | wc -l)

echo "CRITICAL: $CRITICAL_COUNT"
echo "ERROR: $ERROR_COUNT"
echo "WARNING: $WARNING_COUNT"
echo ""

# Show critical errors
if [ $CRITICAL_COUNT -gt 0 ]; then
    echo "--- Critical Errors ---"
    grep -i "CRITICAL" "$LOGFILE" | head -20
    echo ""
fi

# Show errors by module
if [ $ERROR_COUNT -gt 0 ]; then
    echo "--- Errors by Module ---"
    grep -i "ERROR" "$LOGFILE" | grep -oP "odoo\.addons\.\K[^\.:]+" | sort | uniq -c | sort -rn | head -10
    echo ""
fi

# Show recent errors
if [ $ERROR_COUNT -gt 0 ]; then
    echo "--- Recent Errors (last 10) ---"
    grep -i "ERROR" "$LOGFILE" | tail -10
    echo ""
fi

# Recommendations
echo "--- Recommendations ---"
if [ $CRITICAL_COUNT -gt 0 ] || [ $ERROR_COUNT -gt 10 ]; then
    echo "⚠️  Significant errors detected!"
    echo ""
    echo "Options:"
    echo "  A. Fix specific module: ./scripts/fix_and_retry_module.sh <module_name>"
    echo "  B. Resume from checkpoint: ./scripts/resume_from_checkpoint.sh"
    echo "  C. Rollback and restart: ./scripts/barman_restore_pre_migration.sh <backup_id>"
elif [ $ERROR_COUNT -gt 0 ]; then
    echo "⚠️  Some errors detected, but may be non-critical"
    echo "Review logs manually to determine if action needed"
elif [ $WARNING_COUNT -gt 0 ]; then
    echo "✅ No errors, only warnings"
    echo "Migration likely successful, proceed to Phase B"
else
    echo "✅ Clean migration, no errors or warnings"
    echo "Proceed to Phase B"
fi
