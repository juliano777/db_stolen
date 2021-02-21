[**[Home]**](../README.md "Página inicial") - 
[**<**](03_db.md "Criação da estrutura do banco de dados") - 
[**>**](05_proc_func.md "Criação de procedures e funções")

---

# Dados iniciais

**[>]** Populando a tabela tb_account_type:
```sql
INSERT INTO tb_account_type (id_, descr) VALUES 
    (1, 'Tipo 1'),
    (2, 'Tipo 2');
``` 

**[>]** Criação de partições de 2000-01-01 até agora:
```sql
CALL sp_create_multiple_partitions(
    'tb_transaction'::text,
    '2000-01-01'::timestamp without time zone,
    now()::timestamp without time zone,
    'sc_partitions'::text,
    'public'::text);
```

## Primeiro cenário - 100 mil contas

**[>]** Populando a tabela de contas:
```sql
INSERT INTO tb_account (id_, balance) 
    SELECT 
        generate_series(1, 70000),  -- 70000 contas criadas (70% tipo 1)
        (random() * 10000000000);  -- Valores aleatórios para saldo
        
INSERT INTO tb_account (id_, type_, balance) 
    SELECT 
        generate_series(70001, 100000),  -- 30000 contas criadas (30% tipo 2)
        2,  -- Conta tipo 2
        (random() * 10000000000);  -- Valores aleatórios para saldo
``` 

## Segundo cenário - 1000 contas

**[>]** Populando a tabela de contas:
```sql
INSERT INTO tb_account (id_, balance) 
    SELECT 
        generate_series(1, 700),  -- 700 contas criadas (70% tipo 1)
        (random() * 10000000000);  -- Valores aleatórios para saldo
        
INSERT INTO tb_account (id_, type_, balance) 
    SELECT 
        generate_series(701, 1000),  -- 300 contas criadas (30% tipo 2)
        2,  -- Conta tipo 2
        (random() * 10000000000);  -- Valores aleatórios para saldo
```  

---

[**[Home]**](../README.md "Página inicial") - 
[**<**](03_db.md "Criação da estrutura do banco de dados") - 
[**>**](05_proc_func.md "Criação de procedures e funções")