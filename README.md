
# syslog-ng_auditd

Este script em bash e a configuração associada do `syslog-ng` foram desenvolvidos com o objetivo de facilitar a configuração do ambiente de monitoramento de eventos de autenticação gerados pelo serviço `auditd`. O script automatiza tarefas como backup, configuração e reinicialização do `syslog-ng` após alterações no arquivo de configuração, bem como a verificação de pré-requisitos importantes.
  

### Pré-requisitos

- O script deve ser executado com privilégios de root ou sudo.
- O serviço `auditd` deve estar instalado e em execução.
- O serviço `syslog-ng` deve estar instalado e em execução.

### Configuração

**Variaveis**
syslog_host=192.168.15.133 # servidor remoto syslog
syslog_port=514 # porta

### Instalação
Clone o repositório ou copie o código para o seu sistema.
```
git clone https://github.com/carlossilva9867/syslog-ng_auditd
```

Altere os valores da variavel syslog_host e syslog_port para o endereço do servidor de syslog da rede

Execute o comando para executar o script
```
sudo chmod +x configure_syslog.sh && sudo ./configure_syslog.sh
```
### Arquivo de configuração utilizado (syslog-ng):

```
# Configuraççao do auditd para envio -> SYSLOG SERVER 
# Log de origem (auditd)
source s_auditd {
    file(/var/log/audit/audit.log flags(no-parse));
};

## Filter
# Filtando somente por tipos de eventos especificos 
filter f_auditd {
    #program("auditd");
    match("type=(USER_CMD|LOGIN|CRED_ACQ)");
};

## Destination 
# Envio de log via TCP para o syslog server
destination d_syslog_tcp {
    syslog("$syslog_host" transport("tcp") 
    port("$syslog_port")); 
};

## Envio
# Confiurando o envio de log para o syslog-server
log { 
    source(s_auditd);
    filter(f_auditd);
    destination(d_syslog_tcp);
};
```

### OPÇÕES PARA FILTRAGEM DE EVENTOS

| Nome             | Descrição                                        |
|------------------|--------------------------------------------------|
| ANOM_PROMISCUOUS | Detecta atividade de escuta em modo promíscuo na interface de rede. |
| AVC              | Alerta de Controle de Acesso (SELinux).           |
| BPF              | Falha na execução de um programa BPF (Berkeley Packet Filter). |
| CRED_ACQ         | Aquisição de credenciais.                        |
| CRED_DISP        | Descarte de credenciais.                         |
| CRED_REFR        | Atualização de credenciais.                      |
| LOGIN            | Registro de eventos de login no sistema.         |
| NETFILTER_CFG    | Mudança na configuração do Netfilter (iptables). |
| PROCTITLE        | Mudança no título do processo.                   |
| SERVICE_START    | Início de um serviço.                            |
| SERVICE_STOP     | Parada de um serviço.                            |
| SYSCALL          | Registro genérico de chamadas do sistema.        |
| USER_ACCT        | Modificação de informações de conta de usuário.  |
| USER_AUTH        | Eventos de autenticação de usuário.              |
| USER_CMD         | Execução de comandos pelo usuário.               |
| USER_END         | Término da sessão de usuário.                   |
| USER_START       | Início da sessão de usuário.                     |

