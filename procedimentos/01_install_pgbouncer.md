[**[Home]**](../README.md "Página inicial") - 
[**<**](00_install_postgres.md "Instalação do PostgreSQL via código-fonte") - 
[**>**](02_db.md "Criação da estrutura do banco de dados")

---

# Instalação do PgBouncer via código-fonte

O PgBouncer é um excelente *connection pooler*.  
Seguem abaixo detalhes e procedimentos para sua instalação via compilação de código-fonte.  

**Arquitetura de diretórios**

| **Tipo**     | **Localização**                                  |
|--------------|--------------------------------------------------|
| Instalação   | `/usr/local/pgbouncer/`               |
| Configuração | `/etc/pgbouncer`      |
| Binários     | `/usr/local/pgbouncer/bin/`           |

&nbsp;  

**[#]** Variáveis de ambiente de pacotes:
```bash
# Pacotes comuns
PKG='gcc make wget pkg-config'

# Pacotes Debian
PKG_DEB="libsystemd-dev libevent-dev libssl-dev"
```  

**[#]** Instalação de pacotes e posterior limpeza de pacotes baixados:
```bash
apt update && apt install -y ${PKG} ${PKG_DEB} && apt clean
```  

**[#]** Criação de usuário de sistema:
```bash
useradd \
    -c 'PgBouncer system user' \
    -s /usr/sbin/nologin \
    -d /var/local/pgbouncer \
    -g postgres \
    -m -r pgbouncer  &> /dev/null
```  

**[#]** Permissionamento para o diretório do usuário:
```bash
chmod 770 ~pgbouncer
```  

**[#]** Criação de link para o diretório do pgbouncer:
```bash
ln -sv ~pgbouncer /etc/
```  

**[#]** Atribuição de variável de ambiente para versão completa do PogBouncer via prompt:
```bash
read -p \
    'Digite o número de versão completo (X.Y.Z) do PgBouncer a ser baixado: ' \
    VERSION
```
Última versão até então = 1.15.0  

**[#]** URL para baixar o PgBouncer:
```bash
URL="http://www.pgbouncer.org/downloads/files/\
${VERSION}/pgbouncer-${VERSION}.tar.gz"
```

**[#]** URL para baixar o PgBouncer:
```bash
URL="http://www.pgbouncer.org/downloads/files/\
${VERSION}/pgbouncer-${VERSION}.tar.gz"
```

**[#]** Baixar o PgBouncer para o diretório /tmp:
```bash
wget ${URL} -P /tmp/
```

**[#]** Acessar o diretório do código-fonte para a compilação:
```bash
cd /tmp  # Acessar /tmp
tar xvf pgbouncer-${VERSION}.tar.gz  # Descompactar o arquivo
cd pgbouncer-${VERSION}  # Acessar a pasta resultante
```

**[#]** Processo de configuração, com suporte a PAM, systemd e OpenSSL:
```bash
./configure --prefix /usr/local/pgbouncer --with-pam --with-systemd --with-openssl
```  

**[#]** Compilação e instalação:
```bash
make && make install
```  

**[#]** Criar diretório de logs com permissões somente para usuário e grupo:
```bash
mkdir -m 0770 /var/log/pgbouncer
```

**[#]** Criar arquivo de usuários:
```bash
echo '"postgres" ""' > /etc/pgbouncer/userlist.txt
```  

**[#]** Criação de arquivo de configuração:
```bash
cat << EOF > /etc/pgbouncer/pgbouncer.ini
[databases]
db_stone = host=127.0.0.1 port=5432 dbname=db_stone
 
[pgbouncer]
listen_port = 6432
listen_addr = 127.0.0.1
auth_type = trust
auth_file = /etc/pgbouncer/userlist.txt
logfile = /var/log/pgbouncer/pgbouncer.log
admin_users = postgres
pool_mode = transaction
default_pool_size=90
max_client_conn=3000
EOF
```  

**[#]** Mudando usuário e grupo proprietários:
```bash
chown pgbouncer:postgres ~pgbouncer/* /var/log/pgbouncer
``` 

**[#]** Criação do unit file do serviço do PgBouncer para o systemd:
```bash
cat << EOF > /etc/systemd/system/pgbouncer.service 
[Unit]
Description=connection pooler for PostgreSQL
Documentation=man:pgbouncer(1)
Documentation=https://www.pgbouncer.org/
After=network.target
#Requires=pgbouncer.socket

[Service]
Type=notify
User=postgres
ExecStart=/usr/local/pgbouncer/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
#LimitNOFILE=1024

[Install]
WantedBy=multi-user.target
EOF
```  

**[#]** Criação de arquivo de limits (file descryptors):
```bash
cat << EOF > /etc/security/limits.d/pgbouncer.conf
pgbouncer   soft    nofile 30000
pgbouncer   hard    nofile 30000
EOF
```  

**[#]** Habilitar e inicar o serviço imediatamente:
```bash
systemctl enable --now pgbouncer.service
```  

**[#]** Remover pacotes instalados:
```bash
apt purge -y ${PKG} ${PKG_DEB}
```

--- 

[**[Home]**](../README.md "Página inicial") - 
[**<**](00_install_postgres.md "Instalação do PostgreSQL via código-fonte") - 
[**>**](02_db.md "Criação da estrutura do banco de dados")