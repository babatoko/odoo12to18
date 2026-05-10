#!/bin/bash
# Script 10: Validate all modules are properly migrated to v13
# Checks module states in database
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

echo "=== Validate All Modules v13 ==="
echo "Date: $(date)"
echo ""

# Query database to check module states
echo "Checking module states in database..."

docker exec odoo_migration psql -U odoo -d entretien-maconnais -c "
SELECT
    name,
    state,
    latest_version
FROM ir_module_module
WHERE state IN ('installed', 'to upgrade', 'to install')
ORDER BY name;
" | tee ./logs/module_states_$(date +%Y%m%d_%H%M%S).txt

echo ""
echo "--- Module State Summary ---"
docker exec odoo_migration psql -U odoo -d entretien-maconnais -t -c "
SELECT
    state,
    COUNT(*) as count
FROM ir_module_module
WHERE state IN ('installed', 'to upgrade', 'to install', 'uninstalled')
GROUP BY state
ORDER BY count DESC;
"

echo ""
echo "--- Modules with Issues (if any) ---"
docker exec odoo_migration psql -U odoo -d entretien-maconnais -c "
SELECT
    name,
    state
FROM ir_module_module
WHERE state IN ('to upgrade', 'to install', 'to remove')
LIMIT 20;
"

echo ""
echo "✅ Module validation complete"
echo "If modules are in 'to upgrade' or 'to install' state, run Phase B"
