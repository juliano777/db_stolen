[<- Voltar](../README.md)

# Primeiro cenário - 100 mil contas

**[>]** Populando a tabela de contas:
```sql
INSERT INTO tb_account (id_, balance) 
    SELECT 
        generate_series(1, 70000),  -- 70000 contas criadas (70% tipo 1)
        (random() * 100000000)::numeric(15, 2);  -- Valores aleatórios para saldo
        
INSERT INTO tb_account (id_, type_, balance) 
    SELECT 
        generate_series(70001, 100000),  -- 30000 contas criadas (30% tipo 2)
        2,  -- Conta tipo 2
        (random() * 100000000)::numeric(15, 2);  -- Valores aleatórios para saldo
``` 

**[>]** Gerando 2 milhões de transações:
```sql
CALL 
``` 

[<- Voltar](../README.md)