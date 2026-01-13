#!/bin/bash
# =====================================
# SCRIPT DE RECUPERACIÓN DEL SISTEMA
# =====================================

set -e

# VARIABLES
VG_DEV="/dev/vg1/lv-backup"
MOUNT_BACKUP="/mnt/vg1"
BACKUP_FULL="$MOUNT_BACKUP/full"
BACKUP_INCR="$MOUNT_BACKUP/incr"
LOG="/var/log/restore.log"

# RESTAURAR
DEST="/"

echo "===== INICIO RESTAURACIÓN =====" | tee -a "$LOG"

#  Montar disco de backups
if ! mountpoint -q "$MOUNT_BACKUP"; then
    echo "Montando volumen de backup..." | tee -a "$LOG"
    mount "$VG_DEV" "$MOUNT_BACKUP"
fi

#  Seleccionar backup completo
echo "Backups completos disponibles:" | tee -a "$LOG"
ls -1 "$BACKUP_FULL"

read -rp "Introduce la fecha del backup completo (YYYY-MM-DD): " FECHA_FULL
FULL_PATH="$BACKUP_FULL/backup-$FECHA_FULL"

if [ ! -d "$FULL_PATH" ]; then
    echo "❌ Backup completo no encontrado" | tee -a "$LOG"
    exit 1
fi

echo "Usando backup completo: $FULL_PATH" | tee -a "$LOG"

#  Restaurar backup completo
rsync -aAXHv --numeric-ids \
    --exclude={"/proc/*","/sys/*","/dev/*","/tmp/*","/run/*","/mnt/*"} \
    "$FULL_PATH/" "$DEST" | tee -a "$LOG"

# 4 Aplicar incrementales (si existen)
echo "¿Deseas aplicar backups incrementales posteriores? (s/n)"
read -r RESP

if [[ "$RESP" == "s" ]]; then
    for incr in "$BACKUP_INCR"/back-*; do
        INCR_DATE=$(basename "$incr" | sed 's/back-//')

        if [[ "$INCR_DATE" > "$FECHA_FULL" ]]; then
            echo "Aplicando incremental: $incr" | tee -a "$LOG"
            rsync -aAXHv --numeric-ids \
                --exclude={"/proc/*","/sys/*","/dev/*","/tmp/*","/run/*","/mnt/*"} \
                "$incr/" "$DEST" | tee -a "$LOG"
        fi
    done
fi

#  Restaurar lista de paquetes
if [ -f "$FULL_PATH/paquetes_instalados.txt" ]; then
    echo "Restaurando paquetes..." | tee -a "$LOG"
    dpkg --set-selections < "$FULL_PATH/paquetes_instalados.txt"
    apt-get dselect-upgrade -y
fi

echo " RESTAURACIÓN COMPLETADA" | tee -a "$LOG"
echo " Reinicia el sistema cuando estés listo."
