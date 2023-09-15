-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION plpgsql_compile_check" to load this file. \quit

CREATE OR REPLACE FUNCTION pgc_tf_compile_check_func_or_prod()
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
	  		if msg is not null then
	   			RAISE WARNING E'Compile error(s) at % in %:\n%', now(), ident, msg;
				RAISE exception SQLSTATE 'P0000';
			end if;
			RAISE NOTICE 'Compiled % at %', ident, now();
  		end loop;
END;
$$;

CREATE EVENT TRIGGER pgc_evtrg_compile_check_func_or_prod ON ddl_command_end WHEN TAG IN ('CREATE FUNCTION', 'CREATE PROCEDURE')
   EXECUTE FUNCTION pgc_tf_compile_check_func_or_prod();
