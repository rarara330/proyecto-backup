#!/bin/bash

# 1. Detectar Distribución y Versión
OS=$(lsb_release -is 2>/dev/null || cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
VER=$(lsb_release -rs 2>/dev/null || cat /etc/os-release | grep -w "VERSION_ID" | cut -d= -f2 | tr -d '"')

echo "Detectado: $OS versión $VER"

# 2. Construir la URL según el sistema
if [ "$OS" == "Ubuntu" ]; then
    URL_OS="xUbuntu_$VER"
elif [ "$OS" == "debian" ]; then
    # Debian necesita el formato Debian_11.0 o Debian_12.0
    # Forzamos un decimal si no lo tiene
    [[ "$VER" != *.* ]] && VER_FIX="${VER}.0" || VER_FIX="$VER"
    URL_OS="Debian_$VER_FIX"
else
    echo "❌ Sistema no soportado automáticamente."
    exit 1
fi

URL="https://mega.nz/linux/repo/${URL_OS}/amd64/megacmd-${URL_OS}_amd64.deb"

# 3. Instalación
echo "Descargando desde: $URL"
wget "$URL" -O /tmp/megacmd.deb

if [ -f /tmp/megacmd.deb ]; then
    sudo apt update
    sudo apt install -y /tmp/megacmd.deb
    rm /tmp/megacmd.deb
    echo "✅ Instalación completada en $OS"
else
    echo "❌ No se pudo encontrar el paquete para tu versión específica en MEGA."
fi
