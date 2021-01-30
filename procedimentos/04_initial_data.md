[**[Home]**](../README.md "Página inicial") - 
[**<**](03_proc_func.md "Criação de procedures e funções") - 
[**>**](05_first_scenario.md "Primeiro cenário - 100 mil contas")

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

---

[**[Home]**](../README.md "Página inicial") - 
[**<**](03_proc_func.md "Criação de procedures e funções") - 
[**>**](05_first_scenario.md "Primeiro cenário - 100 mil contas")