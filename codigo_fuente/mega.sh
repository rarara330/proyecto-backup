#!/bin/bash

# =======================================================
# SCRIPT SUBIDA Y LIMPIEZA TOTAL (CON DIAGNÓSTICO EN PANTALLA)
# =======================================================

# 1. Variables de Configuración
LOCAL_DIR="/var/www/html/Descargas/pepe"
REMOTE_DIR="/pepe"
# Asegúrate de que este usuario tenga la sesión de MEGA iniciada (con mega-login)
USUARIO_REAL="raul" 
LOG_FILE="/tmp/mega_upload_pepe_$(date +%Y%m%d_%H%M%S).log"

# 2. Verificación de Superusuario (Obligatorio)
if [ "$EUID" -ne 0 ]; then
  echo "❌ ERROR: Debes ejecutar este script con sudo."
  echo "👉 Usa: sudo ./mega.sh"
  exit 1
fi

echo "--- Inicio de Subida y Diagnóstico (Usuario: $USUARIO_REAL) ---"
echo "Log guardado en: $LOG_FILE"
echo "------------------------------------------------------------------"

# 3. COMPROBACIÓN DE SESIÓN (Diagnóstico)
echo "🔍 Comprobando si $USUARIO_REAL está logueado en MEGA..."
# Ejecutamos whoami como 'raul' para ver si la sesión es válida.
MEGA_STATUS=$(sudo -u "$USUARIO_REAL" mega-whoami 2>&1)
EXIT_WHOAMI=$?

if [ $EXIT_WHOAMI -ne 0 ]; then
    echo "❌ ERROR CRÍTICO DE SESIÓN: El usuario $USUARIO_REAL NO está logueado o la sesión ha caducado."
    echo "------------------------------------------------------------------"
    echo "👉 ACCIÓN REQUERIDA:"
    echo "1. Cierra el script."
    echo "2. Ejecuta: mega-login"
    echo "3. Pon tus credenciales."
    echo "4. Vuelve a ejecutar: sudo ./mega.sh"
    echo "------------------------------------------------------------------"
    # NO borramos si el error es de sesión
    exit 1 
fi
echo "✅ Sesión de MEGA detectada. Subiendo archivos..."


# 4. SUBIDA A MEGA (como 'raul')
echo "☁️ Iniciando subida de $LOCAL_DIR a $REMOTE_DIR..."
# Ejecutamos la subida, capturando toda la salida para el log y para mostrar el error.
SUBIDA_OUTPUT=$(sudo -u "$USUARIO_REAL" mega-put "$LOCAL_DIR" "$REMOTE_DIR" 2>&1)
EXIT_CODE=$?

# Registramos el output de la subida en el log
echo "$SUBIDA_OUTPUT" >> "$LOG_FILE"

# 5. RESULTADO DE LA SUBIDA
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ SUBIDA EXITOSA."
else
    echo "⚠️ ERROR EN SUBIDA (Código $EXIT_CODE)."
    echo "------------------------------------------------------------------"
    echo "DETALLE DEL ERROR DE MEGA-PUT (Si está vacío, es error de sesión o ruta):"
    echo "$SUBIDA_OUTPUT"
    echo "------------------------------------------------------------------"
    echo "A pesar del error, el BORRADO INCONDICIONAL se ejecutará ahora."
fi

# 6. BORRADO NUCLEAR (Como Root)
echo "🗑️ Iniciando BORRADO INCONDICIONAL..."

# Si eres root, esto no puede fallar.
if rm -rf "$LOCAL_DIR"/* "$LOCAL_DIR"/.* 2>/dev/null; then
    echo "✨ Limpieza local completada."
else
    # Esto es solo si hay archivos inmutables (casi imposible)
    chattr -R -i "$LOCAL_DIR" 2>/dev/null
    rm -rf "$LOCAL_DIR"/* "$LOCAL_DIR"/.*
    echo "⚠️ Advertencia: Se forzó el borrado con chattr."
fi

echo "--- Fin del Script ---"
