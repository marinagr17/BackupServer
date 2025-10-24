#!/bin/bash

#script para backup incremental

#variables
COPIA="/var /etc /home /root /usr/local /opt /srv /boot"
DATE=$(date +%F)
LDEST="/mnt/vg1/full"
RUTA_LOCAL="/mnt/vg1/incr"

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

#desmontar disco
#sudo umount /mnt/vg1/
