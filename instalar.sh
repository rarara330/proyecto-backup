#!/bin/bash
# Script de Instalación y Configuración Total

USUARIO_WEB="www-data"
USUARIO_SISTEMA="wolf"
NUEVA_DIR_DESCARGAS="/var/www/html/Descargas"
DIR_BASE="/var/www/DescargadorWeb"

echo "==================================================="
echo "      INICIANDO INSTALACIÓN DEL DESCARGADOR        "
echo "==================================================="

# 1. Instalar Apache y PHP
sudo apt-get update
sudo apt-get install -y apache2 php libapache2-mod-php

# 2. Corregir y Mover el directorio del proyecto
# Obtenemos la ruta de donde está el script actualmente
DIR_ACTUAL=$(pwd)

echo "-> Organizando archivos en $DIR_BASE..."
sudo mkdir -p $DIR_BASE
# Copiamos el contenido de la carpeta actual a la carpeta base
sudo cp -r ./* $DIR_BASE/
echo "✅ Archivos movidos a $DIR_BASE"

# 3. Ejecutar dependencias
echo "-> 3. Ejecutando scripts de dependencias y herramientas..."
# Aseguramos permisos de ejecución
sudo chmod +x $DIR_BASE/scripts/*.sh
bash $DIR_BASE/scripts/01_dependencias.sh
bash $DIR_BASE/scripts/02_instalacion.sh

# 4. Crear y configurar directorios de descargas
echo "-> 4. Creando y Configurando Directorios de Descarga..."
sudo mkdir -p $NUEVA_DIR_DESCARGAS
sudo chown -R $USUARIO_WEB:$USUARIO_WEB $NUEVA_DIR_DESCARGAS
sudo chmod -R 777 $NUEVA_DIR_DESCARGAS
echo "✅ Directorio $NUEVA_DIR_DESCARGAS creado."

# 5. Copiar Frontend PHP
echo "-> 5. Copiando frontend PHP a /var/www/html/Descargador.php"
sudo cp $DIR_BASE/codigo_fuente/descargador.php /var/www/html/Descargador.php
sudo chown $USUARIO_WEB:$USUARIO_WEB /var/www/html/Descargador.php
echo "✅ Frontend PHP copiado."

# 6. Configurar sudoers
echo "-> 6. Configurando Sudoers..."
LINEA_SUDO="$USUARIO_WEB ALL=(ALL) NOPASSWD: $DIR_BASE/scripts/mega.sh"
sudo sed -i "/$(basename $DIR_BASE)\/scripts\/mega.sh/d" /etc/sudoers
echo "$LINEA_SUDO" | sudo tee -a /etc/sudoers > /dev/null
echo "✅ Sudoers configurado."

bash $DIR_BASE/scripts/03_integrar_nube.sh

echo "====================================================================================="
echo "🎉 INSTALACIÓN COMPLETADA."
echo "URL de acceso: http://$(hostname -I | awk '{print $1}')/Descargador.php"
echo "====================================================================================="
