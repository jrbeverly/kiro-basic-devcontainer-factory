validate:
	terraform fmt -check -recursive
	terraform init -backend=false -input=false
	terraform validate
	terraform -chdir=examples/default init -backend=false -input=false
	terraform -chdir=examples/default validate
	bash -n examples/default/check.sh
