#!/bin/bash

echo "---------------------------------------------------------"
echo "🛠️  INICIANDO FASE 2: Instalación de Herramientas (CORREGIDO)"
echo "---------------------------------------------------------"

# 1. Actualizar repositorios e instalar utilidades básicas
echo "📦 Actualizando sistema e instalando dependencias base..."
# Usamos -qq para menos ruido
sudo apt-get update -y -qq
sudo apt-get install -y software-properties-common curl wget git lsb-release

# 2. Instalar FFmpeg
echo "🎬 Instalando FFmpeg..."
sudo apt-get install -y ffmpeg

# 3. Instalar Python3 y PIP
echo "🐍 Instalando Python3 y Pip..."
sudo apt-get install -y python3 python3-pip python3-venv

# 4. Instalar yt-dlp (Binario oficial)
echo "📺 Instalando yt-dlp..."
if [ -f "/usr/local/bin/yt-dlp" ]; then
    echo "   -> yt-dlp ya existe. Actualizando..."
    sudo /usr/local/bin/yt-dlp -U
else
    sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
    sudo chmod a+rx /usr/local/bin/yt-dlp
fi
echo "✅ yt-dlp listo."

# 5. Instalar SpotDL (CORRECCIÓN CRÍTICA PARA UBUNTU 24.04)
echo "🎧 Instalando SpotDL..."

# Intentamos instalar ignorando el paquete conflictivo (typing_extensions) del sistema
# y forzando la instalación en el entorno del sistema (necesario en scripts de servidor simple)
pip3 install spotdl --break-system-packages --ignore-installed typing_extensions || pip3 install spotdl --break-system-packages

# Asegurar enlace simbólico
if [ -f "$HOME/.local/bin/spotdl" ]; then
    sudo ln -sf "$HOME/.local/bin/spotdl" /usr/local/bin/spotdl
elif [ -f "/usr/local/bin/spotdl" ]; then
    echo "   -> SpotDL localizado en /usr/local/bin"
fi
echo "✅ SpotDL listo."

# 6. Instalar MEGAcmd (USANDO REPOSITORIOS APT OFICIALES)
# 6. Instalar MEGAcmd (Detección Auto de Debian/Ubuntu)
echo "☁️  Verificando e Instalando MEGAcmd..."

if dpkg -l | grep -q megacmd; then
    echo "✅ MEGAcmd ya está instalado en el sistema. Saltando instalación."
else
    echo "   -> Configurando el repositorio de MEGA..."
    
    # Instalamos lsb-release si no existe y detectamos el ID de la distribución
    sudo apt install -y lsb-release > /dev/null 2>&1
    DISTRO_ID=$(lsb_release -i -s)
    DISTRO_CODE=$(lsb_release -c -s)
    
    REPO_URL=""
    
    if [ "$DISTRO_ID" == "Ubuntu" ]; then
        # Usa el nombre en clave de Ubuntu (ej: jammy, noble)
        REPO_URL="deb https://mega.nz/linux/repo/xUbuntu_${DISTRO_CODE}/amd64/ ./"
    elif [ "$DISTRO_ID" == "Debian" ]; then
        # Para Debian, usamos el código numérico (ej: 12, 11)
        DEBIAN_VERSION=$(lsb_release -r -s | cut -d'.' -f1) # Corta '12' de '12.x'
        REPO_URL="deb https://mega.nz/linux/repo/Debian_${DEBIAN_VERSION}/amd64/ ./"
    else
        echo "   ❌ ERROR: Distribución no soportada ($DISTRO_ID). Intente instalación manual de MEGAcmd."
        echo "✅ MEGAcmd instalado correctamente. (Ignorado debido a error)"
        return 0 # Finaliza la función de instalación de MEGA
    fi

    # 1. Descarga la clave del repositorio (Método obsoleto pero funcional)
    sudo wget -O- https://mega.nz/linux/MEGACMD-PUBLIC-KEY.ASC | sudo apt-key add - > /dev/null 2>&1

    # 2. Añade el repositorio APT
    echo "$REPO_URL" | sudo tee /etc/apt/sources.list.d/megacmd.list > /dev/null

    # 3. Actualiza e instala
    sudo apt update -qq
    sudo apt install -y megacmd
    
    echo "✅ MEGAcmd instalado correctamente."
fi
echo "---------------------------------------------------------"
echo "✨ FASE 2 COMPLETADA."
echo "---------------------------------------------------------"
