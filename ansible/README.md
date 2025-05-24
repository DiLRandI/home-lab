# Ansible Node Exporter Installation

This Ansible playbook installs the latest version of Prometheus Node Exporter on your target hosts.

## Directory Structure

```
ansible/
├── ansible.cfg
├── inventory/
│   └── hosts
├── playbooks/
│   └── install_node_exporter.yml
└── roles/
    └── node_exporter/
        ├── defaults/
        │   └── main.yml
        ├── handlers/
        │   └── main.yml
        ├── tasks/
        │   └── main.yml
        └── templates/
            └── node_exporter.service.j2
```

## Setup Instructions

1. **Configure your inventory**: Edit `ansible/inventory/hosts` and add your target servers:
   ```ini
   [monitoring]
   192.168.1.100 ansible_user=ubuntu
   192.168.1.101 ansible_user=ubuntu
   # or for local installation:
   # localhost ansible_connection=local
   ```

2. **Install Ansible** (if not already installed):
   ```bash
   sudo apt update
   sudo apt install ansible
   ```

3. **Test connectivity** to your hosts:
   ```bash
   cd ansible
   ansible monitoring -m ping
   ```

4. **Run the playbook**:
   ```bash
   cd ansible
   ansible-playbook playbooks/install_node_exporter.yml
   ```

## Configuration Options

### Version Configuration

The node_exporter version is configured via group variables for consistency and simplicity.

**To change the version:**
1. Edit `group_vars/monitoring.yml`
2. Uncomment and modify the `node_exporter_version` line:
   ```yaml
   node_exporter_version: "1.8.2"
   ```
3. Run the playbook:
   ```bash
   make run-ansible
   ```

#### Available Versions:
Check available versions at: https://github.com/prometheus/node_exporter/releases

#### Examples:
```yaml
# Latest stable
node_exporter_version: "1.8.2"

# Previous version
node_exporter_version: "1.7.0"

# Older version
node_exporter_version: "1.6.1"
```

**Via group_vars/monitoring.yml:**
```yaml
node_exporter_version: "1.8.2"
```

**Via playbook vars:**
```yaml
vars:
  node_exporter_version: "1.8.2"
```

### Available Variables

- `node_exporter_version`: Version to install (default: "1.8.2")
- `node_exporter_port`: Port for node_exporter (default: 9100)
- `node_exporter_user`: User to run the service (default: "node_exporter")
- `node_exporter_group`: Group for the service (default: "node_exporter")

## Verification

After installation, you can verify node_exporter is working by visiting:
- `http://YOUR_SERVER_IP:9100/metrics`

Or check the service status:
```bash
sudo systemctl status node_exporter
```
