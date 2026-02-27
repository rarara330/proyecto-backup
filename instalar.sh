#!/bin/bash
# Script de Instalación y Configuración Total - VERSIÓN ROBUSTA

USUARIO_WEB="www-data"
NUEVA_DIR_DESCARGAS="/var/www/html/Descargas"
DIR_BASE="/var/www/DescargadorWeb"

echo "==================================================="
echo "      INICIANDO INSTALACIÓN DEL DESCARGADOR        "
echo "==================================================="

# 0. Asegurar privilegios de root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (ej: sudo ./instalar.sh)"
  exit 1
fi

# 1. Obtener la ruta correcta (donde está este script)
DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# 2. Preparar el sistema base
echo "-> 1. Instalando Apache, PHP y dependencias básicas..."
apt-get update -qq
apt-get install -y apache2 php libapache2-mod-php php-curl unzip lsb-release curl wget git

# 3. Mover archivos al directorio de producción
echo "-> 2. Organizando archivos en $DIR_BASE..."
mkdir -p $DIR_BASE
# Copiamos usando la ruta absoluta detectada, asegurando que copiamos el contenido
cp -r "$DIR_ACTUAL"/* $DIR_BASE/
chmod +x $DIR_BASE/scripts/*.sh
echo "✅ Archivos copiados a $DIR_BASE"

# 4. Ejecutar scripts de dependencias
echo "-> 3. Ejecutando scripts de herramientas (yt-dlp, spotdl)..."
bash $DIR_BASE/scripts/01_dependencias.sh
bash $DIR_BASE/scripts/02_instalacion.sh

# 5. Configurar Web y Frontend
echo "-> 4. Configurando Entorno Web..."
mkdir -p $NUEVA_DIR_DESCARGAS
# Dar propiedad a Apache sobre las descargas y el código backend
chown -R $USUARIO_WEB:$USUARIO_WEB $NUEVA_DIR_DESCARGAS $DIR_BASE
chmod -R 775 $NUEVA_DIR_DESCARGAS

cp $DIR_BASE/codigo_fuente/descargador.php /var/www/html/Descargador.php
chown $USUARIO_WEB:$USUARIO_WEB /var/www/html/Descargador.php
echo "✅ Entorno web configurado."

# 6. Sudoers
echo "-> 5. Configurando Sudoers para $USUARIO_WEB..."
LINEA_SUDO="$USUARIO_WEB ALL=(ALL) NOPASSWD: $DIR_BASE/scripts/mega.sh"
# Eliminar línea anterior si existe para evitar duplicados
sed -i '\|/scripts/mega.sh|d' /etc/sudoers
echo "$LINEA_SUDO" | tee -a /etc/sudoers > /dev/null
echo "✅ Sudoers configurado."

# 7. Integrar Nube (MEGA)
echo "-> 6. Instalando integración en la nube..."
bash $DIR_BASE/scripts/03_integrar_nube.sh

echo "====================================================================================="
echo "🎉 INSTALACIÓN COMPLETADA."
echo "URL de acceso: http://$(hostname -I | awk '{print $1}')/Descargador.php"
echo "====================================================================================="
