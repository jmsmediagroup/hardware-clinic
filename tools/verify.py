#!/usr/bin/env python3
"""Verify a Hardware Clinic report/certificate (inline trailer) or JSON (+ .SIG file).
Usage: verify.py FILE [--pubkey HEX]     (pip install cryptography)"""
import sys, re, pathlib
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
from cryptography.exceptions import InvalidSignature

# --- QR summary verification: verify.py --qr "HC1|serial|kind|subject|result|date|keyfp|sig" [--pubkey HEX]
if len(sys.argv) > 2 and sys.argv[1] == "--qr":
    line = sys.argv[2].strip(); expected = sys.argv[4].lower() if len(sys.argv) > 4 and sys.argv[3] == "--pubkey" else None
    parts = line.split("|")
    if len(parts) < 8 or parts[0] != "HC1": print("not a Hardware Clinic summary"); sys.exit(1)
    msg, sig_hex = "|".join(parts[:7]).encode(), parts[7]
    serial, kind, subject, result, date, fp = parts[1:7]
    if not expected: print(f"{kind} of {subject} on machine {serial}: {result} at {date} (key fingerprint {fp}); pass --pubkey to verify the signature"); sys.exit(0)
    if not expected.startswith(fp): print(f"SIGNED BY A DIFFERENT KEY (fingerprint {fp})"); sys.exit(1)
    try:
        Ed25519PublicKey.from_public_bytes(bytes.fromhex(expected)).verify(bytes.fromhex(sig_hex), msg)
        print(f"VALID: {kind} of {subject} on machine {serial}: {result} at {date}")
    except InvalidSignature: print("INVALID - summary was altered or forged"); sys.exit(1)

def check(msg, pub_hex, sig_hex, expected):
    if expected and pub_hex != expected: return f"SIGNED BY A DIFFERENT KEY ({pub_hex[:16]}...)"
    try: Ed25519PublicKey.from_public_bytes(bytes.fromhex(pub_hex)).verify(bytes.fromhex(sig_hex), msg); return f"VALID (key {pub_hex[:16]}...)"
    except InvalidSignature: return "INVALID - file was modified or forged"

path = pathlib.Path(sys.argv[1]); expected = sys.argv[3].lower() if len(sys.argv) > 3 and sys.argv[2] == "--pubkey" else None
data = path.read_bytes()
m = re.search(rb"\n-----BEGIN HARDWARE CLINIC SIGNATURE-----\nalgorithm: ed25519\npublic-key: ([0-9a-f]{64})\nsignature: ([0-9a-f]{128})\n-----END HARDWARE CLINIC SIGNATURE-----\n", data)
if m:
    print(path.name + ":", check(data[:m.start()], m.group(1).decode(), m.group(2).decode(), expected)); sys.exit()
# detached signature: RESULT-X.JSON.SIG, RESULT-X_JSON.SIG (renamed in transit), RESULT-X.SIG, any case
_cands = [path.with_name(path.name + ".SIG"), path.with_name(path.name + ".sig"), path.with_name(path.stem + "_" + path.suffix[1:] + ".SIG"),
          path.with_name(path.stem + "_" + path.suffix[1:] + ".sig"), path.with_suffix(".SIG"), path.with_suffix(".sig")]
sig = next((c for c in _cands if c.exists()), _cands[0])
if sig.exists():
    _, pub_hex, sig_hex = sig.read_text().split()
    print(path.name + ":", check(data, pub_hex, sig_hex, expected)); sys.exit()
print(path.name + ": NOT SIGNED")

