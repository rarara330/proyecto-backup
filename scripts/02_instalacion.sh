#!/bin/bash
echo "---------------------------------------------------------"
echo "🛠️  INICIANDO FASE 2: Instalación de Herramientas "
echo "---------------------------------------------------------"

# 1. FFmpeg
echo "🎬 Instalando FFmpeg..."
apt-get install -y ffmpeg

# 2. Python3 y PIP
echo "🐍 Instalando Python3 y Pip..."
apt-get install -y python3 python3-pip

# 3. yt-dlp (Binario oficial)
echo "📺 Instalando yt-dlp..."
if [ -f "/usr/local/bin/yt-dlp" ]; then
    /usr/local/bin/yt-dlp -U
else
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
    chmod a+rx /usr/local/bin/yt-dlp
fi
echo "✅ yt-dlp listo."

# 4. SpotDL (Con detección de flag de sistema)
echo "🎧 Instalando SpotDL..."
PIP_FLAG=""
if pip3 install --help | grep -q "break-system-packages"; then
    PIP_FLAG="--break-system-packages"
fi

# Instalamos usando el flag detectado
pip3 install spotdl $PIP_FLAG

# Crear enlace simbólico si se instala en el home del usuario root
if [ -f "$HOME/.local/bin/spotdl" ]; then
    ln -sf "$HOME/.local/bin/spotdl" /usr/local/bin/spotdl
fi
echo "✅ SpotDL listo."

echo "---------------------------------------------------------"
echo "✨ FASE 2 COMPLETADA."
echo "---------------------------------------------------------"
