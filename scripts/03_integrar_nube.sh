#!/bin/bash
echo "--- [3/3] Integrando MEGA y Scripts de Backup ---"

# 1. Instalar megacmd (Detectando versión o usando genérico)
# Nota: La instalación de MEGA varía según la versión de Ubuntu.
# Este es un método genérico seguro instalando el .deb oficial
# pero lo más fiable es asegurar que `wget` está instalado.

sudo apt-get install -y wget

# Descargar e instalar megacmd (versión para Ubuntu genérica o 22.04/24.04 según corresponda)
# Aquí usamos el autoinstalador oficial o el paquete directo.
# Para simplificar y asegurar compatibilidad, añadimos el repo oficial:

if ! command -v mega-cmd &> /dev/null; then
    echo "Instalando MEGA CMD..."
    # Se necesita curl y gnupg
    sudo apt-get install -y curl gnupg2
    
    # Añadir repo oficial (Ejemplo para Ubuntu genérico, ajusta si sabes tu versión exacta)
    # Una forma segura es descargar el .deb directo si el repo falla, pero intentemos esto:
    wget https://mega.nz/linux/repo/xUbuntu_22.04/amd64/megacmd-xUbuntu_22.04_amd64.deb
    sudo apt install ./megacmd-xUbuntu_22.04_amd64.deb -y
    rm megacmd-xUbuntu_22.04_amd64.deb
else
    echo "MEGA CMD ya está instalado."
fi

# 2. Mover el script de backup a una carpeta segura (ej: /usr/local/bin o home)
SCRIPT_BACKUP="./backup_script.sh"
DESTINO_SCRIPT="/usr/local/bin/subir_pepe_mega.sh"

if [ -f "$SCRIPT_BACKUP" ]; then
    sudo cp "$SCRIPT_BACKUP" "$DESTINO_SCRIPT"
    sudo chmod +x "$DESTINO_SCRIPT"
    echo "✅ Script de backup instalado en: $DESTINO_SCRIPT"
else
    echo "⚠️ Advertencia: No encontré 'backup_script.sh' en la carpeta actual."
fi

echo "⚠️ IMPORTANTE: Recuerda ejecutar 'mega-login tu@email.com password' manualmente al terminar."
