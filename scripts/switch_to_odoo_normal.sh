#!/bin/bash
# Script 11: Switch from OpenUpgrade (migration) to Odoo 13 Normal (production)
# Stop migration container, create production container with Odoo 13 Normal
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Switch to Odoo 13 Normal ==="
echo "Date: $(date)"
echo ""
echo "This will:"
echo "  1. Stop the migration container (OpenUpgrade)"
echo "  2. Create production container with Odoo 13 Normal"
echo ""

read -p "Continue? (yes/no): " CONFIRMED

if [ "$CONFIRMED" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Stop migration container
echo "Stopping migration container..."
docker stop odoo_migration

# Remove existing production container if exists
docker stop odoo_v13_prod 2>/dev/null || true
docker rm odoo_v13_prod 2>/dev/null || true

# Create production container with Odoo 13 Normal
echo "Creating production container with Odoo 13 Normal..."
docker run -d --name odoo_v13_prod \
  -v /opt/odoo_13:/opt/odoo \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  -p 8069:8069 \
  odoo:13

echo "✅ Switched to Odoo 13 Normal"
echo "  Migration container: stopped"
echo "  Production container: odoo_v13_prod (ready)"
echo ""
echo "Next: Start Odoo 13 service with ./scripts/start_odoo_v13_normal.sh"
