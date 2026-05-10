#!/bin/bash
# Script 1: Cleanup Run 2 containers and resources
#
# Co-Authored-By: Paperclip <noreply@paperclip.ing>

set -e

echo "=== Cleanup Run 2 ===="
echo "Date: $(date)"

# Stop and remove Run 2 containers if they exist
echo "Stopping Run 2 containers..."
docker stop odoo_run2 2>/dev/null || echo "Container odoo_run2 not running"
docker rm odoo_run2 2>/dev/null || echo "Container odoo_run2 not found"

# Clean up any orphan containers from previous runs
echo "Cleaning up orphan containers..."
docker container prune -f

echo "✅ Cleanup Run 2 completed"
