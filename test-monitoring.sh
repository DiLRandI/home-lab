#!/bin/bash

# Test script to validate the monitoring stack deployment
# Run this script after running 'make install-software'

echo "=== Monitoring Stack Validation ==="
echo

# Check if inventory file exists and has content
if [ -f "ansible/inventory/hosts" ]; then
    echo "✓ Inventory file exists"
    SERVER_IP=$(grep -E '^[0-9]' ansible/inventory/hosts | awk '{print $1}' | head -1)
    if [ -n "$SERVER_IP" ]; then
        echo "✓ Found server IP: $SERVER_IP"
    else
        echo "✗ No server IP found in inventory"
        exit 1
    fi
else
    echo "✗ Inventory file not found. Run 'make update-inventory' first."
    exit 1
fi

echo
echo "=== Testing Service Endpoints ==="

# Test Nginx HTTPS (public access)
echo -n "Testing Nginx HTTPS (port 443)... "
if curl -k -s --max-time 5 "https://$SERVER_IP/nginx-health" > /dev/null; then
    echo "✓ OK"
else
    echo "✗ Failed"
fi

# Test Grafana via Nginx
echo -n "Testing Grafana via Nginx... "
if curl -k -s --max-time 5 "https://$SERVER_IP/" | grep -q "Grafana" 2>/dev/null; then
    echo "✓ OK"
else
    echo "✗ Failed"
fi

# Note: Internal services are not directly accessible
echo "ℹ️  Note: Prometheus and Node Exporter are accessible only via localhost (secure configuration)"

echo
echo "=== Access Information ==="
echo "🔒 Grafana Dashboard: https://$SERVER_IP/"
echo "   Login: admin / admin"
echo "   (Self-signed certificate - accept browser security warning)"
echo
echo "🔧 Nginx Health Check: https://$SERVER_IP/nginx-health"
echo
echo "ℹ️  Internal Services (localhost only):"
echo "   - Prometheus: http://localhost:9090/ (via SSH tunnel or server)"
echo "   - Node Exporter: http://localhost:9100/metrics (via SSH tunnel or server)"
echo "   - Direct Grafana: http://localhost:3000/ (via SSH tunnel or server)"
echo

echo "=== Next Steps ==="
echo "1. Login to Grafana and change the default password"
echo "2. Explore the pre-configured Node Exporter dashboard"
echo "3. Add custom dashboards by placing JSON files in:"
echo "   ansible/roles/grafana/files/dashboards/"
echo "4. Re-run 'make install-software' to deploy custom dashboards"
echo
echo "🔒 Security Notes:"
echo "   - All monitoring services run on localhost only"
echo "   - External access secured via nginx reverse proxy with SSL"
echo "   - Only ports 22, 80, 443 are externally accessible"
echo
