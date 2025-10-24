#!/bin/bash

#script para backup completo

#variables
COPIA="/var /etc /home /root /usr/local /opt /srv /boot"
DATE=$(date +%F)
RUTA_LOCAL="/mnt/vg1/full"

#lo primero será montar la partición
#mount /dev/vg1/lv-backup /mnt/vg1/

#si no se ha montado:

if [ $? -ne 0 ]; then
        echo "La partición no se ha montado."
        exit 1
else
        echo "La partición se ha montado."
fi

#rsync
rsync -aAXHzv --delete $COPIA $RUTA_LOCAL/backup-$DATE 
#scp $RUTA_LOCAL/backup-$DATE debian@10.0.0.22:/home/debian/full/backup-$DATE


#desmontar disco
#umount /mnt/vg1/
