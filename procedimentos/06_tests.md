[**[Home]**](../README.md "Página inicial") - 
[**<**](04_initial_data.md "Segundo cenário - 1000 contas")
[**>**]()

---

# Testes

-- 100%
SELECT count(*) FROM tb_account;        
/*
 count  
--------
 100000
 */
 
-- 70%
SELECT count(*) FROM tb_account WHERE type_ = 1;
/*
 count 
-------
 70000
 */
 
-- 30%
SELECT count(*) FROM tb_account WHERE type_ = 2;
/*
 count 
-------
 30000
 */ 
 
     
-- Duas contas de exemplo    
   
SELECT * FROM tb_account WHERE id_ IN (1, 2);
/*
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724886.00
   2 |     1 | 46678048.79
*/


-- Transferir R$ 100,00 da conta 1 para a conta 2
CALL sp_transfer (1, 2, 100);

-- Verificar os saldos
SELECT * FROM tb_account WHERE id_ IN (1, 2);
/*
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724786.00
   2 |     1 | 46678148.79
*/

-- Tentativa de transferir mais do que se tem em conta
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

/*
ERROR:  new row for relation "tb_account" violates check constraint "ck_balance_not_neg"
DETAIL:  Failing row contains (1, 1, -1.00).
CONTEXT:  SQL statement "UPDATE tb_account SET balance = (balance - value_)
        WHERE id_ = source_"
PL/pgSQL function sp_transfer(integer,integer,numeric) line 6 at SQL statement
SQL statement "CALL sp_transfer (1, 2, absurd)"
PL/pgSQL function inline_code_block line 11 at CALL
*/

-- Verificar os saldos
SELECT * FROM tb_account WHERE id_ IN (1, 2);
/*
 id_ | type_ |   balance   
-----+-------+-------------
   1 |     1 | 69724786.00
   2 |     1 | 46678148.79
*/

-- Transferir todo saldo da conta 1 para a conta 2
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

-- Verificar os saldos
SELECT * FROM tb_account WHERE id_ IN (1, 2);
/*
 id_ | type_ |   balance    
-----+-------+--------------
   1 |     1 |         0.00
   2 |     1 | 116402934.79
*/



---

[**[Home]**](../README.md "Página inicial") - 
[**<**](04_initial_data.md "Segundo cenário - 1000 contas")
[**>**]()