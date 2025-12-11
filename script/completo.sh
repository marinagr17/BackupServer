#!/bin/bash

#script para backup completo

#variables
COPIA="/var /etc /home /root /usr/local /opt /srv /boot"
DATE=$(date +%F)
RUTA_LOCAL="/mnt/vg1/full"
CLAVE="/home/debian/.ssh/backup"
DESTINO_REMOTO="debian@10.0.0.22:/mnt/backup/full/backup-$DATE"

#lo primero será montar la partición
#mount /dev/vg1/lv-backup /mnt/vg1/

#si no se ha montado:

if [ $? -ne 0 ]; then
        echo "La partición no se ha montado."
        exit 1
else
        echo "La partición se ha montado."
fi

#rsync para crear backup completo
rsync -aAXHzv --delete $COPIA $RUTA_LOCAL/backup-$DATE
#scp -i $CLAVE -r $RUTA_LOCAL/backup-$DATE debian@10.0.0.22:/home/debian/full/backup-$DATE
#enviar backup al servidor remoto
rsync -aAXHzv -e "ssh -i $CLAVE -o StrictHostKeyChecking=no" \
    $RUTA_LOCAL/backup-$DATE/ $DESTINO_REMOTO/

# Guardar la fecha del último backup completo para los incrementales
echo "$DATE" > "$RUTA_LOCAL/last_full"

#borrar copias con un mes de anitigüedad
find "$RUTA_LOCAL" -maxdepth 1 -type d -name "backup-*" -mtime +30 -exec rm -rf {} \;

# borrar copias remotas de más de 30 días
ssh -i "$CLAVE" debian@10.0.0.22 \
'find /mnt/backup/full -maxdepth 1 -type d -name "backup-*" -mtime +30 -exec rm -rf {} \;'
