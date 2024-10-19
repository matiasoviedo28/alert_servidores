# Proyecto de Monitoreo y Alerta de Servidores

Este proyecto está diseñado para **monitorear el estado de los servidores en una red** y enviar **alertas por correo electrónico** en caso de que se detecten fallas. Está destinado a ser utilizado en un **ISP** para supervisar dispositivos críticos en la red y recibir notificaciones si algún servidor no responde.

### Funcionalidad

El sistema consiste en:
- Un **script Bash** que realiza verificaciones periódicas (ping) para determinar si los servidores están activos.
- Un **script Python** que se encarga de enviar correos electrónicos en caso de que se detecten fallas en la red.
- Un mecanismo para **evitar el envío repetitivo de correos**, enviando un correo solo si un servidor pasa de estado "OK" a "NO RESPONDE". El correo no se volverá a enviar hasta que el servidor responda al menos una vez.

### Tecnologías Utilizadas

- **Bash**: Para la automatización de tareas de verificación de red mediante el comando `ping`.
- **Python 3**: Para el envío de correos electrónicos utilizando el módulo `smtplib`.
- **SMTP**: Protocolo de envío de correo electrónico.

### Requisitos del Sistema

- **Python 3** instalado en el sistema.
- **Servidor SMTP** para el envío de correos electrónicos. En este proyecto, se utiliza el servidor SMTP de Gmail.
- **Acceso a la terminal** en un sistema Unix (como Linux o macOS).

### Instalación y Configuración

1. Clonar el repositorio

   Primero, clona el repositorio desde GitHub:
```bash
   git clone https://github.com/matiasoviedo28/alert_servidores.git  
   cd alert_servidores  
```

2. Configurar los scripts

   #### Script Bash (verificar_red.sh)

   Edita el archivo `verificar_red.sh` para agregar los nombres e IPs de los servidores a monitorear. Un ejemplo de configuración para una red típica de una **LAN privada** podría ser:
```bash
   declare -A SERVIDORES=(  
       ["SERVIDOR_A"]="192.168.1.10"  
       ["SERVIDOR_B"]="192.168.1.20"  
       ["SERVIDOR_C"]="192.168.1.30"  
   )  
```

   El script ejecutará pings a los servidores configurados y registrará su estado en un archivo `server_status.txt`. Solo enviará un correo cuando un servidor pase de "OK" a "NO RESPONDE" y no volverá a enviar hasta que el servidor responda al menos una vez.

   #### Script Python (send_mail.py)

   En el archivo `send_mail.py`, deberás configurar las credenciales y los destinatarios de los correos electrónicos. Edita las siguientes variables:
```python
   # Correo y contraseña del remitente  
   mail = 'tu_correo@gmail.com'  
   pas = 'tu_contraseña'  

   # Servidor SMTP  
   servidor = 'smtp.gmail.com'
```  
   si no haz creado un gmail y clave, te recomiendo este [video tutorial](https://www.youtube.com/watch?v=OJxShAGAvLM)

   El script también lleva un registro de los correos enviados en `mail_log.txt` y de los errores en `error_log.txt`. El envío de correos se controlará para que no se envíen más de una vez por hora.

3. Configurar permisos de ejecución

   Asegúrate de que el script Bash sea ejecutable:
```bash
   chmod +x verificar_red.sh 
   chmod +x send_mail.py
``` 

4. Ejecutar el monitoreo

   Puedes iniciar el monitoreo ejecutando el script Bash:
```bash
   ./verificar_red.sh 
``` 

   El script verificará continuamente el estado de los servidores y enviará un correo si detecta un cambio en el estado. La frecuencia de verificación es de **60 segundos**, y los correos se enviarán solo si un servidor no responde durante 5 pings consecutivos.

### Métodos Utilizados

1. **Verificación de Ping**

   El **script Bash** realiza pings a los servidores especificados para verificar su estado. Si un servidor no responde a 5 intentos de ping, se considera que está inactivo y se registra en un archivo de log.

2. **Envío de Correo con Python**

   El **script Python** se encarga de enviar un correo electrónico con la información del servidor que no responde. Utiliza el protocolo **SMTP** para conectarse a un servidor de correo (por ejemplo, Gmail). Los correos no se enviarán más de una vez por hora.

3. **Prevención de Spam**

   El script controla el envío de correos para que no se envíe un correo más de una vez por hora, y solo enviará un correo cuando un servidor pase de "OK" a "NO RESPONDE".

### Fortalezas

- **Automatización completa**: El monitoreo se realiza de manera continua y automática.
- **Alertas por correo electrónico**: Notifica al personal técnico en caso de fallas, lo que facilita la reacción rápida ante problemas.
- **Configuración flexible**: Permite modificar fácilmente la lista de servidores a monitorear y el intervalo de verificación.

### Debilidades

- **Dependencia del servicio SMTP**: Si el servidor SMTP falla o no es accesible, no se enviarán los correos.
- **Solo se realiza verificación de conectividad**: La detección de fallas se basa únicamente en la respuesta al ping, lo cual puede no ser suficiente para detectar otros tipos de problemas en los servidores.

### Ejemplo de Uso

En un **ISP**, este proyecto se puede utilizar para monitorear la conectividad de dispositivos clave en la red, como:

- Dslam
- Controladores de red
- Equipos de acceso
- Puntos de enlace críticos

Por ejemplo, en una configuración típica, los servidores a monitorear pueden estar dentro de la red interna, con IPs del rango **192.168.x.x** o **10.x.x.x**.

### Cómo Detener el Script

El script puede detenerse en cualquier momento presionando `Ctrl+C` en la terminal.

### Contribuciones

Para contribuir a este proyecto, por favor realiza un fork del repositorio y envía un pull request con tus cambios.
