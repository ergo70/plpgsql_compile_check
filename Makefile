EXTENSION = plpgsql_compile_check
DATA = plpgsql_compile_check--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
