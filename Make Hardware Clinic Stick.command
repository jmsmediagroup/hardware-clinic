#!/bin/bash
# Make Hardware Clinic Stick — macOS. Double-click it. Uses macOS dialogs; lists removable USB drives only; asks twice.
# If macOS says it "cannot be opened because it is from an unidentified developer": right-click → Open → Open.
cd "$(dirname "$0")"
IMG=$(ls hardware-clinic*.img 2>/dev/null | head -1)
if [ -z "$IMG" ]; then osascript -e 'display alert "Image not found" message "Put this file in the same folder as hardware-clinic-<version>.img and run it again." as critical'; exit 1; fi

# removable, external, physical disks only
CANDIDATES=()
while IFS= read -r line; do
  dev=$(echo "$line" | awk '{print $1}')
  [ -n "$dev" ] || continue
  info=$(diskutil info "$dev" 2>/dev/null)
  echo "$info" | grep -q "Removable Media:.*Removable" || continue
  echo "$info" | grep -q "Protocol:.*USB" || continue
  size=$(echo "$info" | awk -F'[()]' '/Disk Size/{print $2}' | awk '{printf "%.1f", $1/1000000000}')
  name=$(echo "$info" | awk -F': *' '/Device \/ Media Name/{print $2}')
  CANDIDATES+=("$dev — $name — ${size} GB")
done < <(diskutil list external physical | grep -E "^/dev/disk" | awk '{print $1}')

if [ ${#CANDIDATES[@]} -eq 0 ]; then osascript -e 'display alert "No USB stick found" message "Plug in a USB stick (at least 1 GB) and run this again. Everything on it will be erased." as warning'; exit 1; fi

LIST=$(printf '%s\n' "${CANDIDATES[@]}" | sed 's/"/\\"/g' | awk 'BEGIN{ORS=""} {if(NR>1)print ", "; print "\"" $0 "\""}')
CHOICE=$(osascript -e "choose from list {$LIST} with title \"Make Hardware Clinic Stick\" with prompt \"Which USB stick? EVERYTHING ON IT WILL BE ERASED.\" OK button name \"Continue\" cancel button name \"Cancel\"" 2>/dev/null)
[ "$CHOICE" = "false" ] || [ -z "$CHOICE" ] && exit 0
DEV=$(echo "$CHOICE" | awk '{print $1}')

osascript -e "display dialog \"Erase $CHOICE and write Hardware Clinic to it?\n\nThis cannot be undone.\" with title \"Are you sure?\" buttons {\"Cancel\", \"Erase and write\"} default button \"Cancel\" with icon caution" >/dev/null 2>&1 || exit 0

diskutil unmountDisk "$DEV" >/dev/null 2>&1
RDEV="/dev/r${DEV#/dev/}"
# administrator password via the standard macOS prompt; dd runs with progress in this Terminal window
osascript -e "do shell script \"dd if='$(pwd)/$IMG' of='$RDEV' bs=1m 2>&1\" with administrator privileges" >/dev/null 2>&1
RC=$?
sync; diskutil eject "$DEV" >/dev/null 2>&1
if [ $RC -eq 0 ]; then
  osascript -e 'display dialog "Your Hardware Clinic stick is ready.\n\nOn the other computer: plug it in, turn it on, and tap the boot-menu key (F12 on most PCs, Esc on HP; hold Option on an Intel Mac), then choose the USB drive.\n\nIf it says Secure Boot violation, turn Secure Boot off in the firmware setup for now." with title "Ready" buttons {"OK"} default button "OK"' >/dev/null
else
  osascript -e 'display alert "Writing failed" message "Try another USB port or another stick." as critical'
fi
