# Stand-in for PGXS on Windows (see build-ext-windows.sh): the extension's own
# Makefile includes this instead, so `make byre-vars` prints what it set.
byre-vars:
	@echo 'MODULE_big=$(MODULE_big)'
	@echo 'MODULES=$(MODULES)'
	@echo 'OBJS=$(OBJS)'
	@echo 'EXTENSION=$(EXTENSION)'
	@echo 'DATA=$(DATA) $(DATA_built)'
	@echo 'PG_CPPFLAGS=$(PG_CPPFLAGS)'
