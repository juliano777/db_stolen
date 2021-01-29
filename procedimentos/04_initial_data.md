[<- Voltar](../README.md)

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

[<- Voltar](../README.md)