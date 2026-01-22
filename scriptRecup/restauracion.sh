#!/bin/bash

BACKUP_BASE=/mnt/vg1/


backup_restore() {
  echo "Copias disponibles:"
  find "$BACKUP_BASE" -mindepth 2 -maxdepth 2 -type d | sort
  read -p "Indica la ruta exacta del backup que quieres restaurar: " RESTORE_PATH
  if [[ ! -d "$RESTORE_PATH" ]]; then
    echo -e " Ruta no válida."
    exit 1
  fi
  echo -e "Restaurando sistema. Esto puede sobrescribir archivos."
  read -p "¿Confirmas la restauración? (yes/no): " CONFIRM
  case $CONFIRM in
  "yes")
    rsync -aAXHv "$RESTORE_PATH"/ /
    echo -e " Sistema restaurado desde $RESTORE_PATH"
  ;;
  *)
    echo -e " No se restaurará el sistema."
  ;;
esac
}


backup_restore
