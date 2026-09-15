#!/bin/bash
# Make Hardware Clinic Stick — macOS. Double-click it. Uses macOS dialogs; lists removable USB drives only; asks twice.
# If macOS says it "cannot be opened because it is from an unidentified developer": right-click → Open → Open.
#
# The write goes through Apple's authopen, which asks for the administrator password itself.
# Do NOT go back to `do shell script "dd ..." with administrator privileges`: on macOS 26 a dd
# started that way is refused raw access to removable disks ("Operation not permitted") even as
# root, because macOS no longer attributes it to Terminal. authopen is checked against Terminal's
# Removable Volumes permission instead. It writes to the buffered /dev/diskN (not /dev/rdiskN)
# because the raw node rejects writes that are not whole sectors, and authopen reads from a pipe.
cd "$(dirname "$0")" || exit 1
set -o pipefail

alert() { osascript -e 'on run argv' -e 'display alert (item 1 of argv) message (item 2 of argv) as critical' -e 'end run' "$1" "$2" >/dev/null 2>&1; }

IMG=$(ls hardware-clinic*.img 2>/dev/null | head -1)
if [ -z "$IMG" ]; then
  alert "Image not found" "Put this file in the same folder as hardware-clinic-<version>.img and run it again."
  exit 1
fi

# removable, external, physical disks only
CANDIDATES=()
while IFS= read -r dev; do
  [ -n "$dev" ] || continue
  info=$(diskutil info "$dev" 2>/dev/null)
  echo "$info" | grep -q "Removable Media:.*Removable" || continue
  echo "$info" | grep -q "Protocol:.*USB" || continue
  size=$(echo "$info" | awk -F'[()]' '/Disk Size/{print $2}' | awk '{printf "%.1f", $1/1000000000}')
  name=$(echo "$info" | awk -F': *' '/Device \/ Media Name/{print $2}')
  CANDIDATES+=("$dev — $name — ${size} GB")
done < <(diskutil list external physical | grep -E "^/dev/disk" | awk '{print $1}')

if [ ${#CANDIDATES[@]} -eq 0 ]; then
  osascript -e 'display alert "No USB stick found" message "Plug in a USB stick (at least 1 GB) and run this again. Everything on it will be erased." as warning' >/dev/null 2>&1
  exit 1
fi

LIST=$(printf '%s\n' "${CANDIDATES[@]}" | sed 's/"/\\"/g' | awk 'BEGIN{ORS=""} {if(NR>1)print ", "; print "\"" $0 "\""}')
CHOICE=$(osascript -e "choose from list {$LIST} with title \"Make Hardware Clinic Stick\" with prompt \"Which USB stick? EVERYTHING ON IT WILL BE ERASED.\" OK button name \"Continue\" cancel button name \"Cancel\"" 2>/dev/null)
if [ "$CHOICE" = "false" ] || [ -z "$CHOICE" ]; then exit 0; fi
DEV=$(echo "$CHOICE" | awk '{print $1}')

osascript -e "display dialog \"Erase $CHOICE and write Hardware Clinic to it?\n\nThis cannot be undone.\" with title \"Are you sure?\" buttons {\"Cancel\", \"Erase and write\"} default button \"Cancel\" with icon caution" >/dev/null 2>&1 || exit 0

if ! UM=$(diskutil unmountDisk "$DEV" 2>&1); then
  alert "Could not prepare the stick" "macOS would not release $DEV:
$UM

Close any window or app that is using the stick and run this again."
  exit 1
fi

echo "Writing $IMG to $DEV."
echo "macOS will ask for your administrator password. The write takes up to a minute."
ERR=$(dd if="$IMG" bs=1m 2>/dev/null | /usr/libexec/authopen -w "$DEV" 2>&1)
RC=$?
sync
diskutil eject "$DEV" >/dev/null 2>&1

if [ $RC -eq 0 ]; then
  echo "Done - the stick is ready."
  osascript -e 'display dialog "Your Hardware Clinic stick is ready.\n\nOn the other computer: plug it in, turn it on, and tap the boot-menu key (F12 on most PCs, Esc on HP; hold Option on an Intel Mac), then choose the USB drive.\n\nIf it says Secure Boot violation, turn Secure Boot off in the firmware setup for now." with title "Ready" buttons {"OK"} default button "OK"' >/dev/null 2>&1
else
  echo "Writing failed: ${ERR:-exit $RC}"
  HINT=""
  case "$ERR" in
    *"not permitted"*) HINT="

macOS blocked access to the USB stick. Open System Settings → Privacy & Security → Files & Folders → Terminal, turn on Removable Volumes, quit Terminal, and run this again." ;;
  esac
  alert "Writing failed" "${ERR:-The write did not complete (exit $RC).}$HINT"
fi
