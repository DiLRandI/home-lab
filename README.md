# Home Lab Monitoring Stack

A secure, automated monitoring solution deployed on AWS with Prometheus, Grafana, and Node Exporter.

## 🎯 Quick Start

```bash
# 1. Deploy AWS infrastructure
make deploy

# 2. Install monitoring stack  
make install-software

# 3. Access Grafana
# https://your-ec2-ip/ (admin/admin)
```

## 🏗️ Architecture

- **Infrastructure**: AWS EC2 with CloudFormation
- **Monitoring**: Prometheus + Grafana + Node Exporter  
- **Security**: Nginx reverse proxy with SSL/TLS
- **Automation**: Ansible configuration management

## 🔧 Available Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy AWS infrastructure |
| `make install-software` | Install complete monitoring stack |
| `make setup-ansible` | Configure Ansible connectivity |
| `make test-ansible` | Test Ansible connectivity |

## 🔒 Security Features

- **Localhost-only services**: All monitoring services bound to 127.0.0.1
- **SSL termination**: Nginx handles HTTPS with self-signed certificates
- **Minimal exposure**: Only ports 22, 80, 443 accessible externally
- **Security headers**: HSTS, CSP, and other security headers implemented

## 📊 Access Points

- **Grafana Dashboard**: `https://your-ec2-ip/` (admin/admin)
- **SSH Access**: `ssh -i ~/.ssh/id_rsa ec2-user@your-ec2-ip`

> **Note**: Prometheus and Node Exporter are accessible only via Grafana datasource configuration (localhost only).

## 📚 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- **[🚀 Infrastructure & Deployment](docs/infrastructure-deployment.md)** - AWS setup, CloudFormation, deployment
- **[🔧 Ansible Configuration](docs/ansible-setup.md)** - Automation, roles, configuration management  
- **[📊 Dashboard Management](docs/dashboard-management.md)** - Grafana dashboards, customization
- **[🔒 Security Configuration](docs/security-configuration.md)** - Security architecture, hardening

## 🛠️ Requirements

- AWS CLI configured with appropriate permissions
- Ansible installed
- SSH key pair for EC2 access
- Make utility

## 🎓 Learning Focus

This project demonstrates:

- Infrastructure as Code with CloudFormation
- Configuration Management with Ansible
- Monitoring stack deployment and configuration
- Security best practices for web applications
- Reverse proxy configuration with Nginx
