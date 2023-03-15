.PHONY: integration
integration: luacheck vusted

.PHONY: luacheck
luacheck:
	luacheck ./lua

.PHONY: vusted
vusted:
	vusted ./test
