# Tools

## Making a stick

The stick makers are **downloads on the [Releases page](https://github.com/jmsmediagroup/hardware-clinic/releases/latest)**,
not files in this folder:

| You're on | Download | What it does |
|---|---|---|
| Windows | `Make-Hardware-Clinic-Stick.exe` | Self-contained — the disk image is built in. Lists USB sticks only, asks you to confirm, writes the stick. Needs administrator permission; SmartScreen may warn because it is new and unsigned (*More info → Run anyway*). |
| macOS | `Make-Hardware-Clinic-Stick.command` **and** `hardware-clinic-<version>.img` | Put both in the same folder and double-click the `.command`. Lists USB sticks only, confirms twice, asks for your password. |
| Linux | `hardware-clinic-<version>.img` | Write it with `flash.sh` below. |

The Windows maker isn't kept here because it is a 67 MB program with the whole image inside; storing it in
git would add that much to every clone with each release. Check any download against `SHA256SUMS` on the
same release page.

## In this folder

| File | Use |
|---|---|
| `Make-Hardware-Clinic-Stick.command` | Source of the macOS stick maker. To use it, download the release copy next to the `.img`. |
| `flash.sh` | Command-line stick writer for macOS and Linux: `tools/flash.sh hardware-clinic-<version>.img`. Lists removable drives only and makes you type the device name twice before erasing it. |
| `verify.py` | Checks a signed report, certificate or JSON: `python3 tools/verify.py RESULT-<serial>.JSON --pubkey <hex>`, or a QR summary: `python3 tools/verify.py --qr "HC1\|…" --pubkey <hex>`. Needs `pip install cryptography`. Output from the free download is unsigned until you install your own key. |
