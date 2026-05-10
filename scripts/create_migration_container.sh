#!/bin/bash
# Script 3: Create migration container with OpenUpgrade fork
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Create Migration Container ==="
echo "Date: $(date)"

MIGRATION_DIR="$HOME/odoo_migration"

# Remove existing migration container if exists
docker stop odoo_migration 2>/dev/null || true
docker rm odoo_migration 2>/dev/null || true

# Create migration container with OpenUpgrade 13.0
echo "Creating migration container with OpenUpgrade 13.0..."
docker run -d --name odoo_migration \
  --link odoo-db-local:db \
  -e HOST=odoo-db-local \
  -e USER=odoo \
  -e PASSWORD=odoo \
  -v "$MIGRATION_DIR/openupgrade_13":/opt/openupgrade \
  -p 8013:8069 \
  odoo:13

echo "✅ Migration container created"
echo "  Container: odoo_migration"
echo "  Port: 8013"
echo "  OpenUpgrade path: /opt/openupgrade"
echo "  Database host: odoo-db-local"
