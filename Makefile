# Makefile

.PHONY: deploy install-ansible setup-ansible run-ansible test-ansible update-inventory

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
	@echo "Updating Ansible inventory..."
	@echo "[monitoring]" > ansible/inventory/hosts
	@echo "$(PUBLIC_IP) ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ansible/inventory/hosts
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

# Test Ansible connectivity
test-ansible:
	@echo "Testing Ansible connectivity to all hosts..."
	cd ansible && ansible all -m ping

# Complete Ansible setup and deployment
ansible-deploy: setup-ansible run-ansible
	@echo "Ansible deployment completed!"