# Hardware Clinic — Fleet Guide

*For IT departments, refurbishers, and asset-disposal teams processing many machines.*

The bench workflow in the User Guide needs a person at the keyboard. This guide covers the other
mode: a stick that runs a defined job by itself, names its output after the machine it ran on, and
signs everything so the results can be trusted later.

---

## 1. The unattended workflow

1. Prepare one stick (or a batch of identical sticks) with a `CLINIC.CFG` describing the job and a
   `KEY.BIN` signing key.
2. Walk the room: plug a stick into each machine, boot it, walk on. The job starts after a
   5-second countdown, runs with no input, saves its files, and shuts the machine down.
3. Collect the sticks. Each holds one `RESULT-<serial>.JSON` per machine it ran on, plus a report
   and any wipe certificates.
4. Copy the files to your asset system and verify the signatures with `tools/verify.py`.

Every unattended job also writes `REPORT-<serial>.HTML`, which is what you attach to the ticket.
Because output files are keyed by machine serial number, a single stick can be reused across the
whole fleet without files overwriting each other. Re-running on the same machine overwrites that
machine's previous result.

## 2. CLINIC.CFG reference

A plain text file in the root of the stick. `key = value`, one per line, `#` starts a comment.
Keys are case-sensitive; values are not quoted.

| Key | Values | Default | Meaning |
|---|---|---|---|
| `mode` | `menu` `quick` `full` `inventory` `wipe-all` | `menu` | The job. `menu` disables unattended mode. |
| `ram_seconds` | integer | `30` | RAM test duration for `quick`. `full` ignores this and tests everything once. |
| `stress_seconds` | integer | `120` | Stress test duration for `full`. |
| `soak_hours` / `soak_minutes` / `soak_surface` | integer / integer / `yes` `no` | `8` / — / `no` | For `mode = soak`; `soak_minutes` for short burn-ins (stress steps shrink to 30 s under 30 minutes). |
| `rescue_to` | `usb` `stick` | `usb` | For `mode = rescue`: copy to the largest FAT drive that is not this stick, or onto this stick (build it with `make IMG_MB=...`). |
| `wipe_method` | `auto` `firmware` `overwrite` `trim` | `auto` | `auto` uses the drive's firmware erase when available, else overwrites. `firmware` fails the drive rather than falling back — use when policy requires Purge. `trim` deallocates every block on NVMe drives (seconds; not a certified erase — for drives you are reusing internally). |
| `wipe_removable` | `no` `yes` | `no` | Whether `wipe-all` may touch removable drives. The Hardware Clinic stick is never touched regardless. |
| `wipe_verify` | `sample` `full` | `sample` | `full` reads back every sector after erasing and records that on the certificate. Doubles the time of an overwrite; adds a full read to a firmware erase. |
| `wipe_confirm` | exact phrase | — | Must be `I_UNDERSTAND_THIS_ERASES_EVERY_INTERNAL_DRIVE` or `wipe-all` refuses to run. |
| `upload` | URL | — | After saving, POST the RESULT JSON to this URL (wired Ethernet, DHCP). `http://` works as is; `https://` needs the server's CA certificate as `CA.DER` on the stick. Signature travels in the `X-Clinic-Signature` header; serial in `X-Clinic-Serial`. Results are always saved to the stick as well. |
| `ticket` / `customer` | text | — | Job number and customer name for the session; printed on everything. |
| `issuer` | text | — | Organisation or technician name printed on certificates, reports and HTML ("Issued by"). `ISSUER.TXT` on the stick works too. |
| `update_url` | URL | — | GET a text file whose first line is the latest version; the job reports whether this stick is current. Point it at a file on your receiver's web server. |
| `after` | `menu` `shutdown` `reboot` | `menu` | What to do when the job finishes. |

### Modes

- **`quick`** — system info, PCI/USB inventory, SMART, RAM test for `ram_seconds`, memory and
  disk benchmarks, 20-second stress. No display or keyboard test (those need a person). Verdict.
- **`full`** — the intake check for used hardware: everything in `quick`, but the RAM test covers all
  free memory once on every core, **every sector of every drive is read**, every drive runs its
  **short self-test**, and the stress test runs for `stress_seconds`. Budget 10 minutes plus the time to read the drives (a 1 TB HDD is ~2 hours).
- **`inventory`** — system info, RAM modules, PCI/USB inventory, PCIe links, error log, network,
  panel EDID, Secure Boot/TPM, partitions and installed OS, SMART. No RAM test. Use for audits.
- **`soak`** — memory test + 5-minute stress (+ surface read with `soak_surface = yes`) looping for
  `soak_hours` (default 8). Overnight burn-in for intake or for the intermittent-crash machine.
- **`savefiles`** — the plain-language wizard, unattended: surveys every drive's user folders and
  copies them to the first USB drive with enough room (or this stick). For a dedicated rescue
  stick handed to a customer: `mode = savefiles`, `after = shutdown`.
- **`rescue`** — every user's standard folders from every NTFS and ext4 volume, into
  `\RESCUE-<timestamp>\VOLn\<user>\...` on the destination. The go-to before a wipe-all when a
  department wants its files back, or for a repair counter that takes in a "won't boot" machine.
- **`wipe-all`** — system info and SMART (so the certificate and JSON carry drive identities), then
  erases every eligible drive, then saves results.

### Examples

Asset audit, no changes to any machine:
```
mode = inventory
after = shutdown
```

Intake check for used laptops (thorough):
```
mode = full
stress_seconds = 300
after = shutdown
```

Decommissioning, must use firmware erase (Purge) or fail, every sector verified:
```
mode = wipe-all
wipe_method = firmware
wipe_verify = full
wipe_removable = no
wipe_confirm = I_UNDERSTAND_THIS_ERASES_EVERY_INTERNAL_DRIVE
after = shutdown
```

Save the users' files, then wipe (two sticks, or two boots of one stick with different configs):
```
mode = rescue
rescue_to = usb
after = shutdown
```

Refurbishment (erase, then leave the machine at the menu for the tech to run a display test):
```
mode = wipe-all
wipe_method = auto
wipe_confirm = I_UNDERSTAND_THIS_ERASES_EVERY_INTERNAL_DRIVE
after = menu
```

### Safety behaviour in wipe-all

- Never selects the drive Hardware Clinic booted from.
- Skips removable drives unless `wipe_removable = yes`.
- Skips read-only media.
- Runs with no confirmation prompt — the confirmation is the `wipe_confirm` line in the file. Treat
  a stick carrying a `wipe-all` config like a loaded tool: label it, and don't leave it in a drawer
  with the inventory sticks.
- The 5-second countdown at boot accepts any key and drops to the menu, so a tech who plugs the
  wrong stick into the wrong machine has a window to stop it.

## 2a. Network upload — no stick collection

Add `upload = http://<server>:<port>/clinic` to the job and every machine POSTs its signed JSON
when it finishes. Run the bundled receiver anywhere on the LAN:

```
python3 tools/receive.py --port 8000 --dir ./received --pubkey keys/PUBKEY.HEX
```
It stores `<serial>-<timestamp>.json` and `.sig` per machine and prints one line per arrival with
`signature=VALID` (or INVALID / other-key). Feed the directory to the `jq` recipes below.

Requirements and limits: a **wired** connection and a DHCP server (firmware Wi-Fi is not a thing).
For **HTTPS**, export your CA certificate in DER form as `CA.DER` on the stick; the tool installs
it into the firmware's trust store before uploading, and the server certificate must carry the
host (IP or name used in the URL) in its subject alternative names. Run the receiver with
`--tls-cert srv.pem --tls-key srv.key`. Plain HTTP is fine on a trusted LAN — the payload is
signed either way. The firmware's HTTP client is the same one it uses for
network boot, so it works on any machine that can HTTP-boot. If the upload fails, the job still
completes and the files are still on the stick.

## 3. Signing and verification

### Why

A wipe certificate or health report is only useful to an auditor, customer, or insurer if they can
tell it came from the tool and wasn't edited in a text editor afterwards. Hardware Clinic signs its output with
an Ed25519 key that lives on the stick.

### Set up a key

On the build machine:
```
make keys
```
This creates `keys/KEY.BIN` (the secret; 64 bytes) and `keys/PUBKEY.HEX` (the public key; publish
this). The next `make` embeds `KEY.BIN` in the image. You can also copy `KEY.BIN` onto an existing
stick's root directory.

Recommended practice:
- **One key per stick or per technician**, so a certificate is attributable to a specific stick.
  Record which public key belongs to which stick.
- Publish the public keys somewhere your customers can check — a page on your website, or the
  footer of your quotation template.
- Keep `KEY.BIN` off shared drives. Anyone holding it can produce certificates that verify.
- If a stick is lost, retire its key: stop accepting its public key and reissue.

### Verify a file

On any computer with Python 3 and `pip install cryptography`:
```
python3 tools/verify.py WIPE-S4E9NX0N123456.TXT --pubkey 677f1662a86c...
python3 tools/verify.py RESULT-SN12345.JSON  --pubkey 677f1662a86c...
```
Output is one of:

- `VALID (key 677f1662a86c1741...)` — untouched, produced by that key.
- `INVALID - file was modified or forged` — do not trust it.
- `SIGNED BY A DIFFERENT KEY` — signed, but not by the key you expected.
- `NOT SIGNED` — the stick had no `KEY.BIN`.

**QR summaries.** Every wipe and every Quick check shows a QR code carrying a signed one-line
summary: `HC1|machine serial|kind|subject|result|date|key fingerprint|signature`. A phone photo of
the screen is enough: `python3 tools/verify.py --qr "<decoded text>" --pubkey <hex>` reports VALID
or INVALID. Any QR reader app decodes it; the text is plain ASCII.

Omit `--pubkey` to check integrity only (any key accepted). Always pass it when the question is
"did *our* stick produce this."

Text files (reports and certificates) carry the signature inline at the end; JSON files have a
detached `.SIG` file beside them so the JSON stays valid. The formats are documented in
*FILE-FORMATS.md* if you want to verify in another language.

### What a signature does and does not prove

It proves the file's bytes are exactly what a stick holding that key wrote. It does **not** prove
the wipe was appropriate, that the correct machine was wiped, or that the stick's clock was right.
Those are process controls: label sticks, log which stick went to which asset, and check the
`generated` timestamp against your job log.

## 4. Working with the JSON

`RESULT-<serial>.JSON` is designed to be imported without parsing text. Top-level keys are stable:
`system`, `hardware`, `drives`, `memtest`, `display`, `keyboard`, `wipes`, `verdict`. Sections
that didn't run are absent rather than empty. Full field list in *FILE-FORMATS.md*.

Quick ways to use it:

```
# every machine with a failing or worn drive (SMART or surface read)
jq -r 'select((.drives[]?.verdict != "HEALTHY") or (.surface[]?.bad_sectors > 0)) | .system.serial' RESULT-*.JSON

# machines with BitLocker/LUKS volumes (recovery keys needed before disposal)
jq -r 'select(.storage.encrypted_volumes > 0) | .system.serial' RESULT-*.JSON

# machines with a degraded PCIe link or logged hardware errors
jq -r 'select(.pcie.downgraded_links > 0 or .errors.mce_logged > 0) | .system.serial' RESULT-*.JSON

# machines that overheated or throttled under load
jq -r 'select(.stress.result != "PASS") | [.system.serial, .stress.peak_temp_c, .stress.result] | @csv' RESULT-*.JSON

# asset spreadsheet: serial, model, RAM, cores, overall verdict
jq -r '[.system.serial, .system.model, .system.ram_mb, .system.cores, .verdict.overall] | @csv' RESULT-*.JSON

# wipe register
jq -r '.wipes[]? | [.serial, .model, .bytes, .method, .result, .certificate] | @csv' RESULT-*.JSON
```

## 4a. Building a compatibility list

`tools/compat.py received/` turns a folder of RESULT files into a Markdown (or `--csv`) table:
one row per manufacturer/model/firmware with what worked — SMART, self-test, CPU temperature,
PCIe, network, EDID, TPM, Secure Boot, firmware erase. Publish it; ask users to send their JSON.

## 5. Rollout checklist

- [ ] Secure Boot disabled on the target fleet, or a documented exception process. (Signed boot is
      on the roadmap; until then Hardware Clinic won't start on Secure-Boot-enforced machines.)
- [ ] Tested on one machine of each model in the fleet — firmware behaviour varies. Check in
      particular whether **Drive health** shows SMART data (some firmwares don't expose the pass-through
      protocols) and whether SATA drives report *frozen*.
- [ ] Sticks labelled by job type. A `wipe-all` stick must not look like an `inventory` stick.
- [ ] Public keys recorded against stick labels.
- [ ] RTC on target machines is roughly correct, or accept that report timestamps may be off.
- [ ] A place to put the JSON files and the `jq` or spreadsheet import tested.

## 6. What this is not (yet)

Hardware Clinic erasure is not independently certified (ADISA, Common Criteria). Its methods map to NIST SP
800-88 *Clear* (overwrite) and *Purge* (firmware erase), and the certificate states which was used,
but if your disposal policy requires a certified product, Hardware Clinic can be the first pass and not the
paperwork. Certification is on the roadmap once the hardware test lab exists.
