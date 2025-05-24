# Documentation Index

This directory contains comprehensive documentation for the Home Lab Monitoring Stack project.

## 📋 Documentation Structure

### 🚀 [Infrastructure and Deployment](infrastructure-deployment.md)

Complete guide for AWS infrastructure setup and deployment procedures.

**Topics Covered**:

- CloudFormation template configuration
- EC2 instance provisioning
- Security group setup
- Makefile deployment commands
- Network architecture
- Troubleshooting deployment issues

### 🔧 [Ansible Configuration and Setup](ansible-setup.md)  

Detailed documentation for Ansible automation and configuration management.

**Topics Covered**:

- Ansible role architecture
- Version management
- Service configuration
- Playbook execution
- Role customization
- Service troubleshooting

### 📊 [Dashboard Management](dashboard-management.md)

Guide for creating, managing, and customizing Grafana dashboards.

**Topics Covered**:

- Dashboard creation and deployment
- JSON configuration format
- PromQL query examples
- Performance optimization
- Custom dashboard development
- Alerting integration

### 🔒 [Security Configuration](security-configuration.md)

Comprehensive security architecture and hardening guidelines.

**Topics Covered**:

- Network security and isolation
- SSL/TLS configuration
- Authentication and access control
- Security headers and best practices
- Monitoring and logging
- Incident response procedures

## 🎯 Quick Navigation

### Getting Started

1. [Deploy Infrastructure](infrastructure-deployment.md#deployment-commands)
2. [Configure Ansible](ansible-setup.md#usage)
3. [Access Services](infrastructure-deployment.md#monitoring-and-validation)
4. [Customize Dashboards](dashboard-management.md#adding-custom-dashboards)

### Common Tasks

- **Update Software Versions**: [Ansible Setup → Version Management](ansible-setup.md#version-management)
- **Add New Dashboard**: [Dashboard Management → Adding Custom Dashboards](dashboard-management.md#adding-custom-dashboards)
- **Troubleshoot Issues**: Each document contains troubleshooting sections
- **Security Hardening**: [Security Configuration → Best Practices](security-configuration.md#security-best-practices)

### Reference Materials

- **Service Ports and Access**: [Ansible Setup → Network Configuration](ansible-setup.md#network-configuration)
- **File Locations**: [Infrastructure Deployment → Architecture](infrastructure-deployment.md#network-architecture)
- **Configuration Files**: [Ansible Setup → Roles Architecture](ansible-setup.md#roles-architecture)

## 📁 File Organization

```
docs/
├── README.md                     # This index file
├── infrastructure-deployment.md  # AWS and deployment guide  
├── ansible-setup.md             # Ansible configuration guide
├── dashboard-management.md       # Grafana dashboard guide
└── security-configuration.md    # Security and hardening guide
```

## 🔄 Documentation Maintenance

### Updating Documentation

- Keep documentation in sync with code changes
- Update version references when upgrading software
- Add new sections for additional features
- Review and update troubleshooting guides

### Contributing

- Follow existing documentation structure
- Include practical examples and code snippets
- Add troubleshooting information for new features
- Maintain consistent formatting and style
