# Hardware Clinic — User Guide

*For repair technicians and anyone diagnosing a PC or Intel Mac.*

Hardware Clinic is a bootable USB stick. Plug it in, boot from it, and within a second you have a menu of
hardware tests that run without Windows, macOS, or Linux. Nothing on the computer's own drive is
read or changed unless you explicitly choose **Secure wipe**.

---

## 1. Make the stick

You need a USB stick of 64 MB or larger (anything you own will do) and the file `myos.img`.
**Everything on the stick will be erased.**

**Easiest** — the stick makers in the release folder: `Make-Hardware-Clinic-Stick.exe` on Windows
(double-click, pick the stick, confirm) or `Make Hardware Clinic Stick.command` on macOS (double-click;
right-click → Open the first time). Both list USB sticks only. On Linux, `tools/flash.sh` does the same
in the terminal and asks you to type the device name twice.

**macOS**
```
diskutil list                          # find the stick, e.g. /dev/disk4 — check the size!
diskutil unmountDisk /dev/disk4
sudo dd if=myos.img of=/dev/rdisk4 bs=1m
diskutil eject /dev/disk4
```

**Linux**
```
lsblk                                  # find the stick, e.g. /dev/sdb — check the size!
sudo dd if=myos.img of=/dev/sdb bs=1M conv=fsync
```

**Windows** — open [Rufus](https://rufus.ie) or balenaEtcher, select `myos.img`, choose the stick,
write in **DD / image mode**.

The stick shows up afterwards as a small FAT32 volume named `HWCLINIC`. You can keep other files on it;
Hardware Clinic only needs `EFI\BOOT\BOOTX64.EFI` plus, optionally, `KEY.BIN` and `CLINIC.CFG`.

## 2. Boot from it

| Machine | How |
|---|---|
| Most PCs | Power on and tap the boot-menu key: **F12** (Dell, Lenovo, Acer), **F9** (HP), **F8** (ASUS), **Esc** or **F11** (others). Pick the USB entry that says *UEFI:*. |
| Intel Mac (2012–2020) | Hold **Option (⌥)** from power-on until the drive picker appears, choose **EFI Boot**. |
| Headless server / KVM console | Works: with no graphics output the same menu renders on the firmware text console (serial or BMC). |
| Apple Silicon Mac | Not supported. Apple firmware only boots Apple-signed systems from external media. Run Hardware Clinic in a VM (UTM) if you need it there. |

**If the stick doesn't appear in the boot menu:**
- Enter firmware setup (usually **F2** or **Del**) and disable **Secure Boot**. Hardware Clinic is not yet signed with a Microsoft key.
- Make sure **UEFI** boot is enabled (not *Legacy* / *CSM only*).
- Try a different USB port, preferably USB 2.0 or a rear port on desktops.
- Some HP and Lenovo firmwares need *Fast Boot* disabled before they will look at USB.

## 3. The menu

The menu is a sidebar: **Up/Down** moves, **Enter** runs, or press the key shown next to an item.
The pane on the right tells you what the selected tool does, how long it takes, its last result
this session, and whether it writes to anything. The header shows the machine's model and serial,
the current job (see *Job intake*), and whether the stick has a signing key. Long operations show
a progress strip with elapsed time and an estimate of what's left; destructive ones open a dialog
that asks you to type a word before anything is written. Every result screen ends with *Press any
key to return to the menu.*

Items are grouped: **CHECK** (whole-machine tests), **DRIVES**, **FIX** (things that change the machine), **OUTPUT** (saving), **SYSTEM**.
Every drive list shows the model and serial number so you never pick the wrong disk. Once you've
run anything, a **THIS SESSION** line under the menu shows the verdicts so far.

| Item | What it does | Time |
|---|---|---|
| **Quick check** | System info, inventory, SMART, 30 s RAM pass, memory/disk benchmarks, 20 s all-core stress, display and keyboard tests, then a one-screen verdict. Use this first. | ~2 min |
| **System info** | CPU model and features, firmware version, manufacturer, model, serial number, each RAM module with type, speed, part number and slot (warns when a single module means single-channel), battery model, chemistry, design capacity and manufacture date. | instant |
| **Hardware scan** | PCIe link speed/width per device (flags a drive stuck at x1), machine-check error banks (the "WHEA" errors behind random blue screens), PCIe AER error counters, network adapters with link up/down and MAC, panel EDID (maker, native resolution, size, year), Secure Boot and TPM state, every partition with filesystem, encryption (BitLocker/LUKS) and the installed OS **by version** — "Windows 11 23H2 (10.0.22631.2861)", "Ubuntu 24.04.1 LTS" or "macOS 14.6.1", read straight off the drive. | seconds |
| **Drive health** | Reads SMART from every internal NVMe and SATA drive: wear, temperature, power-on hours, bad sectors, with a HEALTHY / WORN / FAILING verdict. | seconds |
| **Drives** | Lists every disk with its capacity and sector size. | instant |
| **Memory test** | Uses every CPU core. Four algorithms over all free RAM: solid 0/1, address-in-address, moving inversions, and random with regeneration. On a fault, reports the physical address, expected and read values — and, on machines whose firmware maps addresses to slots, **which module** ("DIMM_A2 Kingston KF432C16BB/8"). | minutes |
| **Capacity test** | Catches counterfeit flash — the "1 TB" stick that is really 32 GB. Writes a 4 KB stamp every 16 MB across the reported capacity, reads them all back, and reports the real usable size when stamps vanish or wrap. Overwrites those 4 KB blocks only, but use it before formatting, not on a drive with data. | minutes |
| **USB ports** | Plug one device into each port in turn and press Enter; the tool re-enumerates USB and counts the ports where it appears. Finds dead ports. | 1 minute |
| **Surface read** | Reads every sector of a chosen drive (read-only). Isolates unreadable sectors to the exact LBA and draws a 50-segment speed profile; `!` marks zones reading at under half the drive's average. If bad sectors are found, offers **repair**: writing zeros makes the drive swap in spare sectors (data in them is already gone — clone first). | minutes (SSD) – hours (HDD) |
| **Stress test** | Loads every core for two minutes while reading CPU temperature (Intel DTS / AMD Zen). Detects thermal limit, throttling, performance drop-off, and a single core running far slower than its siblings. | 2 min |
| **Soak test** | For the machine that only fails after hours: memory test, five-minute stress, optionally a surface read of every drive, looping for 1–24 hours. Stops on any key after the current step. Ends with a stable / throttled / faulty verdict. | hours |
| **Sensors** | Fan speeds, temperatures and voltages from the Super-I/O monitor chip on desktops (Nuvoton/Winbond, ITE) or the embedded controller on ThinkPads; "no tachometer signal" when a fan header reports nothing. Then peripherals: audio controller, webcam (USB video), Bluetooth radio (USB), touchpad/mouse (PS/2 or USB HID). Other laptop makers' fan readings are vendor-specific and not yet supported — send the JSON to get a model added. | seconds |
| **Display & video** | VRAM test: five patterns written through the framebuffer and read back (catches failing video memory). Then display patterns for your eyes: solid colours, a 1-pixel checkerboard (stuck/dead pixels), 1-pixel lines (scaling, tearing), a grey ramp (banding), colour bars — with the panel's refresh rate from EDID. Then three beeps from the PC speaker. | 2 minutes |
| **Keyboard map** | Draws the keyboard and lights each key as you press it; lists the ones never pressed. Shift, Ctrl, Alt and Caps can't be sensed by firmware — shifted letters test Shift indirectly. | 1 min |
| **Self-test** | Runs the drive's own built-in short (2 min) or extended (hours) self-test and reports its verdict — the result manufacturers ask for in warranty claims. | 2 min+ |
| **Save my files** | The plain-language front door (see §3a): find, count, wait for a USB drive, copy, report. | minutes |
| **Advanced rescue** | Copies files off a Windows (NTFS), Linux (ext4) or Mac (APFS) drive onto any FAT-formatted drive — a second USB stick, or this one if built large. Choose the users' Desktop/Documents/Pictures/Downloads/Videos/Music, a folder you type, or the whole volume. Unreadable sectors leave zero-filled gaps and are logged rather than stopping the copy. Compressed and EFS-encrypted files are skipped with a reason. Files keep their original modification and creation dates. Writes a signed `RESCUE-*.TXT` log. | drive speed |
| **Clone drive** | Sector-by-sector copy to another drive of equal or larger size. Unreadable sectors are bisected, zero-filled on the destination and logged. Verified by sampling; writes a signed `CLONE-*.TXT` log. When the destination is larger, the backup partition table is moved to its end so the OS sees a clean disk and the extra space can be added to a partition. | drive speed |
| **Partition table** | Checks both copies of the GPT and their checksums. Rebuilds as GPT or, for legacy BIOS disks, MBR. Repairs a backup table that isn't at the end of the disk (typical after cloning to a larger drive). When the table is gone or damaged, scans the disk for NTFS, ext4, FAT, exFAT and BitLocker signatures and rewrites the table from what it finds — the files inside are untouched. | seconds; minutes to scan |
| **Boot repair** | Lists the firmware's boot entries (flags stale ones), finds Windows/Linux loaders on the EFI partition, and can add an entry and make it first, or reorder existing ones. Fixes "No bootable device" without reinstalling. | instant |
| **Secure wipe** | Erases a drive and writes a certificate. See §5. | seconds–hours |
| **Save all** | Writes the text report, the HTML report and the JSON to the stick. Also happens automatically when you choose Reboot or Shut down after running anything, so results are never lost. | instant |
| **Save HTML** | `REPORT-<serial>.HTML` — a clean page with the verdict, every result as tables with coloured badges, and the transcript. Open it on any computer, print it, or email it to the customer. Signed like everything else. | instant |
| **Save JSON** | Writes structured results for spreadsheets and fleet tools. | instant |
| **Command shell** | Typed commands for power users (§7). | — |
| **Reboot / Shut down** | Restart or power off. | — |

## 3a. "My computer won't start and my photos are on it"

That is the first item on the menu: **Save my files** (key `f`). It is written for someone who has
never used a tool like this. It looks for the personal folders on the computer's drive (Windows,
Mac or Linux), counts what it finds — "2,410 photos, 812 documents, 14 GB, about 6 minutes" — then
asks for a USB drive. Plug one in and it notices; it checks there is enough room; one key starts
the copy; a progress bar shows time remaining; and the result says exactly where the files are.
Nothing on the computer is changed. If the drive is FileVault- or BitLocker-encrypted it says so
in plain words instead of failing. Technicians who want to pick a folder or a whole volume use
**Advanced rescue** (key `a`) instead.

## 4. Reading the Quick check verdict

```
QUICK CHECK RESULT

  PASS  Memory      no faults in quick pass
  WARN  Drives      a drive is worn - plan replacement
  PASS  Disk read   sectors read cleanly
  PASS  Cooling     stable under full load
  PASS  Error log   no machine-check errors
  PASS  Network     link up
  WARN  Encryption  encrypted volume present - keys needed before any wipe or clone
  PASS  Display     even fill, no defects reported
  Keyboard      PASS   keys register
  Hardware      PASS   inventory captured (see report)

  WORN HARDWARE    Works today. Budget for a replacement.
```

Badges are green (PASS), yellow (WARN), red (FAIL). The overall bar at the bottom uses the same colours.

What the three overall lines mean for the customer conversation:

- **HARDWARE OK** — every test passed. If the machine still misbehaves, the fault is software: OS,
  drivers, malware, or a full disk. Don't sell them RAM.
- **WORN HARDWARE** — an SSD has used most of its rated life, or a hard drive has started
  reallocating sectors. It works now. Recommend a backup today and a replacement soon.
- **HARDWARE FAULT** — at least one FAIL line. Memory faults mean replace the RAM; a FAILING drive
  means stop using it and copy data off immediately; display or keyboard FAIL is whatever you saw.

Notes on individual lines:

- **Memory** in Quick check is a 30-second pass, enough to catch a dead module, not enough to
  catch a marginal one. For an intermittent-crash machine, run the full **Memory test** for an hour.
- **Drives WARN "no SMART data"** appears when the drive is behind a USB bridge or the firmware
  hides it. It's not a fault; it just couldn't be checked.
- **Disk read** in Quick check reads the first 256 MB of each drive — a speed sample and a canary.
  SMART reports what the drive admits; a read test finds what it doesn't. A FAIL here on a drive
  that SMART called healthy is real: run the full **Surface read** to see how bad.
- **Cooling** in Quick check is a 20-second load. A machine that overheats in 20 seconds has a
  serious cooling fault. For "crashes after an hour of gaming", run the full **Stress test**.
  If no temperature line appears, the CPU's sensor isn't readable (common in VMs); the test still
  measures throughput drop-off, which is the symptom that matters.
- **Error log** reads the CPU's machine-check banks. Corrected errors are a WARN (the machine is
  compensating for something — usually RAM); uncorrected ones are a FAIL and the cause of random
  crashes.
- **Encryption** is a warning, not a fault: it tells you a BitLocker or LUKS volume exists so you
  get the recovery key from the customer *before* cloning or wiping.
- **Display** and **Keyboard** are judged by you. During the display patterns a caption at the bottom
  of the screen names each pattern, says what to look for, and shows the keys (any key: next, Esc: skip). the screen fills with red, green, blue, white and
  black (press a key to step through) and asks whether every color was even. The keyboard test
  echoes each key so you can spot dead ones; press **Esc** when done.

Press **?** on the menu for a one-screen guide to which tool to reach for.

## 4a. Fixing things

**"The partition disappeared" / "disk shows as unallocated"** — run **Partition table**. If the GPT is
damaged it scans for the filesystems and writes the table back; the data was never touched.

**"No bootable device" / "Operating system not found"** — run **Boot repair**. If the OS is still on
the disk, its loader appears under *loaders found* and one keypress writes a fresh boot entry. If the
loader isn't found but the OS partition exists (Hardware scan shows NTFS), the EFI partition itself is
damaged and needs the OS's own repair tools.

**"My photos are on it and it won't boot"** — **Save my files** first, before any other test. Plug in a
FAT32 USB drive with enough space, pick the customer's Windows volume, choose *User folders*. Everything
readable is copied; the log lists anything that wasn't. Do this before Surface read or Clone, because
every hour of reading a failing drive is an hour closer to it dying.

**Upgrading to a bigger SSD** — **Clone drive** onto it; the partition table is fixed up for the new
size automatically. Extend the last partition from the OS afterwards.

**A drive with a few bad sectors** — rescue the files, then **Clone drive** to a new disk (the copy
skips the bad spots), then optionally **Surface read → repair** on the old drive to make it remap them.
A drive that keeps growing new bad sectors is finished regardless.

**Macs**: File rescue reads APFS, so an Intel Mac that won't boot is handled like a PC — unless
FileVault is on, in which case use macOS Recovery with the user's password.

**BitLocker / FileVault / LUKS drives** cannot be rescued or cloned meaningfully without the key. Get
the recovery key from the customer (Microsoft account, printout, IT department) and let the OS handle it.

**Slow new SSD** — Hardware scan's PCIe section shows the negotiated link; an NVMe drive at x1 or Gen1
is in the wrong slot or a slot shared with something else.

## 5. Secure wipe

**This destroys all data on the chosen drive. There is no undo.**

1. Choose **Secure wipe**. Every whole drive is listed with its size. The Hardware Clinic stick itself is
   marked *protected* and cannot be selected.
2. Press the drive's number. Press **Esc** to back out at any prompt.
3. Type `ERASE` and press Enter.
4. Choose a method:
   - **1) Firmware secure erase** — offered when the drive supports it and the firmware exposes it.
     Sends the drive's own erase command (NVMe Format with crypto or user-data erase; ATA Security
     Erase). Takes seconds on SSDs, reaches every cell including spare and remapped ones, and maps
     to NIST SP 800-88 **Purge**. Use this for SSDs whenever it's available.
   - **3) Deallocate (TRIM)**, NVMe only — the drive discards every block in seconds. Fine for
     resetting a drive you keep; **not** a certified erase (data can persist until garbage
     collection), and the certificate says so.
   - **2) Overwrite with zeros** — works on any drive including USB sticks and external disks.
     Runs at the drive's write speed (a 1 TB hard drive takes about two hours). Maps to NIST SP
     800-88 **Clear**. Press any key to abort; an aborted drive is unusable until reformatted.
5. Hardware Clinic reads back 66 sectors spread across the drive to confirm they are zero, then
   offers a **full read-back** of every sector (takes as long as reading the drive; the certificate
   then says "FULL read-back ... all zero" instead of "sampled"). It saves `WIPE-<drive serial>.TXT`
   on the stick and shows a **QR code**: a signed one-line summary of the erasure. Photograph it —
   the customer, or an auditor, can verify that photo later with `tools/verify.py --qr`.
6. On SATA drives the certificate also records whether a **hidden area (HPA)** exists, and whether a
   **Device Configuration Overlay (DCO)** hides more capacity below that — neither method reaches a
   DCO; remove it with the vendor tool first. An overwrite
   cannot reach hidden sectors; a firmware erase can, so prefer it whenever a drive reports one.

**"Firmware secure erase — unavailable: drive is FROZEN by firmware"** is common on SATA drives:
most PCs lock the security feature at boot. The workaround is to put the machine to sleep for a
few seconds, wake it, and re-run Hardware Clinic; if that doesn't unfreeze it, use the overwrite.

The stick is protected by matching the device path of the volume Hardware Clinic booted from. If Hardware Clinic ever
fails to identify its own stick it errs on the side of marking drives protected, never the reverse.

After a Quick check the verdict screen shows the same kind of QR code for the overall result.

### Reference scores
Put a `REFERENCE.CSV` on the stick and the stress and memory benchmarks print "96% of your typical
<CPU>". Build it from your own collected results — `tools/compat.py --reference received/ >
REFERENCE.CSV` — so the baseline is the machines you actually see, not someone else's numbers.

### Job intake
**Job intake** asks for a ticket number and customer name. They appear in the header and on every
certificate, report and HTML page for the session. For unattended sticks, `ticket =` and
`customer =` in `CLINIC.CFG` do the same.

### Your name on the certificates
Put a line `issuer = Your Shop Name` in `CLINIC.CFG`, or a file `ISSUER.TXT` on the stick containing
the name. It appears on every certificate, report and HTML page as "Issued by".

## 6. The files it leaves on the stick

| File | Contents |
|---|---|
| `REPORT-<serial>.TXT` | Every result from the session, as shown on screen, with a header and timestamp. |
| `REPORT-<serial>.HTML` | The customer-facing page: verdict banner, result tables, transcript. |
| `RESULT-<serial>.JSON` | The same data as structured JSON. `.JSON.SIG` beside it is its signature. |
| `WIPE-<drive serial>.TXT` | One certificate per erased drive (text, signed). |
| `WIPE-<drive serial>.HTML` | The same certificate as a printable page with the signed QR embedded — print it for the customer; the paper copy verifies by phone. |

`<serial>` is the machine's serial number from its firmware; when there isn't one, a
timestamp is used instead. If the stick has a signing key, each file carries a signature that
proves it was written by that stick and not edited afterwards — see the *Fleet Guide* for how a
customer or auditor can check it.

## 7. Command shell

Choose **Command shell** from the menu or type `menu` to go back.

```
help      show commands           smart     drive health
about     version and firmware    wipe      secure wipe
sysinfo   system information      save      write REPORT-<serial>.TXT
disks     list drives             json      write RESULT-<serial>.JSON
memtest   test all free RAM       quick     quick check
surface   read every sector       stress    all-core load test
hwscan    hardware scan           selftest  drive self-test
rescue    copy files off NTFS
clone     clone a drive           bootfix   boot entries
keymap    keyboard map            mem       memory map summary
time      real-time clock
clear     clear screen            reboot / shutdown
```

## 8. Limits to know about

- **Memory test coverage** is the RAM the firmware reports as free, typically 90 %+; firmware,
  the framebuffer and Hardware Clinic itself occupy the rest. Four algorithms on all cores is a
  serious test; MemTest86 still has more (bit fade, hammer) for marginal-cell hunting.
- **File rescue reads NTFS, ext4 and APFS.** FileVault-encrypted APFS volumes cannot be read without
  the user's password (the tool says so and stops); on a modern Mac the *Data* volume is chosen
  automatically. btrfs/XFS: clone the drive and read it on a Linux machine. Files over 4 GB can't be
  written to FAT32. NTFS-compressed, EFS-encrypted, APFS-compressed and ext4 inline-data files are
  skipped and listed in the log.
- **SMART thresholds are conservative rules of thumb**, not the manufacturer's. A drive can be
  WORN by Hardware Clinic's rules and still have years left; FAILING is always worth acting on.
- **Wipe verification is sampled**, not a full read-back. It confirms the command took effect,
  not that every sector was checked.
- **The clock comes from the machine's RTC.** If that clock is wrong, timestamps in reports will be
  wrong too. System info shows the RTC so you can spot it.
- **Fan speeds** come from desktop Super-I/O chips and ThinkPad ECs; other laptops use vendor-specific
  controllers the tool doesn't know yet. **Input lag** cannot be measured without an external sensor;
  the refresh rate shown is the panel's native rate from EDID, not what the OS will run.
- **Battery health** beyond design data isn't readable. CPU temperature needs an Intel CPU with a digital sensor or an AMD Zen; other CPUs show throughput only.
