#!/bin/bash

#script bash para verificar estado de la red a través de ping en un bucle infinito
#GITHUB: matiasoviedo28
#recomiendo ejecutarlo directamente desde el servidor, o en caso de usar ssh usar "nohup ./verificar_red &" para evitar interrupciones inesperadas

#diccionario de servidores: nombre -> IP
declare -A SERVIDORES=(
    ["NODO1"]="192.168.100.1"
    ["NODO2"]="192.168.100.2"
    ["NODO3"]="192.168.100.3"
    ["NODO4"]="192.168.100.4"
    ["NODO5"]="192.168.100.5"
)

#colores
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
WHITE="\e[97m"

LOG_FILE="logs.txt"
STATUS_FILE="server_status.txt"

#función para manejar la interrupción con Ctrl+C
function detener_script {
    echo -e "\n${RED}Script detenido por el usuario.${RESET}"
    exit 0
}

#capturar la señal de interrupción (Ctrl+C)
trap detener_script SIGINT

#cargar el estado anterior de los servidores
declare -A ESTADO_SERVIDORES
if [ -f "$STATUS_FILE" ]; then
    while read -r LINE; do
        NOMBRE=$(echo "$LINE" | cut -d' ' -f1)
        ESTADO=$(echo "$LINE" | cut -d' ' -f2)
        ESTADO_SERVIDORES["$NOMBRE"]="$ESTADO"
    done < "$STATUS_FILE"
fi

#loop
while true
do
    #variable para llevar cuenta de servidores sin respuesta
    SERVIDORES_FALLIDOS=()

    #verificar cada servidor en la lista
    for NOMBRE in "${!SERVIDORES[@]}"
    do
        IP=${SERVIDORES[$NOMBRE]}
        #hacer ping con 5 intentos y esperar 1 segundo cada vez
        if ! ping -c 5 -W 1 "$IP" > /dev/null; then
            #imprimir en rojo para NO RESPONDE
            echo -e "${WHITE}$NOMBRE ($IP): ${RED}[NO RESPONDE]${RESET}"
            SERVIDORES_FALLIDOS+=("$NOMBRE")
            #registrar en el archivo de log con fecha y hora actual
            echo "$(date '+%d/%m/%y %H:%M:%S') $NOMBRE $IP no responde" >> "$LOG_FILE"
            #enviar correo si el estado cambió de OK a NO RESPONDE
            if [ "${ESTADO_SERVIDORES["$NOMBRE"]}" != "NO_RESPONDE" ]; then
                #llamar al script Python para enviar el correo en segundo plano
                python3 send_mail.py "$NOMBRE" "Alerta: $NOMBRE no responde" &
                #actualizar el estado a NO_RESPONDE
                ESTADO_SERVIDORES["$NOMBRE"]="NO_RESPONDE"
            fi
        else
            #imprimir en verde para OK
            echo -e "${WHITE}$NOMBRE ($IP): ${GREEN}[OK]${RESET}"
            #actualizar el estado a OK si estaba en NO_RESPONDE
            if [ "${ESTADO_SERVIDORES["$NOMBRE"]}" == "NO_RESPONDE" ]; then
                ESTADO_SERVIDORES["$NOMBRE"]="OK"
            fi
        fi
    done

    #guardar el estado de los servidores
    > "$STATUS_FILE"
    for NOMBRE in "${!ESTADO_SERVIDORES[@]}"; do
        echo "$NOMBRE ${ESTADO_SERVIDORES["$NOMBRE"]}" >> "$STATUS_FILE"
    done

    #esperar 30 segundos antes de la próxima iteración
    sleep 30
done
