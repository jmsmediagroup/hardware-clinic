# Hardware Clinic — File Formats

All files are written to the root of the stick's FAT32 volume. Text is ASCII with `\n` line endings.
Characters outside ASCII are replaced by `?`.

---

## Naming

| File | Name | Fallback when the machine has no serial |
|---|---|---|
| Report | `REPORT-<machine serial>.TXT` | `REPORT-YYYYMMDD-HHMMSS.TXT` |
| HTML report | `REPORT-<machine serial>.HTML` | `REPORT-YYYYMMDD-HHMMSS.HTML` |
| JSON | `RESULT-<machine serial>.JSON` (+ `.JSON.SIG`) | `RESULT-YYYYMMDD-HHMMSS.JSON` |
| Wipe certificate | `WIPE-<drive serial>.TXT` | `WIPE-YYYYMMDD-HHMMSS-<n>.TXT` |
| Clone log | `CLONE-YYYYMMDD-HHMMSS.TXT` | — |
| Rescue log | `RESCUE-YYYYMMDD-HHMMSS.TXT` (files go to `\RESCUE-YYYYMMDD-HHMMSS\` on the destination) | — |

Serial numbers are copied as-is except that characters outside `A–Z a–z 0–9 - _` become `_`.
The machine serial comes from SMBIOS type 1; drive serials from NVMe Identify Controller or ATA
IDENTIFY DEVICE.

## RESULT JSON

```json
{
  "tool": "Hardware Clinic",
  "issuer": "Riverside Computer Repair",
  "version": "1.0.0",
  "generated": "2026-09-10 00:12:34",
  "system": {
    "cpu": "Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz",
    "manufacturer": "Dell Inc.", "model": "Latitude 7490", "serial": "ABC1234",
    "firmware": "1.28.0", "ram_mb": 16384, "dimms": 2, "cores": 4,
    "battery": "DELL 7XJF9", "battery_design_mwh": 60000
  },
  "memory": [
    { "mb": 8192, "type": "DDR4", "part": "KF432C16BB/8", "slot": "DIMM_A", "mts": 3200 }
  ],
  "hardware": {
    "pci_00": "NVMe controller 144d:a808",
    "pci_01": "Display 8086:5917",
    "pci_02": "Wireless network 8086:24fd",
    "has_ethernet": 1, "has_wifi": 1, "has_gpu": 1, "has_audio": 1,
    "usb_devices": 3
  },
  "pcie":     { "endpoints": 4, "downgraded_links": 1, "aer_errors": 0 },
  "errors":   { "mce_banks": 20, "mce_logged": 0, "mce_uncorrected": 0 },
  "network":  { "nic0": "up", "nic1": "down", "interfaces": 2, "links_up": 1 },
  "security": { "secure_boot": "enabled", "tpm": "TPM 2.0" },
  "partitions": [
    { "mb": 260, "type": "FAT (EFI system partition?)", "encrypted": 0 },
    { "mb": 487000, "type": "BitLocker (encrypted)", "encrypted": 1 }
  ],
  "storage":  { "encrypted_volumes": 1, "installed_os": "macOS 14.6.1 + Windows" },
  "job":      { "ticket": "T4421", "customer": "J. Smith" },
  "savefiles": { "files_found": 3247, "bytes_found": 15234567890, "photos": 2410, "documents": 812, "videos": 25, "files_saved": 3247, "bytes_saved": 15234567890, "skipped": 0, "partial": 0, "result": "SAVED" },
  "capacity": { "reported_bytes": 1099511627776, "stamps": 65536, "stamps_ok": 1980, "real_bytes_estimate": 33218887680, "result": "COUNTERFEIT" },
  "usb_ports": { "tested": 4, "working": 3 },
  "sensors":  { "chip": "Nuvoton NCT6798D", "fan1_rpm": 1180, "fan2_rpm": 0, "temp1_c": 38, "vcore_mv": 1024, "fans_reporting": 1 },
  "peripherals": { "audio": 1, "webcam": 1, "bluetooth": 1, "pointing": 1, "usb_keyboard": 0, "speaker": "heard" },
  "gpu":      { "vram_tested_mb": 32, "vram_errors": 0, "vram_result": "PASS" },
  "soak":     { "cycles": 6, "minutes": 480, "ram_errors": 0, "stress_worst": 0, "result": "PASS" },
  "partition_table": { "gpt": "rebuilt", "found_partitions": 2 },
  "drives": [
    { "type": "NVMe", "model": "SAMSUNG MZVLB512HAJQ", "serial": "S3TNNX0K123456",
      "life_pct": 94, "temp_c": 41, "hours": 8120, "power_cycles": 1432,
      "media_errors": 0, "gb_written": 22410, "verdict": "HEALTHY" },
    { "type": "SATA", "model": "ST1000LM035-1RK172", "serial": "WDE1AB2C",
      "hours": 15022, "power_cycles": 2210, "temp_c": 36,
      "reallocated": 8, "pending": 0, "uncorrectable": 0, "verdict": "WORN" }
  ],
  "selftest": [ { "type": "NVMe", "model": "SAMSUNG MZVLB512HAJQ", "result": "PASS" } ],
  "memtest":  { "tested_mb": 15410, "work_mb": 61640, "cores": 8, "errors": 0, "result": "PASS" },
  "rescue":   { "files": 4123, "bytes": 18234567890, "skipped": 2, "partial": 1, "read_errors": 7, "volumes": 1 },
  "bench":    { "mem_write_mbs": 9800, "mem_read_mbs": 12400 },
  "disk_bench": [
    { "bytes_read": 268435456, "bad_sectors": 0, "avg_mbs": 1820, "min_mbs": 1650, "max_mbs": 2010, "slow_zones": 0, "result": "PASS" }
  ],
  "surface": [
    { "bytes_read": 512110190592, "bad_sectors": 3, "avg_mbs": 1710, "min_mbs": 12, "max_mbs": 2050, "slow_zones": 2, "result": "FAIL" }
  ],
  "repair":   { "bad_sectors": 3, "remapped": 3 },
  "clone":    { "bytes": 512110190592, "bad_sectors": 3, "write_errors": 0, "result": "COMPLETE_WITH_GAPS" },
  "boot":     { "entries": 4, "loaders_found": 1, "action": "entry_added" },
  "stress":   { "cores": 8, "slowest_core": 5, "core_spread_pct": 4,, "seconds": 120, "peak_temp_c": 91, "tjmax_c": 100,
                "mops_per_core_start": 310, "mops_per_core_end": 214, "throttled": 1, "result": "WARN" },
  "display":  { "width": 1920, "height": 1080, "result": "PASS" },
  "keyboard": { "distinct_keys": 61 },
  "wipes": [
    { "model": "SAMSUNG MZVLB512HAJQ", "serial": "S3TNNX0K123456", "bytes": 512110190592,
      "method": "NVMe Format NVM with cryptographic erase (NIST SP 800-88 'Purge')",
      "result": "PASS", "certificate": "WIPE-S3TNNX0K123456.TXT", "verification": "full", "hpa_hidden_sectors": 0 }
  ],
  "upload":   { "http_status": 201, "result": "OK" },
  "verdict": { "overall": "OK" }
}
```

Field notes:

- **Sections are present only if the corresponding test ran.** `display` and `keyboard` never
  appear in unattended runs. `wipes` appears only after a wipe.
- `system.firmware` is the firmware (BIOS/UEFI) version string, not the vendor.
- `hardware.pci_NN` lists PCI devices in enumeration order as `"<class> <vendor>:<device>"` in hex.
  Bridges are omitted. `has_*` flags are derived from the class codes.
- `drives[]` fields differ by type. NVMe: `life_pct` is `100 − Percentage Used` from the SMART log
  (capped at 0); `gb_written` is Data Units Written × 512 000 / 10⁹. SATA: `reallocated`,
  `pending`, `uncorrectable` are the raw values of SMART attributes 5, 197, 198; `temp_c` from
  194 or 190; `hours` from 9; `power_cycles` from 12.
- `drives[].verdict` and `verdict.overall` use the rules in §Verdicts below.
- `disk_bench[]` (Quick check: first 256 MB per drive) and `surface[]` (Surface read / `full`:
  whole drive) share a layout. `slow_zones` counts 1/50th-of-the-drive segments that read at
  under half the running average. `result` is `FAIL` if `bad_sectors > 0`, `WARN` if
  `slow_zones ≥ 3`, `PARTIAL` if aborted, else `PASS`. Entries are in drive-enumeration order,
  excluding the Hardware Clinic stick.
- `memory[]` is one entry per populated module from SMBIOS type 17; `type` is empty when the
  firmware doesn't report it.
- `pcie`: `downgraded_links` counts endpoints negotiating below their capability. `errors`: machine-
  check banks read directly from MSRs; `mce_uncorrected > 0` is a FAIL. `network.nicN` is `up`,
  `down` or `unknown` (firmware can't report). `partitions[].type` is detected from the first
  sectors (NTFS, BitLocker, LUKS, APFS, FAT, exFAT, ext4, empty). `storage.installed_os` is inferred
  from those. `selftest[].result` is `PASS`, `FAIL` or `ABORTED`. `clone.result` is `COMPLETE`,
  `COMPLETE_WITH_GAPS` (unreadable sectors zero-filled) or `FAILED`. `boot.action` appears only when
  a change was written.
- `partitions[].os` and `storage.installed_os` carry the OS version when readable (Windows from
  `\Windows\servicing\Version`, Linux from `/etc/os-release`).
- `gpt.disks` / `gpt.damaged` count GPT disks and damaged tables; `partition_table.gpt` is
  `intact`, `repaired_backup`, `rebuilt` or `unrecoverable`.
- `stress.core_spread_pct` is how far the slowest core is behind the fastest; over 30 % is a WARN.
  `stress.cpu_pct_of_reference` / `bench.mem_read_pct_of_reference` appear when `REFERENCE.CSV` matches.
- `display.refresh_hz` is the panel's native rate from EDID. `gpu.vram_tested_mb` is the framebuffer size tested.
- `capacity.result` is `GENUINE` or `COUNTERFEIT`; `real_bytes_estimate` is where stamps stopped coming back.
- `memtest.faulty_module` (on failure, when SMBIOS type 20 maps the address) is the slot locator and part number.
- `memtest.work_mb` is bytes read+written across all four passes; `tested_mb` is the RAM covered.
  `result` is `PARTIAL` when stopped by time limit or key. `first_bad_address` appears on failure.
- `rescue`: `partial` files were copied with zero-filled gaps; `skipped` are listed in the log.
- `keyboard`: `keys_registered` of `keys_testable` (modifier keys are not testable through firmware).
- `stress`: `peak_temp_c`/`tjmax_c` appear only when a sensor was readable. `throttled` is 1 if
  the CPU reported a thermal event or per-core throughput fell by more than 30 % during the run.
  `result` is `FAIL` if the CPU came within 3 °C of TjMax, `WARN` if throttled, else `PASS`.
- `wipes[].bytes` is the drive's total capacity. `certificate` is the file written for that drive.
- Numbers are unquoted integers; everything else is a string. There are no nulls or booleans;
  flags are `0`/`1`.

## Wipe certificate

```
Hardware Clinic - CERTIFICATE OF DATA ERASURE

Machine:         Dell Inc. Latitude 7490
Machine serial:  ABC1234
Drive:           NVMe, internal
Drive model:     SAMSUNG MZVLB512HAJQ
Drive serial:    S3TNNX0K123456
Date:            2026-09-10 00:12
Drive capacity:  512110190592 bytes (1000215216 sectors of 512 bytes)
Method:          NVMe Format NVM with cryptographic erase (NIST SP 800-88 'Purge')
Duration:        1 seconds
Verification:    66 sectors sampled across the drive, 0 non-zero
Write errors:    0
Result:          PASS - drive erased

-----BEGIN HARDWARE CLINIC SIGNATURE-----
algorithm: ed25519
public-key: <64 hex>
signature: <128 hex>
-----END HARDWARE CLINIC SIGNATURE-----
```

- `Method` is one of:
  - `NVMe Format NVM with cryptographic erase (NIST SP 800-88 'Purge')`
  - `NVMe Format NVM with user-data erase (NIST SP 800-88 'Purge')`
  - `ATA Enhanced Security Erase (NIST SP 800-88 'Purge')`
  - `ATA Security Erase Unit`
  - `Single-pass overwrite with zeros (NIST SP 800-88 'Clear')`
- `Verification` samples sector 0, the last sector, and 64 sectors evenly spaced between them, each
  of which must read as all zeros. With full verification it reads instead
  `FULL read-back of every sector (N bytes), all zero`. A drive with an unreadable sector after
  erasure fails verification: what cannot be read cannot be certified.
- `Hidden area` (SATA only): `none (HPA check passed)` or `N sectors (HPA) - NOT covered by
  overwrite` / `covered by firmware erase`, from READ NATIVE MAX ADDRESS EXT versus the
  user-addressable capacity.
- `Result` is `PASS - drive erased` only when there were no write errors and every sample was zero.
  Otherwise `FAIL - do not treat as erased`.
- After an overwrite, an advisory paragraph about SSD over-provisioning is appended before the
  signature block.
- `Machine` and `Machine serial` are filled in when System info ran before the wipe (always true in
  unattended mode and Quick check; in the interactive menu run **System info** first if you want
  them on the certificate — otherwise they read `(unknown)`).

## Report

```
Hardware Clinic report
Generated: 2026-09-10 00:12:34

==== System info ====
CPU:      ...
...
==== Drive health ====
...
-----BEGIN HARDWARE CLINIC SIGNATURE-----
...
```

Sections are headed `==== <menu item> ====` in the order they ran. Progress indicators, menu
chrome and the banner are excluded. The report is a transcript for humans; use the JSON for data.

## HTML report

Self-contained (inline CSS, no scripts, no external resources), so it opens anywhere and prints
cleanly (the transcript is hidden when printing). Structure: header with machine and serial, a
verdict banner when a Quick/Full check ran, one `<h2>` section per JSON section with the same data
as tables (badges for PASS/WARN/FAIL-style values), the full transcript in `<pre>`, and the
signature trailer after `</html>` so it verifies with `verify.py` like a text report.

## QR summary

`HC1|<machine serial>|<kind>|<subject>|<result>|<YYYY-MM-DD HH:MM>|<8-hex key fingerprint>|<128-hex signature>`

`kind` is `wipe` (subject = drive serial, result `ERASED`/`FAILED`) or `check` (subject `hardware`,
result `OK`/`WORN`/`FAULT`). Fields containing `|` or control characters are sanitised to `_`.
The Ed25519 signature is over the ASCII bytes of everything before the final `|`. Encoded as a
byte-mode QR, error-correction level L, drawn at 3–4 pixels per module on the framebuffer.

## Signatures

Algorithm: Ed25519 (RFC 8032), as implemented by TweetNaCl. Keys are 32-byte public keys; signatures
are 64 bytes. Hex encoding is lowercase.

**Inline trailer** (reports, certificates): the signed message is every byte of the file **before**
the `\n-----BEGIN HARDWARE CLINIC SIGNATURE-----` line (i.e. the trailer's leading newline is not part of the
message). The trailer is exactly:

```
\n-----BEGIN HARDWARE CLINIC SIGNATURE-----\nalgorithm: ed25519\npublic-key: <64 hex>\nsignature: <128 hex>\n-----END HARDWARE CLINIC SIGNATURE-----\n
```

**Detached** (`.JSON.SIG`): a single line `ed25519 <64 hex public key> <128 hex signature>\n`.
The signed message is the entire JSON file.

Verification in Python without the bundled script:
```python
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
Ed25519PublicKey.from_public_bytes(bytes.fromhex(pub)).verify(bytes.fromhex(sig), message)
```

## Upload (HTTP POST)

`POST <url>` with `Content-Type: application/json`, body = the RESULT JSON exactly as saved, and
headers `X-Clinic-Serial: <machine serial>` and `X-Clinic-Signature: ed25519 <pubkey hex> <signature hex>`
(the detached-signature line without its newline). Any 2xx is success. `tools/receive.py` is a
reference receiver.

## KEY.BIN

64 bytes: 32-byte Ed25519 seed followed by the 32-byte public key (TweetNaCl secret-key layout).
Generated by `make keys`. Must be in the root directory of the boot volume. If absent, files are
written unsigned and *About* / unattended-mode startup print `Signing key: none`.

## CLINIC.CFG

See the Fleet Guide §2. Parsing rules: leading whitespace ignored; key ends at `=` or whitespace;
value runs to end of line or `#`; trailing whitespace trimmed; unknown keys ignored; the first
occurrence of a key wins. Maximum 4 KB.

## Verdicts

**Drive (SMART)**

| Type | FAILING if | WORN if |
|---|---|---|
| NVMe | critical warning ≠ 0, or media errors > 0 | percentage used ≥ 90, or available spare below the drive's own threshold |
| SATA | pending sectors > 0, or uncorrectable > 0, or reallocated > 50 | reallocated > 0 |

**Quick check overall**

- `FAULT` if memory errors > 0, any drive FAILING, any unreadable sector, uncorrected machine-check errors, stress FAIL, display reported bad, or keyboard registered no keys.
- `WORN` otherwise if any drive is WORN, any drive has ≥ 3 slow zones, corrected machine-check errors, a degraded PCIe link, or stress WARN.
- Network down and encryption present are shown as WARN rows but do not change `overall`.
- `OK` otherwise.

Drives with no SMART data show as WARN on screen but do not affect `overall`.
