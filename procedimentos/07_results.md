[**[Home]**](../README.md "Página inicial") - 
[**<**](06_tests.md "Testes")
[**>**]()

---

# Resultados

cat << EOF > /tmp/test.sql
CALL sp_random_transfer(
	fc_random_timestamp(
		'2000-01-01'::timestamp without time zone,
		now()::timestamp without time zone));
EOF

## Cenário 1 - 100 mil contas
### Sem tuning

stone_executor -a 1 -c 2000 -t 10 -d db_stone -f /tmp/test.sql

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 2000 -t 10 db_stone
starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.

[... Kernel panic ...]

stone_executor -a 1 -c 200 -T 600 -d db_stone -f /tmp/test.sql

transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 200
number of threads: 1
duration: 600 s
number of transactions actually processed: 2051316
latency average = 58.507 ms
tps = 3418.405289 (including connections establishing)
tps = 3418.414178 (excluding connections establishing)
pgbench: fatal: Run was aborted; the above results are incomplete.

stone_executor -a 1 -c 200 -t 100 -d db_stone -f /tmp/test.sql

### Com tuning

## Cenário 2 - Mil contas
### Sem tuning
### Com tuning

---

[**[Home]**](../README.md "Página inicial") - 
[**<**](06_tests.md "Testes")
[**>**]()