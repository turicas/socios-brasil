lint:
	autoflake --in-place --recursive --remove-unused-variables --remove-all-unused-imports .
	isort .
	black -l 120 .
	flake8

.PHONY: lint
