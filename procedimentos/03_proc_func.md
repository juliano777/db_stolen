[<- Voltar](../README.md)

# Criação de procedures e funções

## Particionamento

**[>]** Procedure para criar uma nova partição:
```sql
CREATE OR REPLACE PROCEDURE sp_create_partition(
    table_name text,  -- Tabela particionada
    ns_partition text default 'public', -- Schema das partições
    ns_table text default 'public',  -- Schema da tabela partionada
    base_date timestamp without time zone default now()  -- Data base
    )  
AS $body$
DECLARE
    current_month varchar := to_char(base_date, 'YYYYMM');
    lower_bound varchar := to_char(base_date, 'YYYY-MM-01');
    upper_bound varchar := to_char(base_date + '1 month', 'YYYY-MM-01');    
    partition_name varchar := ns_partition||'.'||table_name||'_'||current_month;
    table_name varchar := ns_table||'.'||table_name;
    sql text;
BEGIN
    sql := format(
                 $$
                 CREATE TABLE IF NOT EXISTS %s
                    PARTITION OF %s
                    FOR VALUES FROM ('%s') TO ('%s');
                  $$,
                  partition_name,
                  table_name,
                  lower_bound,
                  upper_bound
                );

    EXECUTE sql;

END; $body$
LANGUAGE PLPGSQL;
``` 

**[>]** Procedure para criar várias partições dada uma faixa de datas:
```sql
CREATE OR REPLACE PROCEDURE sp_create_multiple_partitions (
    table_name text,  -- Tabela particionada
    start_date timestamp without time zone, -- Data de ínício
	end_date timestamp without time zone DEFAULT now(), -- Data fim
    ns_partition text DEFAULT 'public', -- Schema das partições
    ns_table text DEFAULT 'public'  -- Schema da tabela partionada
	) AS $body$
DECLARE
	r record;
BEGIN
	FOR r IN
		SELECT generate_series(start_date, end_date, '1 month') AS i
	LOOP
		CALL sp_create_partition(
								 table_name::text,
								 ns_partition::text,
								 ns_table::text,
								 r.i);
	END LOOP;
END;
$body$ LANGUAGE PLPGSQL;
``` 

## Funções e procedures auxiliares

**[>]** Função para criar datas aleatórias:
```sql
CREATE OR REPLACE FUNCTION fc_random_timestamp(
	start_date timestamp with time zone,
	end_date timestamp with time zone)
	RETURNS timestamp with time zone AS $body$
BEGIN
    RETURN (end_date - random() * (end_date - start_date));
END;
$body$
LANGUAGE PLPGSQL;
``` 

**[>]** Procedure para "zerar" todas as tabelas:
```sql
CREATE OR REPLACE PROCEDURE sp_zero()
 AS $body$
DECLARE
	r record;
BEGIN
	FOR r IN
		SELECT schemaname||'.'||relname AS i
			FROM pg_stat_user_tables
				WHERE schemaname != 'sc_partitions'
					AND relname != 'tb_account_type'
	LOOP
		EXECUTE 'TRUNCATE '||r.i||' RESTART IDENTITY CASCADE';
	END LOOP;
END;
$body$ LANGUAGE PLPGSQL;
``` 

## Transferências

**[>]** Procedure para executar transferências:
```sql
CREATE OR REPLACE PROCEDURE sp_transfer (
    source_ int,
    destiny_ int,
    value_ bigint,
	dt_ timestamp with time zone default now()
    ) AS $body$
    
    BEGIN
    
    -- Retirar
    UPDATE tb_account SET balance = (balance - value_)
        WHERE id_ = source_;
        
    -- Adicionar
    UPDATE tb_account SET balance = (balance + value_)
        WHERE id_ = destiny_;

	-- Registrar transação
	INSERT INTO tb_transaction
		(source_account, destiny_account, dt, transfer_value)
	VALUES (source_, destiny_, dt_, value_);

    -- Ajustando formato numérico para a mensagem
    SET lc_numeric = 'pt_BR.UTF-8';

    -- Mensagem informativa
    RAISE NOTICE 'Transferido de % para %: R$ % em %', 
        source_,
        destiny_,
        trim(to_char((value_ / 100), '999G999G999G999D99')),
        to_char(dt_, 'dd/mm/YYYY HH:MM');
        
    END;
    $body$ LANGUAGE PLPGSQL;
``` 

**[>]** Procedure para realizar transferências aleatórias:
```sql
CREATE OR REPLACE PROCEDURE sp_random_transfer (
    account_type int default ceil(random() * 2),
    dt timestamp with time zone default now()
    ) AS $body$
    DECLARE
            source_ int;
            destiny_ int;
            value_ bigint;        
    BEGIN
    	SELECT
        	id_ INTO source_
			FROM tb_account
			WHERE type_ = account_type
			ORDER BY random()
			LIMIT 1;
    	SELECT id_ INTO destiny_ FROM tb_account WHERE id_ != source_ ORDER BY random() LIMIT 1;
    	SELECT balance * 0.1 INTO value_ FROM tb_account WHERE id_ = source_;
    	CALL sp_transfer (source_, destiny_, value_, dt);
    END;
    $body$ LANGUAGE PLPGSQL;
``` 

## Extrato bancário

**[>]** Função para gerar extrato:
```sql
CREATE OR REPLACE FUNCTION fc_bank_statement (account_number int)
RETURNS TABLE (
    dt_ text, 
    account_ int,
    transfer_value_ bigint) AS $xyz$
BEGIN
    RETURN QUERY

    SELECT                                       
        to_char(dt, 'dd/mm/YYYY HH:MM') AS dt,
        destiny_account AS account,
        (transfer_value * -1) AS transfer_value
        FROM tb_transaction
        WHERE source_account = account_number               

    UNION
        
    SELECT
        to_char(dt, 'dd/mm/YYYY HH:MM') AS dt,
        source_account AS account,
        transfer_value
        FROM tb_transaction
        WHERE destiny_account = account_number
    ORDER BY dt;
        
END;
$xyz$ LANGUAGE PLPGSQL;
``` 

[<- Voltar](../README.md)