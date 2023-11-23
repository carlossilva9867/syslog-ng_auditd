
## Configuração do Syslog-ng para Monitoramento de Eventos de Autenticação com Auditd

  

### Objetivo
Este script em bash e a configuração associada do `syslog-ng` foram desenvolvidos com o objetivo de facilitar a configuração do ambiente de monitoramento de eventos de autenticação gerados pelo serviço `auditd`. O script automatiza tarefas como backup, configuração e reinicialização do `syslog-ng` após alterações no arquivo de configuração, bem como a verificação de pré-requisitos importantes.

  

### Pré-requisitos

- O script deve ser executado com privilégios de root ou sudo.

- O serviço `auditd` deve estar instalado e em execução.

- O serviço `syslog-ng` deve estar instalado e em execução.

  

### Instruções de Uso

1. Clone este repositório para o seu sistema.

```

git clone https://github.com/carlossilva9867/syslog-ng_auditd

```

2. Altere os valores da variavel syslog_host e syslog_port para o endereço do servidor de syslog da rede

3. Execute o comando para executar o script

```

sudo chmod +x configure_syslog.sh && sudo ./configure_syslog.sh

```