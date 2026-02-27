#!/bin/bash
export HOME=/home/wolf
export PATH=$PATH:/usr/bin
LOG="/var/www/html/mega_upload.log"

echo "[$(date)] --- Secuencia iniciada ---" >> $LOG

# Login usando el archivo de credenciales
/usr/bin/mega-login $(cat /home/wolf/.mega_creds) >> $LOG 2>&1

echo "[$(date)] Transfiriendo a MEGA..." >> $LOG
/usr/bin/mega-put /var/www/html/Descargas/* /DescargadorWeb/ >> $LOG 2>&1

if [ $? -eq 0 ]; then
    echo "[$(date)] ✅ OBJETIVO ALCANZADO: Archivos en la nube." >> $LOG
    rm -rf /var/www/html/Descargas/*
else
    echo "[$(date)] ❌ FALLO EN LA MATRIZ: Error de subida." >> $LOG
fi
