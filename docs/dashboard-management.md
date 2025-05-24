# Dashboard Management

This document covers Grafana dashboard configuration, customization, and management.

## Dashboard Storage Location

Once deployed, dashboard JSON files are stored at: `/etc/grafana/dashboards/` on the target server.

## Adding Custom Dashboards

### Method 1: JSON File Deployment

1. **Create Dashboard JSON**:
   - Design dashboard in Grafana UI
   - Go to Dashboard Settings → JSON Model
   - Copy the JSON content

2. **Add to Ansible Role**:
   - Create a new `.json` file in `ansible/roles/grafana/files/dashboards/`
   - Paste the JSON content
   - Ensure `"id": null` for new imports

3. **Deploy Dashboard**:

   ```bash
   make install-software
   ```

### Method 2: Grafana UI Import

1. Access Grafana at `https://your-server-ip/`
2. Login with admin credentials
3. Navigate to Dashboards → Import
4. Upload JSON file or paste JSON content

## Included Dashboards

### Node Exporter Dashboard

**File**: `node-exporter-dashboard.json`

**Panels Included**:

- **CPU Usage**: Current percentage and time series
- **Memory Usage**: Current percentage and time series  
- **Disk Usage**: Root filesystem utilization
- **Load Average**: 1-minute system load

**Metrics Used**:

```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage  
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk Usage
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

# Load Average
node_load1
```

## Dashboard Development Guidelines

### JSON Format Requirements

- Must be valid JSON format
- Set `"id": null` for new dashboard imports
- Include proper panel configurations
- Use meaningful titles and descriptions

### PromQL Best Practices

1. **Test queries in Prometheus UI first**: `http://localhost:9090`
2. **Use appropriate time ranges**: `[5m]`, `[1h]`, etc.
3. **Include instance labels**: `by (instance)` for multi-server setups
4. **Set reasonable refresh intervals**: Balance performance vs real-time data

### Performance Optimization

- Use appropriate data source intervals
- Limit the number of series in single queries
- Set reasonable time ranges for historical data
- Use summary/aggregation functions for overview panels

## Dashboard Categories

### System Monitoring

- CPU, Memory, Disk, Network utilization
- System load and processes
- File system statistics

### Application Monitoring  

- Service-specific metrics
- Custom application metrics
- Business metrics

### Infrastructure Monitoring

- Container metrics (if using Docker/K8s)
- Cloud provider metrics
- Network infrastructure

## Updating Dashboards

### Via Ansible (Recommended)

1. Modify JSON files in `ansible/roles/grafana/files/dashboards/`
2. Run deployment:

   ```bash
   make install-software
   ```

### Via Grafana UI

1. Make changes in Grafana interface
2. Export updated JSON
3. Replace file in Ansible role
4. Commit changes to version control

## Advanced Dashboard Features

### Variables and Templating

- Use dashboard variables for dynamic content
- Create dropdowns for server selection
- Implement time range controls

### Alerting Integration

- Configure alert rules within dashboards
- Set up notification channels
- Define alert conditions and thresholds

### Sharing and Permissions

- Configure dashboard permissions
- Set up team-based access control
- Create public dashboard snapshots

## Troubleshooting

### Dashboard Not Appearing

1. Check file location: `/etc/grafana/dashboards/`
2. Verify JSON syntax validity
3. Check Grafana logs: `sudo journalctl -u grafana-server -f`
4. Restart Grafana: `sudo systemctl restart grafana-server`

### Query Issues

1. Test PromQL in Prometheus UI
2. Verify metric names and labels
3. Check data retention settings
4. Confirm scrape targets are active

### Performance Issues

1. Reduce query complexity
2. Increase refresh intervals
3. Limit time ranges
4. Use recording rules for complex calculations
