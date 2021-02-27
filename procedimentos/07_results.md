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

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 2000 -t 10 db_stone

starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.

[... Kernel panic ...]

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 200 -T 600 db_stone

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

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 200 db_stone -t 100

starting vacuum...end.
transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 200
number of threads: 1
number of transactions per client: 100
number of transactions actually processed: 20000/20000
latency average = 61.873 ms
tps = 3232.403296 (including connections establishing)
tps = 3233.369081 (excluding connections establishing)

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 300 db_stone -t 100

starting vacuum...end.
transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 300
number of threads: 1
number of transactions per client: 100
number of transactions actually processed: 30000/30000
latency average = 107.584 ms
tps = 2788.525796 (including connections establishing)
tps = 2789.012599 (excluding connections establishing)

Último limite de centena seguro.

### Com tuning

## Cenário 2 - Mil contas
### Sem tuning

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 2000 -t 10 db_stone

starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.

[... Kernel panic ...]


pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 200 -T 600 db_stone

transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 200
number of threads: 1
duration: 600 s
number of transactions actually processed: 2299434
latency average = 52.191 ms
tps = 3832.102249 (including connections establishing)
tps = 3832.114191 (excluding connections establishing)
pgbench: fatal: Run was aborted; the above results are incomplete.


pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 200 db_stone -t 100

starting vacuum...end.
transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 200
number of threads: 1
number of transactions per client: 100
number of transactions actually processed: 20000/20000
latency average = 62.409 ms
tps = 3204.643019 (including connections establishing)
tps = 3205.489224 (excluding connections establishing)


pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 300 db_stone -t 100

transaction type: /tmp/test.sql
scaling factor: 1
query mode: simple
number of clients: 300
number of threads: 1
number of transactions per client: 100
number of transactions actually processed: 29976/30000
latency average = 110.244 ms
tps = 2721.238436 (including connections establishing)
tps = 2721.647647 (excluding connections establishing)

pgbench -h localhost -p 5432 -U postgres -f /tmp/test.sql -c 300 db_stone -t 100

Último limite de centena seguro.

### Com tuning

---

[**[Home]**](../README.md "Página inicial") - 
[**<**](06_tests.md "Testes")
[**>**]()