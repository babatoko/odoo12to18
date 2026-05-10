#!/bin/bash
# Script 2: Prepare OpenUpgrade environment
# - Install openupgradelib
# - Clone OpenUpgrade 13.0 (for migration)
# - Clone Odoo 13 Normal (for production service)
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Prepare OpenUpgrade Environment ==="
echo "Date: $(date)"

# Install openupgradelib
echo "Installing openupgradelib..."
python3 -m pip install --break-system-packages --upgrade git+https://github.com/OCA/openupgradelib.git@master

# Use local directory for migration files
MIGRATION_DIR="$HOME/odoo_migration"
mkdir -p "$MIGRATION_DIR"

# Clone OpenUpgrade 13.0 (FORK - for migration only)
if [ -d "$MIGRATION_DIR/openupgrade_13" ]; then
    echo "OpenUpgrade 13.0 already exists, pulling latest..."
    cd "$MIGRATION_DIR/openupgrade_13" && git pull
else
    echo "Cloning OpenUpgrade 13.0..."
    git clone -b 13.0 https://github.com/OCA/OpenUpgrade.git "$MIGRATION_DIR/openupgrade_13"
fi

# Clone Odoo 13 Normal (for test service)
if [ -d "$MIGRATION_DIR/odoo_13" ]; then
    echo "Odoo 13 Normal already exists, pulling latest..."
    cd "$MIGRATION_DIR/odoo_13" && git pull
else
    echo "Cloning Odoo 13 Normal..."
    git clone -b 13.0 https://github.com/odoo/odoo.git "$MIGRATION_DIR/odoo_13"
fi

echo "✅ OpenUpgrade environment prepared"
echo "  - openupgradelib installed"
echo "  - OpenUpgrade 13.0: $MIGRATION_DIR/openupgrade_13"
echo "  - Odoo 13 Normal: $MIGRATION_DIR/odoo_13"
