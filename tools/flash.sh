#!/bin/bash
# Flash hardware-clinic.img to a USB stick safely (macOS and Linux). Lists removable drives, refuses system disks, confirms.
set -e
IMG=${1:-hardware-clinic.img}; [ -f "$IMG" ] || { echo "usage: flash.sh [image] — image not found: $IMG"; exit 1; }
echo "Removable drives:"
if [ "$(uname)" = Darwin ]; then
  diskutil list external physical | grep -E "^/dev/disk" | while read -r line; do echo "  $line"; done
  read -r -p "Device (e.g. disk4): " DEV; DEV=${DEV#/dev/}
  diskutil info "/dev/$DEV" | grep -q "Removable Media:.*Removable" || { echo "Refusing: /dev/$DEV is not a removable drive"; exit 1; }
  SIZE=$(diskutil info "/dev/$DEV" | awk -F'[()]' '/Disk Size/{print $2}' | awk '{print $1}'); echo "  $DEV: $SIZE bytes"
  read -r -p "Type the device name again to erase it and write the image: " CONFIRM; [ "$CONFIRM" = "$DEV" ] || { echo "cancelled"; exit 1; }
  diskutil unmountDisk "/dev/$DEV"; sudo dd if="$IMG" of="/dev/r$DEV" bs=1m status=progress; sync; diskutil eject "/dev/$DEV"
else
  lsblk -d -o NAME,SIZE,MODEL,TRAN,RM | awk 'NR==1 || $NF==1' | sed 's/^/  /'
  read -r -p "Device (e.g. sdb): " DEV; DEV=${DEV#/dev/}
  [ "$(lsblk -dn -o RM "/dev/$DEV")" = 1 ] || { echo "Refusing: /dev/$DEV is not marked removable"; exit 1; }
  mount | grep -q "^/dev/$DEV" && sudo umount "/dev/$DEV"* 2>/dev/null || true
  read -r -p "Type the device name again to erase it and write the image: " CONFIRM; [ "$CONFIRM" = "$DEV" ] || { echo "cancelled"; exit 1; }
  sudo dd if="$IMG" of="/dev/$DEV" bs=1M status=progress conv=fsync; sync
fi
echo "Done. Boot from the stick (PC: boot-menu key; Intel Mac: hold Option)."
