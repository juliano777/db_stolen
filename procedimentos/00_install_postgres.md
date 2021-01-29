[<- Voltar](../README.md)

# Instalação do PostgreSQL via código-fonte

É o tipo de instalação mais complicada e demorada a se fazer, No entanto, a mesma tem suas vantagens.  
No processo de compilação podem ser especificadas opções de acordo com o desejo do usuário, além claro, de poder alterar o código fonte.  
O PostgreSQL instalado por compilação pode ter um desempenho superior a um pacote binário se tiver otimizações para a máquina na qual será instalado.  
Existem diversas formas de fazer esse tipo de instalação.  

**Arquitetura de diretórios**

| **Tipo**     | **Localização**                                  |
|--------------|--------------------------------------------------|
| Instalação   | `/usr/local/pgsql/`               |
| Configuração | `/var/local/pgsql/data/`      |
| Dados        | `/var/local/pgsql/data/`      |
| Binários     | `/usr/local/pgsql/bin/`           |
&nbsp;  

**[#]** Variáveis de ambiente de pacotes:
```bash
# Pacotes comuns
PKG='bison gcc flex make bzip2 wget'

# Pacotes Debian
PKG_DEB="libreadline-dev libssl-dev libxml2-dev libldap2-dev \
uuid-dev python3-dev"
```  

**[#]** Instalação de pacotes e posterior limpeza de pacotes baixados:
```bash
apt update && apt install -y ${PKG} ${PKG_DEB} && apt clean
```  

**[#]** Habilitar configurações de localidades (locales) pt_BR.utf8 e en_US.utf8:
```bash
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
```  
&nbsp;  

**[#]** Criação de um grupo de sistema:
```bash
groupadd -r postgres &> /dev/null
```  

**[#]** Criação de usuário de sistema:
```bash
useradd \
    -c 'PostgreSQL system user' \
    -s /bin/bash \
    -k /etc/skel \
    -d /var/local/pgsql \
    -g postgres \
    -m -r postgres  &> /dev/null
```  

**[#]** Definição de variáveis:
```bash
PGHOME='/usr/local/pgsql'  # Diretório de instalação do PostgreSQL
PGBIN="${PGHOME}/bin"  # Diretório de binários executáveis
PG_LD_LIBRARY_PATH="${PGHOME}/lib"  # Diretório de bibliotecas
PG_MANPATH="${PGHOME}/man"  # Diretório de manuais
PGLOG='/var/log/pgsql'  # Diretório de logs
PGDATA='/var/local/pgsql/data'  # Diretório de dados do PostgreSQL
PGWAL='/var/local/pgsql/wal'  # Diretório de logs de transação
PG_STAT_TEMP='/var/local/pgsql/pg_stat_tmp'  # Diretório de estatísticas temporárias
```  

**[#]** Criar o arquivo .pgvars com seu respectivo conteúdo no diretório do usuário home postgres:
```bash
cat << EOF > ~postgres/.pgvars
# Environment Variables
export LD_LIBRARY_PATH="${PG_LD_LIBRARY_PATH}:\${LD_LIBRARY_PATH}" 
export MANPATH="${PG_MANPATH}:\${MANPATH}"
export PATH="${PGBIN}:\${PATH}"
export PGDATA="${PGDATA}"
EOF
```  

**[#]** Adiciona linha no arquivo de perfil do usuário postgres para ler o arquivo ~/.pgvars e aplicá-las:
```bash
if [ -f ~postgres/.bash_profile ]; then
    echo -e "\nsource ~/.pgvars" >> ~postgres/.bash_profile
else
    echo -e "\nsource ~/.pgvars" >> ~postgres/.profile
fi
```  

**[#]** ~postgres/.psqlrc otimizado:
```bash
cat << EOF > ~postgres/.psqlrc
\set HISTCONTROL ignoreboth
\set COMP_KEYWORD_CASE upper
\x auto
EOF
```  

**[#]** Criação de diretórios:
```bash
mkdir -pm 0700 ${PGLOG} ${PGDATA} ${PGWAL} ${PG_STAT_TEMP}
```  

**[#]** Atribuição de variável de ambiente para versão completa do Postgres via prompt:
```bash
read -p \
    'Digite o número de versão completo (X.Y) do PostgreSQL a ser baixado: ' \
    PGVERSIONXY
```  

**[#]** Download do código-fonte:
```bash
wget -c \
https://ftp.postgresql.org/pub/source/v${PGVERSIONXY}/postgresql-\
${PGVERSIONXY}.tar.bz2 -P /tmp/
```  

**[#]** Ir para /tmp onde o arquivo foi baixado, descompactá-lo:
```bash
cd /tmp/ && tar xf postgresql-${PGVERSIONXY}.tar.bz2
```  

**[#]** Após a descompactação acessar a pasta do código-fonte:
```bash
cd postgresql-${PGVERSIONXY}
```  

**[#]** Variáveis de ambiente para o processo de compilação:
```bash
export PYTHON=`which python3`  # Variável de ambiente do executável Python 3

CONFIGURE_OPTS="
    --prefix=${PGHOME} \
    --with-python \
    --with-libxml \
    --with-openssl \
    --with-ldap \
    --with-uuid=e2fs \
    --includedir=/usr/local/include
"

# Protege o processo principal do OOM Killer
CPPFLAGS="-DLINUX_OOM_SCORE_ADJ=0"

# Número de jobs conforme a quantidade cores de CPU (cores + 1): 
NJOBS=`expr \`nproc\` + 1`

# Opções do make
MAKEOPTS="-j${NJOBS}"

# Tipo de hardware
CHOST="x86_64-unknown-linux-gnu"

# Flags de otimização para o make 
CFLAGS="-march=native -O2 -pipe"
CXXFLAGS="$CFLAGS"
```  

**[#]** Processo de configure:
```bash
./configure ${CONFIGURE_OPTS}
```  

**[#]** Compilação (com manuais e contrib):
```bash
make world
```  

**[#]** Instalação:
```bash
make install-world
```  

**[#]** Criação de arquivo de serviço do PostgreSQL:
```bash
cat << EOF > /lib/systemd/system/postgresql.service
[Unit]
Description=PostgreSQL ${PGVERSION} database server
After=syslog.target
After=network.target
[Service]
Type=forking
User=postgres
Group=postgres
Environment=PGDATA=${PGDATA}
OOMScoreAdjust=-1000    
ExecStart=${PGBIN}/pg_ctl start -D ${PGDATA} -s -w -t 300
ExecStop=${PGBIN}/pg_ctl stop -D ${PGDATA} -s -m fast
ExecReload=${PGBIN}/pg_ctl reload -D ${PGDATA} -s
TimeoutSec=300
[Install]
WantedBy=multi-user.target
EOF
```  

**[#]** Dar propriedade ao usuário e grupo postgres aos diretórios:
```bash
chown -R postgres: ${PGLOG} /var/local/pgsql ~postgres
```  

**[#]** Criação de cluster:
```bash
su - postgres -c "\
initdb \
-D ${PGDATA} \
-E utf8 \
-U postgres \
-k \
--locale=pt_BR.utf8 \
--lc-collate=pt_BR.utf8 \
--lc-monetary=pt_BR.utf8 \
--lc-messages=en_US.utf8 \
-T portuguese \
-X ${PGWAL}"
```  

**[#]** Alterações no postgresql.conf via sed:
```bash
# listen_addresses = '*'
sed "s:\(^#listen_addresses.*\):\1\nlisten_addresses = '*':g" -i ${PGDATA}/postgresql.conf

# log_destination = 'stderr'
sed "s:\(^#log_destination.*\):\1\nlog_destination = 'stderr':g" -i ${PGDATA}/postgresql.conf

# logging_collector = on
sed "s:\(^#logging_collector.*\):\1\nlogging_collector = on:g" -i ${PGDATA}/postgresql.conf

# log_filename (nova linha descomentada)
sed "s:\(^#\)\(log_filename.*\):\1\2\n\2:g" -i ${PGDATA}/postgresql.conf

# log_directory = '${PGLOG}'
sed "s:\(^#log_directory.*\):\1\nlog_directory = '${PGLOG}':g" -i ${PGDATA}/postgresql.conf

# stats_temp_directory = '${PG_STAT_TEMP}'
sed "s:\(^#stats_temp_directory.*\):\1\nstats_temp_directory = '${PG_STAT_TEMP}':g" -i ${PGDATA}/postgresql.conf
```  

**[#]** Montagem da linha para montagem em memória RAM:
```bash
echo -e \
"\ntmpfs ${PG_STAT_TEMP} tmpfs size=32M,uid=postgres,gid=postgres 0 0"\
 >> /etc/fstab
```  

**[#]** Monta tudo definido em /etc/fstab:
```bash
mount -a
```  

**[#]** Habilita e inicializa o serviço do PostgreSQL:
```bash
systemctl enable --now postgresql
```
[<- Voltar](../README.md)
## Limpeza de pacote desnecessários

Terminada a instalação, por questões de boas práticas de segurança devemos remover os pacotes utilizados conforme o tipo de distribuição Linux.

**[#]** Desinstalação de pacotes Debian:
```bash
apt purge -y ${PKG} ${PKG_DEB}
```

[<- Voltar](../README.md)
## SSH sem senha

Após instalar um servidor PostgreSQL é interessante que sua admnistração seja feita somente pelo usuário `postgres`.  
Evitar o usuário `root` e fazer com que o DBA se conecte ao servidor através de uma chave pública autorizada.  
&nbsp;  
  

**[$]** Armazenar o endereço na variável de ambiente:
```bash
read -p 'Digite o endereço do Servidor PostgreSQL: ' PGSERVER
```

```
Digite o endereço do Servidor PostgreSQL:
```  
  
**[$]** Caso não exista a chave na máquina local, a mesma será criada:
```bash
if [ ! -e ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa;
fi
```  
  
**[$]** Adicionando a chave pública do usuário e máquina local para o usuário root do servidor:
```bash
ssh-copy-id root@${PGSERVER}
```  
  
**[$]** Adicionando a chave pública do usuário e máquina local para o usuário root do servidor:
```bash
ssh-copy-id root@${PGSERVER}
```  

**[$]** Criando chaves para o usuário postgres:
```bash
ssh root@${PGSERVER} \
"su - postgres -c \"ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa\""
```  
  
**[$]** Adicionando a chave pública para o usuário postgres do servidor:
```bash
cat ~/.ssh/id_rsa.pub | \
ssh root@${PGSERVER} "cat - >> ~postgres/.ssh/authorized_keys"
```  
  
**[$]** Teste de acesso como usuário postgres:
```bash
ssh postgres@${PGSERVER}
```
[<- Voltar](../README.md)