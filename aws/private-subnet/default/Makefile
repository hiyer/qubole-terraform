.PHONY: docs
docs: variables.tf
	gsed -i -e '/## Inputs/,+100d' README.md
	terraform-docs md . >> README.md
