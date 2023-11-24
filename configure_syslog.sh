#/bin/bash
# Configuração do Syslog-ng para Monitoramento de Eventos de Autenticação com Auditd
# Versão 1.0
#Autor: [Carlos Silva](https://github.com/carlossilva9867)

# ==============================================================
#     ALTERE AS CONFIGURAÇÕES ABAIXO PARA O SEU SERVIDOR DE SYSLOG
# ==============================================================
export syslog_host=127.0.0.1
export syslog_port=514
#_______________________________________________________________

# Função para verificar se o script está sendo executado como root ou com sudo
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "[ERROR] - Este script precisa ser executado com privilégios de root ou sudo."
        exit 1
    fi
}

# Função para verificar se o serviço do syslog-ng está instalado
check_syslog_ng() {
    if command -v syslog-ng >/dev/null 2>&1; then
        echo "[OK] - Serviço syslog-ng já instalado no sistema operacional"
    else
        echo "[ERROR] - Serviço syslog-ng não encontrado. Instale o syslog-ng e execute o script novamente."
        echo "[INFO] - Para instalar o serviço digite apt install syslog-ng ou yum install syslog-ng"
        exit 1
    fi
}
# Função para verificar se o serviço auditd está instalado
check_auditd() {
    if command -v auditd >/dev/null 2>&1; then
        echo "[OK] - Serviço auditd já instalado no sistema operacional."
    else
        echo "[ERROR] - Serviço auditd não encontrado. Instale o auditd e execute o script novamente."
        echo "[INFO] - sudo apt install auditd" 
        exit 1
    fi
}

# Função para realizar backup dos arquivos de configuração do syslog-ng
backup_syslog_ng_conf() {
    local arquivo_config="/etc/syslog-ng/syslog-ng.conf"
    if [ -f "$arquivo_config" ]; then
        cp "$arquivo_config" "$arquivo_config.bak"
        echo "[OK] - Backup do arquivo de configuração do syslog-ng realizado com sucesso"
    else
        echo "[ERROR] - Arquivo de configuração não encontrado: $arquivo_config. Não foi possível fazer o backup. do syslog-ng"
        exit 1
    fi
}

# Função para verificar os pré requisitos 
pre_requisitos(){
    check_root
    check_syslog_ng
    check_auditd
}

# Função com as configurações do syslog-ng
syslog_ng_configure() {
echo  '
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

' > /etc/syslog-ng/conf.d/auditd-to-syslog.conf
}

# Função para reiniciar o serviço
restart_service() {
    echo "[INFO] - Reiniciando o serviço syslog-ng..."
    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart syslog-ng
    elif command -v service >/dev/null 2>&1; then
        service syslog-ng restart
    else
        echo "[ERROR] - Não foi possível determinar o sistema de inicialização. Reinicie o serviço manualmente."
        exit 1
    fi

    # Aguardar um breve momento antes de verificar o status
    sleep 2

    # Verificar se o serviço está em execução
    if pgrep -x "syslog-ng" >/dev/null; then
        echo "[OK] - Serviço reiniciado com sucesso."
    else
        echo "[ERROR] - Falha ao reiniciar o serviço. Verifique os logs para mais detalhes."
        exit 1
    fi
}

# Função com as configurações do auditd
auditd_configure() {
  echo "[INFO] - Iniciando a configuração do auditd"
}

# Função principal
main() {
    pre_requisitos
    backup_syslog_ng_conf
    syslog_ng_configure
    restart_service    
}
main