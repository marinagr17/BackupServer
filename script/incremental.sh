#!/bin/bash

#script para backup incremental

#variables
COPIA="/var /etc /home /root /usr/local /opt /srv /boot"
DATE=$(date +%F)
#LDEST="/mnt/vg1/full"
RUTA_LOCAL="/mnt/vg1/incr"
CLAVE="/home/debian/.ssh/backup"

#obtener la fecha del ultimo backup completo
if [ -f /mnt/vg1/full/last_full ]; then
    LAST_FULL=$(cat /mnt/vg1/full/last_full)
    LDEST="/mnt/vg1/full/backup-$LAST_FULL"
else
    echo "No se encontró backup completo previo. Se requiere al menos un backup completo."
    exit 1
fi

#lo primero será montar la partición
#sudo mount /dev/vg1/lv-backup /mnt/vg1/
#si no se ha montado:

if [ $? -ne 0 ]; then
        echo "La partición no se ha montado."
        exit 1
else
        echo "La partición se ha montado."
fi

#rsync
sudo rsync -aAXHzv --delete --link-dest=$LDEST $COPIA $RUTA_LOCAL/back-$DATE
#scp -i $CLAVE -r $RUTA_LOCAL/back-$DATE debian@10.0.0.22:/home/debian/incr/back-$DATE
rsync -aAXHz --delete -e "ssh -i $CLAVE" $RUTA_LOCAL/back-$DATE/ debian@10.0.0.22:/mnt/backup/incr/back-$DATE/

#borrar copias que tengan un mes de antiguedad:
find "$RUTA_LOCAL" -maxdepth 1 -type d -name "back-*" -mtime +30 -exec rm -rf {} \;

# borrar copias remotas de más de 30 días (opcional)
ssh -i "$CLAVE" debian@10.0.0.22 'find /mnt/backup/incr -maxdepth 1 -type d -name "back-*" -mtime +30 -exec rm -rf {} \;'
