#!/bin/bash
# Script 11: Switch from OpenUpgrade (migration) to Odoo 13 Normal (test server)
# Stop migration container, create test container with Odoo 13 Normal
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Switch to Odoo 13 Normal ==="
echo "Date: $(date)"
echo ""
echo "This will:"
echo "  1. Stop the migration container (OpenUpgrade)"
echo "  2. Create test container with Odoo 13 Normal"
echo ""

read -p "Continue? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Stop migration container
echo "Stopping migration container..."
docker stop odoo_migration

# Remove existing test container if exists
docker stop odoo_v13_test 2>/dev/null || true
docker rm odoo_v13_test 2>/dev/null || true

# Create test container with Odoo 13 Normal
echo "Creating test container with Odoo 13 Normal..."
docker run -d --name odoo_v13_test \
  -v /opt/odoo_13:/opt/odoo \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  -p 8069:8069 \
  odoo:13

echo "✅ Switched to Odoo 13 Normal"
echo "  Migration container: stopped"
echo "  Test container: odoo_v13_test (ready)"
echo ""
echo "Next: Start Odoo 13 service with ./scripts/start_odoo_v13_normal.sh"
