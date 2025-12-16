#!/bin/bash
# Script de Instalación y Configuración Total

USUARIO_WEB="www-data"
USUARIO_SISTEMA="wolf"
NUEVA_DIR_DESCARGAS="/var/www/html/Descargas"
DIR_BASE="/var/www/ProyectoDescargadorWeb"

echo "==================================================="
echo "      INICIANDO INSTALACIÓN DEL DESCARGADOR        "
echo "==================================================="

# Instalar Apache y PHP (y la librería que conecta ambos)
sudo apt-get install -y apache2 php libapache2-mod-php

#Mover directorio
sudo mv 
cd "$(dirname "$0")"
sudo mv ../ProyectoDescargadorWeb /var/www/

# 1. Ejecutar dependencias
echo "-> 1. Ejecutando scripts de dependencias y herramientas..."
bash $DIR_BASE/scripts/01_dependencias.sh
bash $DIR_BASE/scripts/02_instalacion.sh

# 2. Crear y configurar directorios de descargas
echo "-> 2. Creando y Configurando Directorios de Descarga..."
sudo mkdir -p $NUEVA_DIR_DESCARGAS
sudo chown -R $USUARIO_WEB:$USUARIO_WEB $NUEVA_DIR_DESCARGAS
sudo chmod -R 777 $NUEVA_DIR_DESCARGAS
echo "✅ Directorio $NUEVA_DIR_DESCARGAS creado y con permisos."

# 3. Copiar Frontend PHP a la ruta final
echo "-> 3. Copiando frontend PHP a /var/www/html/Descargador.php"
# NOTA: Asegúrate de que descargador.php ya tiene las rutas del Paso 4.1
sudo cp $DIR_BASE/codigo_fuente/descargador.php /var/www/html/Descargador.php
sudo chown $USUARIO_WEB:$USUARIO_WEB /var/www/html/Descargador.php
echo "✅ Frontend PHP copiado."

# 4. Configurar sudoers para ejecución asíncrona (mega.sh)
sudo sed -i '/mega.sh/d' /etc/sudoers
echo "$LINEA_SUDO" | sudo tee -a /etc/sudoers > /dev/null
echo "✅ Sudoers configurado: www-data puede ejecutar mega.sh como root sin contraseña."
bash $DIR_BASE/scripts/03_integrar_nube.sh


echo "====================================================================================="
echo "🎉 INSTALACIÓN DEL DESCRAGADOR COMPLETADA."
echo "====================================================================================="
echo "⚠️ PASO FINAL REQUERIDO: Iniciar sesión en MEGAcmd"
echo "Para que la subida a MEGA funcione, el usuario '$USUARIO_SISTEMA' debe iniciar sesión."
echo "Ejecuta lo siguiente, sin sudo y como usuario '$USUARIO_SISTEMA', en tu terminal:"
echo "-------------------------------------------------------------------------------------"
echo "mega-login"
echo "-------------------------------------------------------------------------------------"
echo "http://$(hostname -I | awk '{print $1}')/Descargador.php"
