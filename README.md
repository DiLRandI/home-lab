# home-lab

This project provides an AWS CloudFormation template and supporting files to deploy a minimal home lab monitoring stack on an EC2 instance. The stack includes:

- **Grafana**: For visualization and dashboards
- **Prometheus**: For metrics collection and monitoring
- **Node Exporter**: For exposing Linux system metrics to Prometheus

## Structure

- `infrastructure.yaml`: Main CloudFormation template to provision the EC2 instance, security group, and install all monitoring components using UserData.
- `param/param.json`: Parameter file in AWS format, used to provide stack parameters (AMI ID, Grafana version, etc.)
- `Makefile`: Contains a `deploy` target to deploy the stack using AWS CLI and the parameter file.

## Usage

1. **Edit Parameters**
   - Update `param/param.json` with your desired AMI ID and Grafana version.

2. **Deploy the Stack**
   - Run `make deploy` to deploy the stack to AWS. This uses the AWS CLI and requires appropriate credentials and permissions.

3. **Access**
   - After deployment, the public IP and DNS of the instance will be available as stack outputs. Use these to access Grafana and Prometheus web interfaces.

## Requirements

- AWS CLI installed and configured
- `make` utility
- An appropriate ARM64 AMI for the EC2 instance (e.g., Amazon Linux 2 ARM64)

## Notes

- The EC2 instance is configured to allow SSH from anywhere (port 22 open to 0.0.0.0/0). For production, restrict this as needed.
- The UserData script installs all components and sets up systemd services for Grafana, Prometheus, and Node Exporter.
- The stack is intended for learning and home lab use.