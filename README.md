# plpgsql_compile_check
This extension provides automatic static code analysis of PL/pgSQL functions and procedures using plpgsql_check and an event trigger.

## Installation

shared_preload_libraries='plpgsql,plpgsql_check'

```
create extension plpgsql_check;
create etension plpgsql_compile_check;
```

## Usage

```
CREATE OR REPLACE FUNCTION increment(i integer) RETURNS integer AS $$
        BEGIN
                RETURN i + 1;
        END;
$$ LANGUAGE plpgsql;

Compiled public.increment(integer) at 2023-09-13 14:08:50.213244+02
```

BUT:

```
CREATE OR REPLACE FUNCTION increment(i integer) RETURNS integer AS $$
        BEGIN
                -- RETURN i + 1;
        END;
$$ LANGUAGE plpgsql;

Compile error(s) at 2023-09-13 14:06:52.39903+02 in public.increment(integer):
<Function oid="236274">
  <Issue>
    <Level>error</Level>
    <Sqlstate>2F005</Sqlstate>
    <Message>control reached end of function without RETURN</Message>
  </Issue>
  <Issue>
    <Level>warning extra</Level>
    <Sqlstate>00000</Sqlstate>
    <Message>unused parameter "i"</Message>
  </Issue>
</Function>
```

Functionality can be switched off/on by:

```
ALTER EVENT TRIGGER pgc_evtrg_compile_check_func_or_prod DISABLE;
ALTER EVENT TRIGGER pgc_evtrg_compile_check_func_or_prod ENABLE;
```
