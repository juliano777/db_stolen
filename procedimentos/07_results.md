[**[Home]**](../README.md "Página inicial") - 
[**<**](06_tests.md "Testes")
[**>**](08_conclusion.md "Conclusão")

---

# Resultados

cat << EOF > test.sql
CALL sp_random_transfer(
	fc_random_timestamp(
		'2000-01-01'::timestamp without time zone,
		now()::timestamp without time zone));
EOF

<!-- ===================================================================== -->

## Cenário 1 - 100 mil contas
### Sem tuning

**[$]** pgbench, 1000 conexões, 10 transações cada:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 1000 -t 10 db_stone
```
```
starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.
. . .
[... Kernel panic ...]
```

**[$]** pgbench, 200 conexões, 10 transações:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 200 db_stone -t 10
```

tps = 246.712304

**[$]** pgbench, 300 conexões, 10 transações:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 300 db_stone -t 10
```
tps = 246.269275

Último limite de centena seguro.

**[$]** pgbench, 300 conexões, 10 minutos:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 300 db_stone -T 600
```
```
starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.
. . .
[... Kernel panic ...]
```

**[$]** pgbench, 250 conexões, 10 minutos:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 250 db_stone -T 600
```

tps = 234.763271



<!-- ===================================================================== -->

### Com tuning

**[$]** pgbench, 1000 conexões, 10 transações cada:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 1000 -t 10 db_stone
```

tps = 219.021225


**[$]** pgbench, 300 conexões, 10 transações:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 300 db_stone -t 10
```
tps = 267.479309


**[$]** pgbench, 500 conexões, 10 transações:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 500 db_stone -t 10
```
tps = 260.963801

**[$]** pgbench, 500 conexões, 10 minutos:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 500 db_stone -T 600
```
tps = 229.924600



## Cenário 2 - Mil contas

<!-- ===================================================================== -->

### Sem tuning

**[$]** pgbench, 1000 conexões, 10 transações cada:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 1000 -t 10 db_stone
```
```
starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.
. . .
[... Kernel panic ...]
```

**[$]** pgbench, 200 conexões, 10 transações:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 200 db_stone -t 10
```

tps = 2284.838823

**[$]** pgbench, 300 conexões, 10 transações:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 300 db_stone -t 10
```
tps = 2026.820860

Último limite de centena seguro.

**[$]** pgbench, 300 conexões, 10 minutos:
```bash
pgbench -h localhost -p 5432 -U postgres -f test.sql -c 300 db_stone -T 600
```
```
starting vacuum...end.
Connection to 192.168.56.2 closed by remote host.
. . .
[... Kernel panic ...]
```

<!-- ===================================================================== -->

### Com tuning


**[$]** pgbench, 1000 conexões, 10 transações cada:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 1000 -t 10 db_stone
```

tps = 3202.123776


**[$]** pgbench, 300 conexões, 10 transações:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 300 db_stone -t 10
```

tps = 4479.754539

**[$]** pgbench, 500 conexões, 10 transações:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 500 db_stone -t 10
```

tps = 4393.291349

**[$]** pgbench, 500 conexões, 10 minutos:
```bash
pgbench -h localhost -p 6432 -U postgres -f test.sql -c 500 db_stone -T 600
```
tps = 2274.704638


<!-- ===================================================================== -->

---

[**[Home]**](../README.md "Página inicial") - 
[**<**](06_tests.md "Testes")
[**>**](08_conclusion.md "Conclusão")