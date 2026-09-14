# Changelog

## 1.0.0-rc8 — Save my files
- **One-click stick makers**: `Make-Hardware-Clinic-Stick.exe` (Windows, self-contained, USB-only, admin-elevated, locked writes) and `Make-Hardware-Clinic-Stick.command` (macOS, native dialogs). Both beta: built and structurally verified, not yet run on real machines
- **Save my files**: new first menu item and `mode = savefiles`. Surveys every user's folders on every NTFS/ext4/APFS drive and counts by kind (photos, videos, documents, music), estimates time, waits for a USB drive to be plugged in (hot-plug detection), checks free space, copies with a progress bar and ETA, and ends with a plain-language result. Encrypted drives explained in plain words. Nothing on the computer is written
- Filesystem readers report file sizes (for the survey and progress)
- The technician tool is now **Advanced rescue** (key `a`)
- Regression: 3g wizard scenario with a hot-plugged drive, byte-identical check (40 checks)

## 1.0.0-rc7 — fixes from the first real machine (Acer Nitro AN515-55, i5-10300H)
- **SMART behind Intel RST**: the RAID-mode controller (8086:282a and friends) is now detected and named, with the exact BIOS change needed (storage mode → AHCI, with the Windows safe-mode step) instead of "no drives found"
- **AER**: the same correctable bit on every endpoint is recognised as ASPM link-power noise and no longer counted as errors (the Nitro logged 5/5 identical)
- **TPM**: larger capability buffer for firmwares with a bigger struct; fallback to the ACPI `TPM2`/`TCPA` tables when no protocol is offered (the Nitro reported "none" with a TPM present)
- **verify.py** finds a detached signature under `.JSON.SIG`, `_JSON.SIG` or `.SIG` (a renamed file verified as "NOT SIGNED")
- **REFERENCE.CSV** now ships seeded with the first real machine (i5-10300H: 216 Mops/s per core, 7139 MB/s memory read)
- First real-hardware results confirmed: memtest 16 GB clean on 8 cores, stress 70°C stable with 1% core spread, VRAM clean, 144 Hz AUO panel, Windows 11 22H2 detected off the drive, all four peripherals detected

## 1.0.0-rc6 — first real-hardware feedback (Acer Nitro 5)
- Display patterns now carry a caption strip: which pattern, what to look for, "Any key: next / Esc: skip" (a tester was dropped into a full-red screen with no explanation)
- Quick check announces the display test before taking over the screen
- SMART: connect storage controllers before probing (pass-through drivers may bind lazily); device-path fallback via ATA GetDevice / NVMe GetNamespace; clearer message pointing at RAID/RST storage mode
- Confirmed on real hardware (Nitro 5, 8 cores, NVIDIA x16 Gen3, 144 Hz AUO panel): boot, quick check, memtest, stress with temperature, VRAM, EDID, OS detection, AER counters

## 1.0.0-rc5 — release plumbing
- `soak_minutes` for short burn-ins; soak loop covered by the regression suite (41 checks)
- Text-mode fallback verified over a serial console (headless servers, KVM consoles)
- `make release` (image, ISO, BOOTX64.EFI, SHA256SUMS, docs, tools, zip); `tools/flash.sh` with removable-only safety; LICENSE (MIT); CONTRIBUTING.md
- Menu grouping fix (USB ports under CHECK)

## 1.0.0-rc4 — paper that verifies
- **Printable HTML certificate** (`WIPE-<serial>.HTML`) with the signed summary embedded as an SVG QR; regression decodes it and verifies the signature
- **MBR** as an alternative when rebuilding a partition table (legacy BIOS disks)
- **Update check**: `update_url` in CLINIC.CFG (or `update <url>` in the shell) fetches a version file and says whether the stick is current
- **ecdump** shell command for developers adding laptop sensor maps; refreshed `help`
- Regression 3c widened for the longer wipe flow (39 checks)

## 1.0.0-rc3 — the rest of the review list
- **Sensors**: fans/temperatures/voltages from Nuvoton/Winbond and ITE Super-I/O chips and the ThinkPad EC (untested in emulation — see developer guide); peripherals presence (audio, webcam, Bluetooth, touchpad/mouse via USB classes and PS/2 probe); PC-speaker beep test
- **Display & video**: VRAM read-back test through the framebuffer; 1-px checkerboard, lines, grey ramp, colour bars; panel refresh rate from EDID
- **TRIM** (NVMe deallocate) as a wipe method, labelled as not a certified erase; **DCO** detection on SATA drives, warned on certificates
- **Reference scores**: `REFERENCE.CSV` built from your own results (`compat.py --reference`); stress and memory benchmarks report "% of your typical <CPU>"
- Quick check now includes the VRAM test, display patterns and speaker

## 1.0.0-rc2 — Macs
- **APFS file rescue**: from-scratch reader (container checkpoints, object maps, Data/System volume selection, fs B-tree with multi-level descent, extents); FileVault volumes detected and refused with a clear message. Verified byte-identical against a volume validated by libfsapfs
- **macOS version** read from `SystemVersion.plist`; hardware scan lists APFS volumes
- `tools/apfs_inject.py` and an APFS volume in the regression bench (36 checks)

## 1.0.0-rc1 — fix what's broken, not just report it
- **Partition table**: GPT integrity check (both copies, CRCs) in the hardware scan and as a FIX tool; repairs a misplaced backup table; rebuilds a destroyed table from NTFS/ext4/FAT/exFAT/BitLocker signatures — verified to reproduce the original layout exactly
- **Clone** now relocates the backup GPT when the destination is larger (the SSD-upgrade case)
- **Soak test** (menu and `mode = soak`): memtest + stress (+ surface) cycles for 1–24 hours with a verdict
- **Stress test** flags a single core far slower than its siblings
- **Help overlay** (`?` / F1): which tool for which complaint
- Regression: 3f GPT rebuild scenario (34 checks)

## 1.0.0-beta8 — the professional UI, and four bench features
- **UI**: sidebar menu with a details pane (what it does, how long, last result, destructive marker), progress strip with elapsed time and ETA on every long operation, modal typed confirmations for destructive actions, report-cover verdict band, splash screen, muted/accent palette
- **Counterfeit-capacity test**: stamp every 16 MB, read back, report the real size
- **USB port test**: re-enumerates after each plug, counts working ports
- **Job intake**: ticket and customer in the header and on every certificate/report/HTML/JSON; `ticket =` / `customer =` in CLINIC.CFG
- **OS version** read off the drive: Windows build → marketing name; Linux PRETTY_NAME; whole-disk filesystems now scanned too
- Fixed: multi-core memtest race (passes of one chunk could run concurrently on two CPUs and report false faults)
- Regression: memtest asserts zero errors (33 checks)

## 1.0.0-beta7 — details that matter on a bench
- **Memory test names the module**: a fault address is mapped through SMBIOS type 20 to the slot locator and part number
- **Rescued files keep their dates** (NTFS `$STANDARD_INFORMATION`, ext4 inode times) via `SetInfo`
- **Issuer name** on certificates, reports, HTML and JSON (`issuer =` in CLINIC.CFG or `ISSUER.TXT`)
- **HTTPS upload**: `CA.DER` on the stick is installed into the firmware's TLS trust store; receiver gained `--tls-cert/--tls-key`
- **tools/compat.py**: compatibility table from a folder of RESULT files
- Regression: 3e HTTPS scenario (32 checks); `START_AT`/`STOP_AFTER` section selection

## 1.0.0-beta6 — results come to you
- **Network upload**: `upload = http://server/path` in CLINIC.CFG (or `upload <url>` in the shell) POSTs the signed RESULT JSON via the firmware's IPv4/HTTP stack (wired, DHCP); serial and signature travel as headers
- **tools/receive.py**: reference receiver that stores per-machine JSON + signature and verifies against the published key
- Regression: 3d upload scenario with a receiver on the host (31 checks)

## 1.0.0-beta5 — proof you can photograph
- **QR code** after every wipe and Quick check: a signed one-line summary (`HC1|...`) drawn on the framebuffer via qrcodegen (MIT); `tools/verify.py --qr` verifies a decoded photo. Regression decodes the screenshot with OpenCV and verifies it.
- **Full read-back verification** for wipes (interactive prompt; `wipe_verify = full` unattended), recorded on the certificate; an unreadable sector after erasure now fails certification
- **Hidden-area (HPA) detection** on SATA drives in Drive health and on certificates; warns that an overwrite cannot reach it
- Regression: 3c interactive-wipe-with-QR scenario (28 checks)

## 1.0.0-beta4 — Linux rescue, HTML report, session UX
- **ext4 file rescue**: extents and legacy block maps, 64-bit group descriptors, linear and hashed directories; verified byte-identical on 153 files. Filesystem readers now sit behind one interface (`rescue.h`); NTFS moved to `ntfs.c`
- **HTML report** `REPORT-<serial>.HTML`: verdict banner, result tables with badges, transcript, signed; written by every unattended job and by Save all
- **Menu session summary**: badges for everything run so far; **auto-save** of text/HTML/JSON on Reboot or Shut down
- **Unattended `rescue` mode** with `rescue_to = usb|stick`, all NTFS/ext4 volumes in one run
- Battery model, chemistry, design capacity and manufacture date in System info (SMBIOS type 22)
- Hardened NTFS/ext4 readers against corrupt geometry (divide-by-zero hang on a damaged partition)
- Regression: ext4 volume in the bench, unattended rescue scenario, HTML signature checks (27 checks)

## 1.0.0-beta3 — rescue, multi-core memtest, regression suite
- **File rescue**: from-scratch read-only NTFS (boot sector, MFT, fixups, resident/non-resident data, sparse runs, INDX blocks with bitmap, `$ATTRIBUTE_LIST` extension records). Copies user folders, a typed path, or the whole volume to any FAT drive; zero-fills unreadable gaps; skips compressed/encrypted with reasons; signed `RESCUE-*.TXT`. Verified byte-identical on 124 files across two users.
- **Memory test** rewritten: every core via MP Services pulling (chunk, algorithm) work items; solid, address-in-address, moving inversions, random-with-regeneration; reports first fault address with expected/read values
- **tests/regress.sh**: synthetic bench + four boot scenarios, 21 checks
- `make IMG_MB=n` for large sticks (rescue capacity)
- Regression section 0: Secure Boot enforced (image refused) and setup mode (detected); GitHub Actions workflow runs the suite on every push
- Fixed: `EFI_FILE_SYSTEM_INFO` layout; user list clobbered during rescue

## 1.0.0-beta2 — the full clinic
- **Hardware scan**: PCIe link speed/width per endpoint with downgrade detection and AER error counters; machine-check bank readout; network adapters with link state and MAC (deduplicated across firmware child handles); panel EDID; Secure Boot / setup mode / TPM 1.2 and 2.0; partition table with filesystem, BitLocker/LUKS detection and installed-OS inference
- **Clone drive**: sector copy with bisection around unreadable sectors (zero-filled and logged), sampled verification, signed `CLONE-*.TXT`
- **Boot repair**: list Boot#### entries and BootOrder, flag stale ones, discover Windows/Ubuntu/Fedora/Debian/fallback loaders on FAT volumes, create an entry and make it first, or reorder
- **Drive self-test**: ATA SMART short/extended with progress and element-level failure reasons; NVMe Device Self-test; abortable
- **Sector repair**: after a surface read, write zeros to the bad LBAs so the drive remaps them; reports how many recovered
- **Keyboard map**: on-screen US layout lighting each pressed key; reports keys never pressed
- **RAM details**: type, speed, configured speed, part number, slot per module; single-channel warning
- Quick check and unattended modes include the scan; `full` also runs drive self-tests; new verdict rows for error log, PCIe, network, encryption
- Every drive list shows model and serial
- JSON: `memory[]`, `pcie`, `errors`, `network`, `security`, `partitions[]`, `storage`, `selftest[]`, `repair`, `clone`, `boot`; facts update in place when a tool is re-run
- Fixed: UEFI error-code constants lacked the high bit (broke boot-entry creation)

## 1.0.0-beta1 — Hardware Clinic
- Renamed from MyOS to Hardware Clinic everywhere: screens, certificates, signature markers (`-----BEGIN HARDWARE CLINIC SIGNATURE-----`), volume label `HWCLINIC`, `clinic>` prompt
- New framebuffer UI: own font (DejaVu Sans Mono, embedded), header bar with machine model/serial and signing status, footer with key hints, palette, PASS/WARN/FAIL badges, red for failures; falls back to the firmware text console when no graphics output exists
- Menu regrouped (CHECK / DRIVES / OUTPUT / SYSTEM) with number-key shortcuts
- Verdict screen uses badges and a coloured overall bar; wipe screen carries a DESTRUCTIVE badge
- `make iso`: hybrid ISO for KVM consoles and VMs

## 0.9.0 — surface read and stress test
- Surface read: every sector, bisection isolation of unreadable sectors to the LBA, 50-segment speed profile with slow-zone marking
- Stress test: all cores via MP Services, CPU temperature via Intel DTS/PTM MSRs or AMD Zen SMN, TjMax-aware verdict, throttling and throughput-drop detection
- Memory bandwidth and disk sequential-read benchmarks; Quick check now includes both plus a 20 s stress
- Unattended `full` mode: whole-surface read of every drive and `stress_seconds` stress
- JSON: `bench`, `disk_bench[]`, `surface[]`, `stress`; verdict rows for disk read and cooling
- TSC-calibrated timing for all rates

## 0.8.0 — signed outputs
- Ed25519 signing of reports, JSON and wipe certificates using a per-stick `KEY.BIN`
- `make keys` (host key generator), `tools/verify.py` (host verifier, python-cryptography)
- Inline signature trailer for text files; detached `.SIG` for JSON
- Drive model and serial on certificates and in `wipes[]`; certificates named `WIPE-<drive serial>.TXT`

## 0.7.0 — unattended mode
- `CLINIC.CFG` on the stick: modes `quick`, `full`, `inventory`, `wipe-all`; `after = shutdown|reboot|menu`
- 5-second countdown escape hatch at boot
- Output files named by machine serial (`RESULT-<serial>.JSON`, `REPORT-<serial>.TXT`)
- `wipe-all` with explicit confirmation line, removable-drive exclusion, firmware/overwrite/auto method
- Wipe refactored into enumerate / execute / batch

## 0.6.0 — quick check
- One-minute triage: system, PCI/USB inventory, SMART, 30 s RAM pass, display and keyboard tests, verdict screen
- Structured facts layer and `RESULT.JSON` export
- Time-limited memory test; tools return results for orchestration

## 0.5.1
- Fixed: zero command timeouts (firmware treats 0 as "don't wait"); ATA erase timeout now derived from drive estimate, NVMe 1 h

## 0.5.0 — firmware secure erase
- NVMe Format NVM (crypto erase when supported) and ATA Security Erase (enhanced when supported)
- Device-path mapping from disk to controller; frozen-drive detection; password cleanup on failure
- Method choice in the wipe flow; certificate states NIST 800-88 level

## 0.4.0 — wipe and report
- Secure wipe by zero overwrite with boot-stick protection, typed confirmation, abort, sampled verification, certificate
- Session report capture and `REPORT.TXT`

## 0.3.0 — drive health and menu
- SMART via NVMe Get Log Page and ATA SMART READ DATA with plain-English verdicts
- Arrow-key menu

## 0.2.0 — clinic tools
- System info from CPUID and SMBIOS; disk listing; five-pattern RAM test

## 0.1.0
- Bootable UEFI kernel with a command shell
