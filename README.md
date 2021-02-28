# Ambiente de transações bancárias

## Laboratório

**Máquina dos testes**

| **Tipo de virtualização** | Virtualização Total |
|---------------------------|---------------------|
| **Virtualizador**         | VirtualBox          |
| **Sistema operacional**   | Debian 10           |
| **Núcleos de CPU**        | 6                   |
| **Memória RAM**           | 16GB                |

---

### Preparação / Procedimentos

- [**Instalação do PostgreSQL**](procedimentos/00_install_postgres.md)
- [**Instalação do PgBouncer**](procedimentos/01_install_pgbouncer.md)
- [**Tuning do servidor de banco de dados**](procedimentos/02_server_tuning.md)
- [**Criação da estrutura do banco de dados**](procedimentos/03_db.md)
- [**Dados iniciais**](procedimentos/04_initial_data.md)
- [**Criação de procedures e funções**](procedimentos/05_proc_func.md)
- [**Testes**](procedimentos/06_tests.md)
- [**Resultados**](procedimentos/07_results.md)
- [**Conclusão**](procedimentos/08_conclusion.md)

---


## Tuning de parâmetros:

| **Parâmetro** | **Valor padrão** | **Novo valor** |
|---------------|------------------|----------------|
| listen_addresses | 'localhost' | 'localhost, 192.168.56.2'|
| password_encryption  | md5 | scram-sha-256 |
| shared_buffers | 128MB | 4GB |
| huge_pages | try | on |
| work_mem | 4MB | 32MB |
| maintenance_work_mem | 64MB | 1GB |
| max_stack_depth | 2MB | 16MB |
| bgwriter_flush_after | 512kB | 2MB |
| effective_io_concurrency | 1 | 220 |
| maintenance_io_concurrency | 10 | 220 |
| default_statistics_target | 100 | 500
| max_parallel_workers_per_gather | 2 | 6 |
| max_parallel_maintenance_workers | 2 | 6 |
| wal_writer_flush_after | 1MB | 16MB |
| commit_delay | 0 | 1500 |
| commit_siblings | 5 | 90 |
| checkpoint_timeout | 5min | 10min |
| max_wal_size | 1GB | 5GB |
| min_wal_size | 80MB | 512MB |
| checkpoint_completion_target | 0.5 | 0.85 |
| checkpoint_flush_after | 256kB | 2MB |
| random_page_cost | 4.0 | 1.1 |
| cpu_tuple_cost | 0.01 | 0.1 |
| effective_cache_size | 4GB | 5GB |
| log_directory | 'log' | '/var/log/pgsql' |
| autovacuum_naptime | 1min | 10s |
| autovacuum_vacuum_insert_scale_factor | 0.2 | 0.05 |
| autovacuum_vacuum_insert_threshold | 1000 | -1 |
 