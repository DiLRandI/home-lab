# Makefile

# Default SSH key path, can be overridden with: make target ssh-key=/path/to/key.pem
SSH_KEY_PATH ?= ~/.ssh/id_rsa
# Allow 'ssh-key' as an alternative to SSH_KEY_PATH
ifdef ssh-key
    SSH_KEY_PATH = $(ssh-key)
endif

.PHONY: deploy install-ansible setup-ansible run-ansible run-prometheus run-grafana run-monitoring-stack install-software test-ansible update-inventory ansible-deploy monitoring-deploy

deploy:
	aws cloudformation deploy \
		--template-file infrastructure.yaml \
		--stack-name home-lab-stack \
		--parameter-overrides file://param/param.json \
		--capabilities CAPABILITY_NAMED_IAM

# Install Ansible and required dependencies
install-ansible:
	@echo "Installing Ansible and dependencies..."
	sudo apt update
	sudo apt install -y ansible python3-pip awscli
	pip3 install --user ansible-core
	@echo "Ansible installation completed!"

# Get public IP from CloudFormation stack and update inventory
update-inventory:
	@echo "Retrieving public IP from CloudFormation stack..."
	$(eval PUBLIC_IP := $(shell aws cloudformation describe-stacks --stack-name home-lab-stack --query 'Stacks[0].Outputs[?OutputKey==`PublicIp`].OutputValue' --output text))
	@echo "Found public IP: $(PUBLIC_IP)"
	@echo "Updating Ansible inventory with SSH key: $(SSH_KEY_PATH)"
	@echo "[monitoring]" > ansible/inventory/hosts
	@echo "$(PUBLIC_IP) ansible_user=ec2-user ansible_ssh_private_key_file=$(SSH_KEY_PATH)" >> ansible/inventory/hosts
	@echo "Inventory updated with IP: $(PUBLIC_IP)"

# Setup Ansible configuration and test connectivity
setup-ansible: update-inventory
	@echo "Testing Ansible configuration..."
	cd ansible && ansible --version
	@echo "Testing connectivity to hosts..."
	cd ansible && ansible monitoring -m ping

# Run the node_exporter installation playbook
run-ansible:
	@echo "Running Ansible playbook to install node_exporter..."
	cd ansible && ansible-playbook playbooks/install_node_exporter.yml

# Run the prometheus installation playbook
run-prometheus:
	@echo "Running Ansible playbook to install prometheus..."
	cd ansible && ansible-playbook playbooks/install_prometheus.yml

# Run the grafana installation playbook
run-grafana:
	@echo "Running Ansible playbook to install grafana..."
	cd ansible && ansible-playbook playbooks/install_grafana.yml

# Run the complete monitoring stack installation playbook
run-monitoring-stack:
	@echo "Running Ansible playbook to install monitoring stack (Prometheus + Node Exporter + Grafana)..."
	cd ansible && ansible-playbook playbooks/install_monitoring_stack.yml

# Install all monitoring software (Prometheus + Node Exporter + Grafana)
install-software: setup-ansible run-monitoring-stack
	@echo "All monitoring software installation completed!"
	@echo "Note: You can override the SSH key with: make install-software ssh-key=/path/to/key.pem"

# Test Ansible connectivity
test-ansible:
	@echo "Testing Ansible connectivity to all hosts..."
	cd ansible && ansible all -m ping

# Complete Ansible setup and deployment
ansible-deploy: setup-ansible run-monitoring-stack
	@echo "Ansible deployment completed!"

# Complete monitoring stack deployment
monitoring-deploy: setup-ansible run-monitoring-stack
	@echo "Monitoring stack deployment completed!"