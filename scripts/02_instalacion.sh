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

echo "---------------------------------------------------------"
echo "✨ FASE 2 COMPLETADA."
echo "---------------------------------------------------------"
