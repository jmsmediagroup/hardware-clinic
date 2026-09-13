# Security policy

Hardware Clinic erases drives and signs certificates that people rely on. Three classes of bug are
critical, and I want to hear about them privately before anyone else does:

1. **A wipe that reports PASS while data is still readable**, or any way to obtain a certificate
   without the erase having happened.
2. **A write to a drive the user did not select** — including the Hardware Clinic stick itself, which
   the tool is designed never to touch.
3. **A forged or altered report, certificate or QR that `tools/verify.py` accepts**, or any weakness
   in how outputs are signed.

## How to report

Email **johan@struijk.it** with `SECURITY` in the subject. Include the machine, the Hardware Clinic
version (top-left of the screen), what you did, and the `REPORT-<serial>.TXT` / `RESULT-<serial>.JSON`
files from the stick if they are relevant. You will get an acknowledgement within 72 hours, a fix as
fast as the problem deserves, and credit in the changelog if you want it.

Please do not open a public issue for anything in the three classes above. Everything else — wrong
readings, crashes, a screen that looks broken — belongs in a normal
[bug report](https://github.com/jmsmediagroup/hardware-clinic/issues/new?template=bug-report.yml).

## Scope

In scope: the shipped `hardware-clinic-<version>.img` / `.iso`, `BOOTX64.EFI`, `tools/verify.py`,
`tools/flash.sh`, and the unattended mode (`CLINIC.CFG`, signed upload).

Out of scope: firmware bugs (report those to the machine's manufacturer), devices a firmware hides
(Intel RST / RAID mode), and a signing key that was copied off a stick — key custody is the operator's.

## What a signature proves — and what it doesn't

A valid signature proves that a file was produced by a stick holding a particular private key and has
not been altered since. It does not prove that the key was kept safe, that the drive was physically
destroyed, or that the person holding the stick was who they said they were. Treat certificates as
strong evidence inside a process you control, not as a substitute for one. Details on erase levels and
verification are in [FLEET-GUIDE.md](FLEET-GUIDE.md) and [FILE-FORMATS.md](FILE-FORMATS.md).

## Supported versions

Only the latest release receives fixes. Check `SHA256SUMS` on the release page before flashing.
