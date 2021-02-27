[**[Home]**](../README.md "Página inicial") - 
[**<**](05_proc_func.md "Criação de procedures e funções")
[**>**](07_results.md "Resultados")

---

# Testes

**[>]** Verificando a quantidade de contas:
```sql
SELECT count(*) FROM tb_account;
```
```
 count  
--------
 100000
```

**[>]** Verificando a quantidade de contas do tipo 1:
```sql
SELECT count(*) FROM tb_account WHERE type_ = 1;
```
```
 count 
-------
 70000
```  
Corresponde a 70% das contas.

**[>]** Verificando a quantidade de contas do tipo 2:
```sql
SELECT count(*) FROM tb_account WHERE type_ = 2;
```
```
 count 
-------
 30000
```
Corresponde a 30% das contas.  

**[>]** Duas contas de exemplo:
```sql
SELECT * FROM tb_account WHERE id_ IN (1, 2);
```
```
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724886.00
   2 |     1 | 46678048.79
```  

**[>]** Transferir R$ 100,00 da conta 1 para a conta 2:
```sql
CALL sp_transfer (1, 2, 100);
```  

**[>]** Verificar os saldos:
```sql
SELECT * FROM tb_account WHERE id_ IN (1, 2);
```
```
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724786.00
   2 |     1 | 46678148.79
```

**[>]** Tentativa de transferir mais do que se tem em conta:
```sql
DO $foo$
DECLARE 
    absurd numeric(15, 2);  -- Variável do valor incongruente
BEGIN
    SELECT (balance + 1)  -- Saldo + R$ 1,00 (valor incongruente)
        INTO absurd  -- Atribuir à variável o valor incongruente
        FROM tb_account
        WHERE id_ = 1;
    
    -- Executar procedure com o valor incongruente
    CALL sp_transfer (1, 2, absurd);
END 
$foo$ LANGUAGE PLPGSQL;
```
```
ERROR:  new row for relation "tb_account" violates check constraint "ck_balance_not_neg"
DETAIL:  Failing row contains (1, 1, -1.00).
CONTEXT:  SQL statement "UPDATE tb_account SET balance = (balance - value_)
        WHERE id_ = source_"
PL/pgSQL function sp_transfer(integer,integer,numeric) line 6 at SQL statement
SQL statement "CALL sp_transfer (1, 2, absurd)"
PL/pgSQL function inline_code_block line 11 at CALL
```  

**[>]** Verificar os saldos:
```sql
SELECT * FROM tb_account WHERE id_ IN (1, 2);
```
```
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724786.00
   2 |     1 | 46678148.79
```  

**[>]** Transferir todo saldo da conta 1 para a conta 2:
```sql
DO $foo$
DECLARE 
    transferred numeric(15, 2);  -- Variável do saldo da conta 1
BEGIN
    SELECT balance  -- Saldo
        INTO transferred  -- Atribuir à variável o saldo da conta 1
        FROM tb_account
        WHERE id_ = 1;
    
    -- Executar procedure com o valor incongruente
    CALL sp_transfer (1, 2, transferred);
END 
$foo$ LANGUAGE PLPGSQL;
```  

**[>]** Verificar os saldos:
```sql
SELECT * FROM tb_account WHERE id_ IN (1, 2);
```
```
 id_ | type_ |   balance    
-----+-------+--------------
   1 |     1 |         0.00
   2 |     1 | 116402934.79
```

**[>]** Criação de script SQL que será usado para os testes:
```bash
cat << EOF > /tmp/test.sql
CALL sp_random_transfer(
	fc_random_timestamp(
		'2000-01-01'::timestamp without time zone,
		now()::timestamp without time zone));
EOF
```

## Testes de desempenho 

**[#]** Instalação do git:
```bash
apt install -y git && apt clean
```

**[#]** Clonar o repositório db_stone como usuário postgres:
```bash
su - postgres -c "
git clone https://github.com/juliano777/db_stone.git \
/tmp/db_stone
"
```

**[#]** Copia o stone_executor para um diretório do $PATH:
```bash
cp /tmp/db_stone/sh/stone_executor /usr/local/bin/
```

**[#]** Copia o stone_executor para um diretório do $PATH:
```bash
chmod +x /usr/local/bin/stone_executor
```

**[$]** Apaga e recria a base de dados:
```bash
dropdb db_stone && createdb db_stone
```

<hr />  
<hr />

**Escolha que qual cenário vai testar;**

**1) 100 mil contas**
**[$]** Restaurar do dump do primeiro cenário:
```bash
xzcat /tmp/db_stone/xz/db_stone.primeiro_cenario.sql.xz | psql db_stone
```

ou

**2) Mil contas**
**[$]** Restaurar do dump do primeiro cenário:
```bash
xzcat /tmp/db_stone/xz/db_stone.segundo_cenario.sql.xz | psql db_stone
```
<hr />  
<hr />


**[$]** Inicialização dos metadados do pgbench:
```bash
pgbench -i db_stone
```


**[$]** Inicialização dos metadados do pgbench:
```bash
pgbench -i db_stone
```

**[$]** Execução do teste:
```bash
stone_executor -a 1 -c 2000 -t 10 -d db_stone -p 6432 -f /tmp/test.sql
```


---

[**[Home]**](../README.md "Página inicial") - 
[**<**](05_proc_func.md "Criação de procedures e funções")
[**>**](07_results.md "Resultados")