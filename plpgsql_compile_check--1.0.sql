-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION plpgsql_compile_check" to load this file. \quit

CREATE OR REPLACE FUNCTION compile_check_func_or_prod()
  RETURNS event_trigger
 LANGUAGE plpgsql
  AS $$
  declare
  	r record;
  	ident text;
	msg text;
begin
	ident := null;
	msg := null;	
  	for r in select d.object_identity from pg_event_trigger_ddl_commands() d inner join pg_catalog.pg_proc p on (p."oid" = d.objid) inner join pg_catalog.pg_language l on (p.prolang = l."oid") WHERE p.proname != 'compile_check_func_or_prod' and p.prokind in ('f', 'p') and l.lanname = 'plpgsql' limit 1 loop
		ident := r.object_identity;
	  	msg := plpgsql_check_function(ident, format:='xml');
  	end loop;
  	if ident is not null then
 		if msg is null then
 			RAISE NOTICE 'Compiled % at %', ident, now();
		else
 			RAISE WARNING 'Compile error(s) at % in %: %', now(), ident, msg;
			RAISE SQLSTATE 'P0000';
		end if;
	end if;
END;
$$;

CREATE EVENT TRIGGER evtrg_compile_check_func_or_prod ON ddl_command_end WHEN TAG IN ('CREATE FUNCTION', 'CREATE PROCEDURE')
   EXECUTE FUNCTION compile_check_func_or_prod();