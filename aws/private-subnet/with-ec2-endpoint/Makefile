.PHONY: docs
docs:
	gsed -i -e '/## Inputs/,+100d' README.md
	terraform-docs md . >> README.md
