# Security Configuration

This document outlines the security architecture and configuration for the monitoring stack.

## Security Architecture Overview

The monitoring stack implements a defense-in-depth security strategy:

1. **Network Isolation**: Services bind to localhost only
2. **Reverse Proxy**: Nginx handles external access with SSL termination  
3. **Minimal Exposure**: Only ports 22, 80, 443 externally accessible
4. **SSL/TLS Encryption**: All external communication encrypted

## Network Security

### Service Binding Configuration

All monitoring services are configured for localhost-only access:

```yaml
# Grafana Configuration
http_addr = 127.0.0.1

# Prometheus Configuration  
prometheus_web_listen_address: "127.0.0.1:9090"

# Node Exporter Configuration
node_exporter_web_listen_address: "127.0.0.1:9100"
```

### AWS Security Group Rules

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
    Description: HTTP access via nginx (redirects to HTTPS)
  - IpProtocol: tcp
    FromPort: 443
    ToPort: 443
    CidrIp: 0.0.0.0/0
    Description: HTTPS access via nginx
```

## SSL/TLS Configuration

### Certificate Management

**Self-Signed Certificate Generation**:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=Local/L=Local/O=HomeLabOrg/OU=IT/CN=<server-ip>"
```

**Diffie-Hellman Parameters**:
```bash
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
```

### SSL Configuration in Nginx

```nginx
# SSL Protocols and Ciphers
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
ssl_ecdh_curve secp384r1;
ssl_session_timeout 10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
```

## HTTP Security Headers

### Implemented Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### Header Explanations

- **X-Frame-Options**: Prevents clickjacking attacks
- **X-XSS-Protection**: Enables browser XSS filtering
- **X-Content-Type-Options**: Prevents MIME type sniffing
- **Referrer-Policy**: Controls referrer information
- **Content-Security-Policy**: Restricts resource loading
- **Strict-Transport-Security**: Enforces HTTPS connections

## Authentication and Access Control

### Grafana Authentication

**Default Credentials**:
- Username: `admin`
- Password: `admin`

**Security Recommendations**:
1. Change default password immediately after first login
2. Create individual user accounts
3. Disable admin user after creating alternative admin account
4. Configure role-based access control

### SSH Access

**Key-Based Authentication**:
- Password authentication disabled
- Public key authentication required
- Keys managed via EC2 Key Pairs

**SSH Hardening**:
```bash
# Recommended SSH configuration
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

## Service Security Configuration

### Grafana Security Settings

```ini
[security]
admin_user = admin
admin_password = admin  # Change this!
secret_key = <random-secret>
disable_gravatar = false
data_source_proxy_whitelist =
disable_brute_force_login_protection = false

[users]
allow_sign_up = false
allow_org_create = false
auto_assign_org = true
auto_assign_org_role = Viewer
```

### Prometheus Security

- Web interface accessible only via nginx proxy
- No authentication configured (protected by nginx)
- Query access restricted to Grafana datasource

### Node Exporter Security

- Metrics exposed only on localhost
- No authentication required (localhost access only)
- System metrics collection with minimal privileges

## Monitoring and Logging

### Security Event Monitoring

**Nginx Access Logs**:
```nginx
access_log /var/log/nginx/access.log main;
error_log /var/log/nginx/error.log;
```

**System Logs**:
```bash
# Monitor authentication attempts
sudo journalctl -f -u ssh

# Monitor service access
sudo tail -f /var/log/nginx/access.log

# Monitor system security events
sudo journalctl -f -t kernel
```

## Security Best Practices

### Regular Updates
```bash
# Update system packages
sudo yum update -y

# Update monitoring software versions in group_vars/monitoring.yml
# Redeploy with: make install-software
```

### Backup and Recovery
- Regular configuration backups
- Database exports from Grafana
- Documentation of custom dashboards
- SSH key backup and rotation

### Incident Response
1. **Suspicious Activity Detection**:
   - Monitor nginx access logs
   - Check for failed SSH attempts
   - Review Grafana user activity

2. **Response Procedures**:
   - Block suspicious IP addresses
   - Rotate SSH keys if compromised
   - Change Grafana passwords
   - Review and update security groups

## Compliance Considerations

### Data Protection
- Metrics data stored locally only
- No external data transmission
- Self-contained monitoring environment

### Audit Trail
- Nginx access logging enabled
- System authentication logging
- Service modification tracking via configuration management

## Security Limitations

### Current Limitations
- Self-signed certificates (browser warnings)
- Basic Grafana authentication
- No network segmentation beyond localhost binding
- No intrusion detection system

### Production Recommendations
- Use proper SSL certificates (Let's Encrypt, commercial CA)
- Implement OAuth or LDAP authentication
- Add fail2ban for SSH protection
- Configure log aggregation and monitoring
- Implement network monitoring and alerting
