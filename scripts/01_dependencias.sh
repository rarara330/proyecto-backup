#!/bin/bash
# --- [0/3] Configuración de Usuario Base ---
echo "👤 Verificando y creando usuario 'wolf'..."
if ! id -u wolf >/dev/null 2>&1; then
    # Crea el usuario 'wolf' y su directorio home
    sudo useradd -m wolf -s /bin/bash 
    sudo passwd -d wolf
    echo "   -> Usuario 'wolf' creado con éxito."
else
    echo "   -> Usuario 'wolf' ya existe. Saltando creación."
fi
# -------------------------------------------

echo "--- [1/3] Instalando Dependencias (Apache + PHP) ---"

# Actualizar repositorios
sudo apt-get update

# Habilitar Apache para que arranque al inicio
sudo systemctl enable apache2
sudo systemctl start apache2

echo "✅ Dependencias instaladas."
