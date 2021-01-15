/*
Estrutura
*/

-- Criação da base de dados
CREATE DATABASE db_stone;

-- Conectar à base
\c db_stone

-- Criação da tabela de tipos de conta
CREATE TABLE tb_account_type (
    id_ int2 PRIMARY KEY, -- Identificação do tipo de conta
    descr text -- Descrição
    );

-- Criação da tabela de contas
CREATE TABLE tb_account (
    id_ int PRIMARY KEY,  -- Identificação da conta (Número da conta)
    type_ int2 REFERENCES tb_account_type (id_) default 1, -- Tipo de conta
    balance numeric (15, 2),  -- Saldo
    CONSTRAINT ck_balance_not_neg CHECK (balance >= 0)  -- Restrição CHECK para evitar saldo negativo
    );

-- Criação de tabela de transações
CREATE TABLE tb_transaction (
	source_account int,
	destiny_account int,
	dt timestamp with time zone,
	transfer_value numeric (15, 2),
	PRIMARY KEY (source_account, destiny_account, dt))
	PARTITION BY RANGE (dt);
	

-- Criação de schema para partições:
CREATE SCHEMA sc_partitions;
