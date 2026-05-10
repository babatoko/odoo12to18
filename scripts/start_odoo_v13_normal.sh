#!/bin/bash
# Script 12: Start Odoo 13 Normal service (production)
# Uses Odoo 13 Normal, NOT OpenUpgrade fork
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Start Odoo 13 Normal Service ==="
echo "Date: $(date)"

# Start Odoo 13 Normal service
echo "Starting Odoo 13 Normal on port 8069..."
docker exec -d odoo_v13_prod python3 /opt/odoo/odoo-bin \
  -c /etc/odoo/odoo.conf \
  -d production_db \
  --http-port=8069

# Wait a few seconds for startup
echo "Waiting for startup..."
sleep 5

# Check if service is running
echo ""
echo "--- Service Status ---"
if curl -s -I http://localhost:8069/web | grep -q "200\|302"; then
    echo "✅ Odoo 13 service is running"
    echo "  URL: http://localhost:8069/web"
else
    echo "⚠️  Service may not be responding yet"
    echo "  Check logs: docker logs odoo_v13_prod"
fi

# Show recent logs
echo ""
echo "--- Recent Logs ---"
docker logs odoo_v13_prod --tail 50

echo ""
echo "✅ Odoo 13 Normal started"
echo "  Container: odoo_v13_prod"
echo "  Port: 8069"
echo "  Access: http://localhost:8069/web"
echo ""
echo "Next: Board validation and testing"
