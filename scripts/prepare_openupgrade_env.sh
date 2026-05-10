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
pip3 install --upgrade git+https://github.com/OCA/openupgradelib.git@master

# Clone OpenUpgrade 13.0 (FORK - for migration only)
if [ -d "/opt/openupgrade_13" ]; then
    echo "OpenUpgrade 13.0 already exists, pulling latest..."
    cd /opt/openupgrade_13 && git pull
else
    echo "Cloning OpenUpgrade 13.0..."
    git clone -b 13.0 https://github.com/OCA/OpenUpgrade.git /opt/openupgrade_13
fi

# Clone Odoo 13 Normal (for production service)
if [ -d "/opt/odoo_13" ]; then
    echo "Odoo 13 Normal already exists, pulling latest..."
    cd /opt/odoo_13 && git pull
else
    echo "Cloning Odoo 13 Normal..."
    git clone -b 13.0 https://github.com/odoo/odoo.git /opt/odoo_13
fi

echo "✅ OpenUpgrade environment prepared"
echo "  - openupgradelib installed"
echo "  - OpenUpgrade 13.0: /opt/openupgrade_13"
echo "  - Odoo 13 Normal: /opt/odoo_13"
