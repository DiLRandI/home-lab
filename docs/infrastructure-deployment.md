# Infrastructure and Deployment

This document covers the AWS infrastructure setup and deployment procedures.

## Infrastructure Overview

The project uses AWS CloudFormation to provision:
- **EC2 Instance**: t4g.nano (ARM-based, cost-effective)
- **Security Group**: HTTP/HTTPS access only (ports 80, 443, 22)
- **Key Pair**: SSH access for configuration management

## CloudFormation Template

**File**: `infrastructure.yaml`

### Resources Created
1. **Security Group** (`MySecurityGroup`):
   - SSH access (port 22)
   - HTTP access (port 80) - redirects to HTTPS
   - HTTPS access (port 443) - nginx reverse proxy

2. **EC2 Instance** (`MyEC2Instance`):
   - Instance type: `t4g.nano` (ARM64 architecture)
   - Automated SSH key setup via UserData
   - Security group attachment

### Security Configuration
```yaml
SecurityGroupIngress:
  - IpProtocol: tcp
    FromPort: 22
    ToPort: 22
    CidrIp: 0.0.0.0/0
    Description: SSH access
  - IpProtocol: tcp
    FromPort: 80
    ToPort: 80
    CidrIp: 0.0.0.0/0
    Description: HTTP access via nginx
  - IpProtocol: tcp
    FromPort: 443
    ToPort: 443
    CidrIp: 0.0.0.0/0
    Description: HTTPS access via nginx
```

## Deployment Commands

### Complete Deployment
```bash
# Deploy infrastructure and install software
make deploy          # Create AWS resources
make install-software # Configure monitoring stack
```

### Individual Operations
```bash
# Infrastructure only
make deploy

# Software installation only  
make install-software

# Ansible connectivity test
make test-ansible

# Update inventory from CloudFormation
make update-inventory
```

## Makefile Targets

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy AWS infrastructure via CloudFormation |
| `make install-software` | Install complete monitoring stack |
| `make setup-ansible` | Configure Ansible and test connectivity |
| `make run-prometheus` | Install Prometheus only |
| `make ansible-deploy` | Complete setup (same as install-software) |
| `make test-ansible` | Test Ansible connectivity |
| `make update-inventory` | Update inventory from CloudFormation output |

## Parameters Configuration

**File**: `param/param.json`

```json
[
    {
        "ParameterKey": "AmiId",
        "ParameterValue": "ami-094ead6eb0a3fed45"
    },
    {
        "ParameterKey": "KeyName", 
        "ParameterValue": "home-lab"
    }
]
```

### Customizing Parameters
- **AmiId**: Update for different regions or OS versions
- **KeyName**: Must match existing EC2 Key Pair name

## Architecture Decisions

### Security-First Design
- **No Direct Service Access**: All monitoring services bind to localhost
- **Reverse Proxy**: Nginx handles SSL termination and external access
- **Minimal Attack Surface**: Only essential ports exposed

### Cost Optimization
- **ARM Instance**: t4g.nano provides cost-effective performance
- **Single Instance**: Suitable for learning/development environments
- **Self-Signed SSL**: Eliminates certificate authority costs

### Automation Focus
- **Infrastructure as Code**: CloudFormation for reproducible deployments
- **Configuration Management**: Ansible for consistent software setup
- **Version Control**: All configurations stored in Git

## Network Architecture

```
Internet
    ↓ (HTTPS/443)
[AWS Security Group]
    ↓
[EC2 Instance - nginx:443]
    ↓ (HTTP/3000)
[Grafana - localhost:3000]
    ↓ (HTTP/9090)  
[Prometheus - localhost:9090]
    ↓ (HTTP/9100)
[Node Exporter - localhost:9100]
```

## Deployment Workflow

1. **Infrastructure Deployment**:
   ```bash
   make deploy
   ```
   - Creates CloudFormation stack
   - Provisions EC2 instance and security group
   - Outputs public IP address

2. **Inventory Update**:
   ```bash
   make update-inventory
   ```
   - Retrieves public IP from CloudFormation
   - Updates Ansible inventory file

3. **Software Installation**:
   ```bash
   make install-software
   ```
   - Tests Ansible connectivity
   - Deploys monitoring stack
   - Configures nginx reverse proxy

## Monitoring and Validation

### Service Health Checks
The deployment includes automatic validation:
- Service startup verification
- Endpoint connectivity testing
- Configuration validation

### Manual Verification
```bash
# Run validation script
./test-monitoring.sh

# Check individual services
curl -k https://your-server-ip/           # Grafana via nginx
curl -k https://your-server-ip/nginx-health # Nginx health check
```

## Troubleshooting

### Common Issues

#### CloudFormation Deployment Fails
- Check AWS credentials: `aws sts get-caller-identity`
- Verify key pair exists: `aws ec2 describe-key-pairs`
- Review CloudFormation events in AWS Console

#### Ansible Connection Fails
- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Test direct SSH: `ssh -i ~/.ssh/id_rsa ec2-user@<ip>`
- Check security group SSH rules

#### Service Not Accessible
- Verify nginx configuration: `sudo nginx -t`
- Check service status: `sudo systemctl status nginx grafana-server`
- Review nginx logs: `sudo tail -f /var/log/nginx/error.log`

### Cleanup
```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name home-lab-stack

# Clean local inventory
echo "[monitoring]" > ansible/inventory/hosts
```
