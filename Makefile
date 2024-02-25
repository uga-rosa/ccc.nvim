.PHONY: test
vusted:
	vusted ./test

.PHONY: format
format:
	stylua .
