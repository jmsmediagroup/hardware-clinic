# Reporting machines and bugs

Hardware Clinic is proprietary freeware and the source is not published, so there are no pull
requests. What genuinely helps — and what the tool is built to collect — is real-hardware feedback.
Everything in the shipped image is verified in QEMU/OVMF on every build; firmware quirks only show
up on real machines.

## Report a machine (5 minutes)

1. Boot the stick, run **Quick check** and **Sensors**, then **Save all** (`s`).
2. Open a [machine report](https://github.com/jmsmediagroup/hardware-clinic/issues/new?template=machine-report.yml)
   and drag `RESULT-<serial>.JSON` from the stick's root into it. It contains hardware identifiers
   only, no personal data; delete the serial number if you prefer.
3. Say what didn't match reality: a drive with no SMART, a fan that spins but reads 0, a wrong verdict.

Reports become rows in [COMPATIBILITY.md](COMPATIBILITY.md) and drive the fixes — rc6 and rc7 both
came straight out of the first one.

## Add a laptop's fan / temperature map

Sensor maps are keyed on the SMBIOS model string and can only be built from a real machine. Run
`ecdump` from the command shell when the machine is cool, run **Stress test**, run `ecdump` again,
and send both dumps plus the exact model. The bytes that changed with heat are the temperature
offsets; the ones that changed with fan noise are the fan tachometer. They go into the next build.

## Bugs

Crashes, hangs, wrong readings, broken screens: [bug report](https://github.com/jmsmediagroup/hardware-clinic/issues/new?template=bug-report.yml).
Questions ("will it work on my X?"): [Discussions](https://github.com/jmsmediagroup/hardware-clinic/discussions).

## Security problems

A wrong PASS on a wipe, a write to a drive that wasn't selected, or a forged certificate is a critical
bug. Report it privately — see [SECURITY.md](SECURITY.md).

Contact: johan@struijk.it
