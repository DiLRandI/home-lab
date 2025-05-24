# Makefile

.PHONY: deploy

deploy:
	aws cloudformation deploy \
		--template-file infrastructure.yaml \
		--stack-name home-lab-stack \
		--parameter-overrides file://param/param.json \
		--capabilities CAPABILITY_NAMED_IAM