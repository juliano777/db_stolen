[**[Home]**](../README.md "Página inicial") - 
[**<**](01_install_pgbouncer.md "Instalação do PgBouncer via código-fonte") - 
[**>**](03_proc_func.md "Criação de procedures e funções")

---

# Tuning do servidor de banco de dados

**[>]** Verificando parâmetros:
```sql
SELECT
    name, setting, unit
    FROM pg_settings
    WHERE name IN (
        'huge_pages', 'max_stack_depth');
``` 
```
      name       | setting | unit 
-----------------+---------+------
 huge_pages      | try     | 
 max_stack_depth | 2048    | kB
```
Mais humanamente legível:  
`huge_pages` = try  
`max_stack_depth` = 2MB  
&nbsp;
São dois parâmetros que precisam de ajustes no sistema operacional, 
sendo que `huge_pages` vamos habilitar (on) e `max_stack_depth` vamos ajustar para 16MB.  
Esse valor sugere-se que seja 80% de `ulimit -s`, cujo valor é em kb.  
Então devemos ajustar `stack size`, no sistema operacional para 20480.  

**[#]** Ajustando o tamanho de pilha (stack size), em kb, para o usuário postgres:
```bash
cat << EOF > /etc/security/limits.d/postgres.conf
postgres  soft  stack  20480
postgres  hard  stack  20480
EOF
```

**[$]** Via sed, alterando os parâmetros max_stack_depth e huge_pages:
```bash
# max_stack_depth
sed 's:^\(#max_stack_depth.*\):\1\nmax_stack_depth = 16MB:g' \
    -i ${PGDATA}/postgresql.conf
# huge pages
sed 's:^\(#huge_pages.*\):\1\nhuge_pages = on:g' \
    -i ${PGDATA}/postgresql.conf
```


systemctl edit --full postgresql.service


[Service]
. . .
LimitSTACK=20971520

**[>]** Verificando parâmetros:
```sql
SELECT
    name, setting, unit
    FROM pg_settings
    WHERE name IN (
        'effective_cache_size',
        'maintenance_work_mem',
        'shared_buffers',
        'work_mem');
``` 
```
         name         | setting | unit 
----------------------+---------+------
 effective_cache_size | 524288  | 8kB
 maintenance_work_mem | 65536   | kB
 shared_buffers       | 16384   | 8kB
 work_mem             | 4096    | kB
```

**[$]** Via sed, alterando os parâmetros:
```bash
# effective_cache_size
sed 's:^\(#effective_cache_size.*\):\1\neffective_cache_size = 6GB:g' \
    -i ${PGDATA}/postgresql.conf
# maintenance_work_mem
sed 's:^\(#maintenance_work_mem.*\):\1\nmaintenance_work_mem = 1GB:g' \
    -i ${PGDATA}/postgresql.conf
# shared_buffers
sed 's:^\(shared_buffers.*\):#\1\nshared_buffers = 12GB:g' \
    -i ${PGDATA}/postgresql.conf
# work_mem
sed 's:^\(#work_mem.*\):\1\nwork_mem = 32MB:g' \
    -i ${PGDATA}/postgresql.conf        
```  

**[$]** Saia (como usuário postgres), volte e reinicie o serviço:
```bash
pg_ctl restart
```
```
. . . FATAL:  could not map anonymous shared memory: Cannot allocate memory
. . . request size (currently 13210722304 bytes) . . .
```
Foi requerida memória, como *huge pages* 12901096 kb.  
O ajuste será feito para 15481315 (20% a mais).


apt install -y bc && apt clean



export HUGEPAGESIZE=`cat /proc/meminfo | fgrep Hugepagesize | awk '{print $2}'`
export HUGE_PAGES_TOTAL_KB=15481315
export NR_HUGEPAGES=`echo "${HUGE_PAGES_TOTAL_KB} / ${HUGEPAGESIZE}" | bc`


cat << EOF > /etc/sysctl.d/postgres.conf
vm.nr_hugepages = ${NR_HUGEPAGES}
vm.hugetlb_shm_group = `id -g postgres`
EOF

sysctl -p

cat << EOF >> /etc/security/limits.d/postgres.conf
postgres  hard  memlock  ${HUGE_PAGES_TOTAL_KB}
postgres  soft  memlock  ${HUGE_PAGES_TOTAL_KB}
EOF




