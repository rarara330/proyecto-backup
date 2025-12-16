#!/bin/bash

# 1. Detectar Distribución y Versión
OS=$(lsb_release -is 2>/dev/null || cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
VER=$(lsb_release -rs 2>/dev/null || cat /etc/os-release | grep -w "VERSION_ID" | cut -d= -f2 | tr -d '"')

echo "--- [Iniciando] Sistema detectado: $OS $VER ---"

# 2. Construir la URL según el sistema
if [[ "$OS" =~ [Uu]buntu ]]; then
    URL_OS="xUbuntu_$VER"
elif [[ "$OS" =~ [Dd]ebian ]]; then
    # Debian en MEGA usa formato X.0 (ej: Debian_11.0)
    [[ "$VER" != *.* ]] && VER_FIX="${VER}.0" || VER_FIX="$VER"
    URL_OS="Debian_$VER_FIX"
else
    echo "❌ Sistema $OS no soportado automáticamente por este script."
    exit 1
fi

URL="https://mega.nz/linux/repo/${URL_OS}/amd64/megacmd-${URL_OS}_amd64.deb"

# 3. Instalación de MEGA
echo "Descargando MEGA desde: $URL"
if wget -q "$URL" -O /tmp/megacmd.deb; then
    sudo apt-get update
    sudo apt-get install -y /tmp/megacmd.deb
    rm /tmp/megacmd.deb
    echo "✅ MEGA CMD instalado correctamente."
else
    echo "❌ Error: No se pudo descargar el paquete. Verifica que MEGA soporte la versión $URL_OS"
    exit 1
fi

echo "-------------------------------------------------------"
echo "PROCESO FINALIZADO"
echo "Recuerda loguearte con: mega-login tu@email.com"
echo "-------------------------------------------------------"
