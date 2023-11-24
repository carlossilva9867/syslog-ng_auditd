# Objetivo
Este script tem como objetivo automatizar o processo de configuração do envio de logs do serviço auditd para um servidor syslog remoto (SIEM), utilizando o serviço syslog-ng presente na maioria dos sistemas operacionais baseados em Linux.

## Arquitetura (syslog-ng)
![imagem](https://github.com/carlossilva9867/syslog-ng_auditd/blob/main/img/arquitetura_syslog.png?raw=true)\
O serviço syslog-ng realiza o monitoramento do arquivo de log em /var/log/audit/audit.log, aplicando um filtro específico para selecionar chamadas de eventos específicas do auditd, como, por exemplo, `match("type=(USER_CMD)")`. Após esse processo de filtragem, os logs resultantes são enviados para um servidor remoto de syslog.

## Funcionamento do script

- Verificar se o serviço syslog está instalado.
- Verificar se o serviço auditd está instalado.
- Se os parâmetros de verificação estiverem OK, o script iniciará o processo de configuração do serviço syslog-ng.
 
## Etapas da execução do script
1) Realizar backup dos arquivos de configuração do syslog-ng para garantir a reversibilidade das alterações.

2) Configuração do syslog-ng para Envio Remoto:

3) Adicionar configurações ao syslog-ng para direcionar os logs do auditd para um servidor syslog remoto ou repositório remoto.

4) Reiniciar o serviço syslog-ng para aplicar as alterações feitas na configuração.

5) Validação da Inicialização do Serviço:

6) Verificar se o serviço syslog-ng foi reiniciado com sucesso.

### Sistemas operacionais testados
- [x] Ubuntu
- [x] Debian

## Observações:

- Certifique-se de executar o script com privilégios de root ou utilizando o sudo.

- Antes de executar em um ambiente de produção, é recomendável testar o script em um ambiente controlado.

- Este script foi testado em sistemas operacionais Debian e Red Hat, podendo necessitar de adaptações para outros sistemas Linux.

- Este script visa simplificar a tarefa de configurar a integração entre o serviço auditd e o syslog-ng, facilitando o monitoramento centralizado de eventos de segurança.

- Contribuições são bem-vindas para aprimorar e expandir as funcionalidades do script.

  

### Pré-requisitos

- O script deve ser executado com privilégios de root ou sudo.

- O serviço `auditd` deve estar instalado e em execução.

- O serviço `syslog-ng` deve estar instalado e em execução.

### Instalação

1) Clone o repositório ou copie o código para o seu sistema.

```
git clone https://github.com/carlossilva9867/syslog-ng_auditd
```
2) Entre no diretorio que que foi criado
```
cd syslog-ng_auditd
```

### Configuração
3) Altere os valores da variável os valores abaixo no arquivo no arquivo configure_syslog.sh
- **IP_SYSLOG_REMOTO**           - IP do servidor que será o repositorio de logs\
- **PORTA_SYSLOG_REMOTO** - Porta de destino do servidor syslog da rede (normalmente é a porta 514)
```
vi configure_syslog.sh
```
4) Execute o comando para executar o script
```
sudo chmod +x configure_syslog.sh && sudo ./configure_syslog.sh
```

----
## Forma manual 
### Arquivo de configuração utilizado (syslog-ng):
Caso queira adicionar a configuração do syslog manualmente no servidor, basta criar um arquivo de configuração em /etc/syslog-ng/conf.d/. Não se esqueça de alterar os valores $syslog_host e $syslog_port.
```
# Configuração AUDITD < SYSLOG > REMOTE LOG

# Log de origem (auditd)
source s_auditd {
file(/var/log/audit/audit.log flags(no-parse));
};

## Filter (OPCIONA) 
# Filtando por tipos de registros de auditoria
filter f_auditd {
	match("type=(USER_CMD|LOGIN|CRED_ACQ)");
};

## Declarando qual o servidor e porta que será o repositorio de log
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
Reinicie o serviço do syslog-ng
```
systemctl restart syslog-ng 
```
---
### Tipos de registros de auditoria (auditd)

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

Referencias: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sec-audit_record_types