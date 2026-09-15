# Compatibility

Real machines Hardware Clinic has booted on, and what each one exposed. Hardware coverage is firmware
coverage: if a machine's UEFI doesn't offer a protocol — ATA pass-through, MP Services, an EDID — that
feature is unavailable on that machine, and that is exactly what this list records.

**Add yours:** [machine report](https://github.com/jmsmediagroup/hardware-clinic/issues/new?template=machine-report.yml)
— two minutes; the JSON carries hardware identifiers only.

> **Status for 1.0.0-rc8:** the rc8 build has passed the full QEMU/OVMF regression bench but has **not
> yet been run on a physical machine** — the row below was produced on rc7, and the "Save my files"
> wizard and both one-click stick makers are new in rc8 and real-hardware-untested. If you boot rc8 on
> anything, your report is the most useful thing in this project right now.

Legend: ✅ works · ⚠️ works after a setting change · ❌ not available on this machine · — not tested yet

## Laptops

| Machine | CPU / RAM / GPU | Version | Boot | Quick check | SMART | Memory test | Stress + temp | Fans | Display (EDID) | TPM | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **Acer Nitro 5 AN515-55** | i5-10300H (4c/8t), 16 GB, NVIDIA dGPU (PCIe x16 Gen3) | rc7 | ✅ (Secure Boot off) | ✅ | ⚠️ SSD hidden by **Intel RST / RAID** storage mode — set it to AHCI; the tool names the controller and prints the BIOS steps | ✅ 16 GB clean on 8 threads | ✅ 70 °C stable, 1 % core spread | ❌ no EC map for Acer yet | ✅ 144 Hz AUO panel | ✅ via ACPI `TPM2` table (firmware offered no protocol) | Identical correctable AER bit on every endpoint recognised as ASPM noise (rc7). Windows 11 22H2 detected off the drive. VRAM clean. All four peripherals detected. First real-hardware machine — it shaped rc6 and rc7. |

## Desktops

None reported yet — [be the first](https://github.com/jmsmediagroup/hardware-clinic/issues/new?template=machine-report.yml).
Desktop Super-I/O sensor chips (Nuvoton / Winbond / ITE) are implemented from the datasheets and the
Linux drivers but have not yet run on a physical board; a report from any desktop is worth a lot.

## Intel Macs

None reported yet. Apple Silicon (M1–M4) is **not supported**: those Macs refuse to boot non-Apple
systems from USB. Run it in UTM or QEMU there instead.

## Virtual machines

| Hypervisor | Firmware | Status | Notes |
|---|---|---|---|
| QEMU / OVMF (`q35` and `pc`) | EDK II | ✅ reference bench | Every build runs the regression suite here: NVMe and SATA SMART, memory test on 4 CPUs, NTFS / ext4 / APFS file rescue, GPT rebuild, wipe-all, signed HTTP(S) upload. No CPU temperature (TCG has no DTS) and no Super-I/O or EC sensors — nothing emulates them. |
| VMware, VirtualBox, UTM, Hyper-V | — | — | Untested. UEFI boot from the `.iso` should work; a report either way is useful. |

## Known machine-class limitations

- **Intel RST / RAID storage mode** (common on Acer, Dell and HP laptops): the SSD is invisible to every
  standard firmware interface, so SMART and drive self-tests are unavailable until the BIOS storage
  mode is switched to AHCI. Windows needs a safe-mode boot around that change; the tool prints the steps.
- **Laptop fans and temperatures** need a per-model embedded-controller map. Only ThinkPads are mapped
  so far. To add a model: run `ecdump` from the command shell when the machine is cool, run the Stress
  test, run `ecdump` again, and send both dumps with the model name.
- **ATA Security Erase** is frozen by most firmware at boot. The tool detects this and offers overwrite
  or (on NVMe) the controller's own Format / crypto-erase instead.
- **Secure Boot** must be off for this free build; it is unsigned. Signed builds are part of the
  commercial licence.
- **Battery health** beyond design data is not readable without an ACPI interpreter.
