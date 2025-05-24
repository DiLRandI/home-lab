# Ansible Configuration and Setup

This document covers the Ansible automation for deploying the monitoring stack.

## Overview

The Ansible setup provides automated deployment of:

- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Visualization and dashboards
- **Node Exporter**: Linux system metrics
- **Nginx**: Reverse proxy for secure access

## Directory Structure

```text
ansible/
├── ansible.cfg              # Ansible configuration
├── group_vars/
│   └── monitoring.yml       # Version management for all software
├── inventory/
│   └── hosts               # Target hosts (auto-generated from CloudFormation)
├── playbooks/              # Orchestration playbooks
│   ├── install_monitoring_stack.yml  # Complete stack installation
│   ├── install_prometheus.yml        # Prometheus only
│   └── install_node_exporter.yml     # Node Exporter only
└── roles/                  # Software-specific roles
    ├── grafana/           # Grafana installation and configuration
    ├── prometheus/        # Prometheus installation and configuration
    ├── node_exporter/     # Node Exporter installation
    └── nginx/             # Reverse proxy configuration
```

## Configuration Management

### Version Management

All software versions are centrally managed in `group_vars/monitoring.yml`:

```yaml
node_exporter_version: "1.8.2"
prometheus_version: "2.54.1" 
grafana_version: "12.0.1"
```

### Network Configuration

- **Node Exporter**: 127.0.0.1:9100 (localhost only)
- **Prometheus**: 127.0.0.1:9090 (localhost only)
- **Grafana**: 127.0.0.1:3000 (localhost only)
- **Nginx**: 0.0.0.0:80/443 (public access via reverse proxy)

## Usage

### Install Complete Stack

```bash
cd ansible
ansible-playbook playbooks/install_monitoring_stack.yml
```

### Install Individual Components

```bash
# Prometheus only
ansible-playbook playbooks/install_prometheus.yml

# Grafana only
ansible-playbook playbooks/install_grafana.yml

# Node Exporter only  
ansible-playbook playbooks/install_node_exporter.yml
```

### Update Versions

1. Edit `group_vars/monitoring.yml`
2. Run installation playbook
3. Ansible will detect version differences and update accordingly

## Roles Architecture

### Grafana Role

- **Location**: `roles/grafana/`
- **Purpose**: Grafana installation, configuration, and dashboard provisioning
- **Key Features**:
  - Automatic Prometheus datasource configuration
  - Dashboard JSON file provisioning
  - Self-signed SSL certificate generation
  - Service management with systemd

### Prometheus Role

- **Location**: `roles/prometheus/`
- **Purpose**: Prometheus server installation and configuration
- **Key Features**:
  - Automatic service discovery for Node Exporter
  - Configurable retention policies
  - Web interface on localhost only

### Node Exporter Role

- **Location**: `roles/node_exporter/`
- **Purpose**: System metrics collection
- **Key Features**:
  - Linux system metrics (CPU, memory, disk, network)
  - Localhost-only binding for security

### Nginx Role

- **Location**: `roles/nginx/`
- **Purpose**: Reverse proxy for secure external access
- **Key Features**:
  - SSL/TLS termination with self-signed certificates
  - HTTP to HTTPS redirection
  - Grafana proxy configuration
  - Security headers implementation

## Security Configuration

### Service Binding

All monitoring services are configured to bind to localhost only:

- Prevents direct external access to monitoring services
- Forces access through nginx reverse proxy
- Reduces attack surface

### SSL/TLS

- Self-signed certificates generated automatically
- Strong cipher suites configured
- HTTP Strict Transport Security (HSTS) enabled
- Security headers implemented

### Firewall

AWS Security Group allows only:

- Port 22: SSH access
- Port 80: HTTP (redirects to HTTPS)
- Port 443: HTTPS (nginx reverse proxy)

## Troubleshooting

### Service Status

```bash
# Check all services
sudo systemctl status grafana-server prometheus node_exporter nginx

# View service logs
sudo journalctl -u grafana-server -f
sudo journalctl -u prometheus -f  
sudo journalctl -u node_exporter -f
sudo journalctl -u nginx -f
```

### Configuration Validation

```bash
# Test nginx configuration
sudo nginx -t

# Check prometheus configuration
/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --dry-run
```

### Connectivity Testing

```bash
# Test internal services
curl http://localhost:3000/api/health  # Grafana
curl http://localhost:9090/-/ready     # Prometheus
curl http://localhost:9100/metrics     # Node Exporter

# Test external access
curl -k https://your-server-ip/        # Nginx → Grafana
```
