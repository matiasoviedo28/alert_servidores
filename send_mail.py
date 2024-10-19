#script python para enviar correos electronicos de alerta, es llamado desde el otro .sh
#github: matiasoviedo28

import time
import smtplib
import sys
from datetime import datetime
import os

#variables para correo
mail = 'mail@examle.com'
discart = 'password de mail para api'
pas = discart
servidor = 'smtp.gmail.com'

#https://www.youtube.com/watch?v=OJxShAGAvLM

#archivo para registrar la ultima vez que se envio un correo
LAST_EMAIL_TIME_FILE = "last_email_time.txt"
MAIL_LOG_FILE = "mail_log.txt"
ERROR_LOG_FILE = "error_log.txt"

def sendmail(falla_server, subject):
    """
    Envía un correo electrónico con la información del servidor que no responde
    y registra el envío en el archivo de log.

    Parámetros:
        falla_server (str): Nombre del servidor que no responde.
        subject (str): Asunto del correo electrónico.
    """
    message = f"NO responde una parte de la red: {falla_server}"
    print("Mensaje:", message)
    print("Asunto:", subject)
    message_formatted = 'Subject: {}\n\n{}'.format(subject, message)

    try:
        with smtplib.SMTP(servidor, 587) as server:
            server.starttls()
            server.login(mail, pas)
            #enviar correo a los destinatarios
            destinatarios = [
                'tecnico1@example.com',
                'tecnico2@example.com',
                'tecnico3@example.com'
            ]
            for destinatario in destinatarios:
                server.sendmail(mail, destinatario, message_formatted)
                #registrar el envio en el archivo de log
                with open(MAIL_LOG_FILE, "a") as log_file:
                    log_file.write(f"{datetime.now().strftime('%d/%m/%y %H:%M:%S')} {destinatario} {message}\n")

            print("Correo enviado.")
    except Exception as e:
        print(f"Error al enviar el correo: {e}")
        #registrar el error en el archivo de log de errores
        with open(ERROR_LOG_FILE, "a") as error_file:
            error_file.write(f"{datetime.now().strftime('%d/%m/%y %H:%M:%S')} Error al enviar el correo: {e}\n")

def puede_enviar_correo():
    """
    Verifica si han pasado al menos 1 hora desde el último envío de correo.
    """
    UNA_HORA = 3600  #1 hora en segundos
    try:
        if os.path.exists(LAST_EMAIL_TIME_FILE):
            with open(LAST_EMAIL_TIME_FILE, "r") as file:
                last_email_time = float(file.read().strip())
            current_time = time.time()
            if (current_time - last_email_time) < UNA_HORA:
                print("No ha pasado 1 hora desde el último envío.")
                return False
    except Exception as e:
        print(f"Error al verificar el tiempo del último correo: {e}")
        #registrar el error en el archivo de log de errores
        with open(ERROR_LOG_FILE, "a") as error_file:
            error_file.write(f"{datetime.now().strftime('%d/%m/%y %H:%M:%S')} Error al verificar el tiempo: {e}\n")

    #actualizar el archivo con el tiempo actual
    with open(LAST_EMAIL_TIME_FILE, "w") as file:
        file.write(str(time.time()))

    return True

#verificar que se hayan pasado los argumentos necesarios
if len(sys.argv) < 3:
    print("Uso: python enviar_mail.py 'servidores_fallidos' 'asunto'")
    sys.exit(1)

#obtener los parametros de la linea de comandos
falla_server = sys.argv[1]
subject = sys.argv[2]

#enviar el correo solo si han pasado 1 hora desde el ultimo
if puede_enviar_correo():
    sendmail(falla_server, subject)
else:
    print("El correo no se enviará hasta que pase 1 hora.")
