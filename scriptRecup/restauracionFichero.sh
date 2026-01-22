#!/bin/bash

BACKUP_BASE=/mnt/vg1/

backup_restore() {
  echo "Copias disponibles:"
  find "$BACKUP_BASE" -mindepth 2 -maxdepth 2 -type d | sort

  read -p "Indica la ruta exacta del backup que quieres usar: " RESTORE_PATH
  if [[ ! -d "$RESTORE_PATH" ]]; then
    echo "Ruta no válida."
    exit 1
  fi

  echo
  echo "Contenido del backup:"
  ls "$RESTORE_PATH"

  read -p "Indica la ruta RELATIVA del archivo o directorio a restaurar (ej: etc/ssh): " ITEM
  SOURCE="$RESTORE_PATH/$ITEM"

  if [[ ! -e "$SOURCE" ]]; then
    echo "El archivo o directorio no existe en el backup."
    exit 1
  fi

  read -p "Indica el destino donde restaurar (ej: /etc): " DEST
  if [[ -z "$DEST" ]]; then
    echo "Destino no válido."
    exit 1
  fi

  echo
  echo "e va a restaurar:"
  echo "   Origen : $SOURCE"
  echo "   Destino: $DEST"

  read -p "¿Confirmas la restauración? (yes/no): " CONFIRM
  case "$CONFIRM" in
    yes)
      rsync -aAXHv "$SOURCE" "$DEST"
      echo "Restauración completada desde $RESTORE_PATH"
      ;;
    *)
      echo "No se restaurará nada."
      ;;
  esac
}

backup_restore
