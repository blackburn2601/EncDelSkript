<div align="center">

# securedel

**A small macOS shell script that optionally encrypts a file and then deletes it with `srm`.**

![Bash](https://img.shields.io/badge/Bash-4eaa25?logo=gnubash&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)
![OpenSSL](https://img.shields.io/badge/OpenSSL-AES--256-721412)

</div>

---

## About

Deleting a file normally leaves its contents on disk until something overwrites them. `securedel.sh` wraps
the usual steps into one command: check the target, warn if the file system cannot guarantee a secure
overwrite, optionally keep an AES-256 encrypted copy, then delete with `srm` (secure remove).

The script is German-language (prompts and messages).

## What it does

```
./securedel.sh <path>
```

1. **Validates the argument.** Exits with an error if no path is given or the path does not exist.
2. **Detects the file system** of the volume with `diskutil info` and **warns on APFS**, where overwriting
   in place is not guaranteed to touch the original blocks (copy-on-write, snapshots, SSD wear levelling).
3. **Asks whether to encrypt first.** On `y`, writes `<path>.enc` with
   `openssl enc -aes-256-cbc -salt`; OpenSSL prompts for the password.
4. **Deletes** with `srm` if it is installed. If not, it says so and falls back to a plain `rm -f`.

## Usage

```bash
chmod +x securedel.sh
./securedel.sh ~/Documents/old-tax-return.pdf
```

To restore an encrypted copy:

```bash
openssl enc -d -aes-256-cbc -in old-tax-return.pdf.enc -out old-tax-return.pdf
```

## Read this before relying on it

- **It is built for macOS.** It calls `diskutil`, which only exists there.
- **`srm` is not part of current macOS.** Apple removed it in macOS 10.12. Without it, the script
  deletes with a plain `rm -f`, which is **not** secure. It says so, but the final message
  ("Datei wurde gelöscht") appears either way. Install a compatible `srm` if you need real overwriting.
- **On SSDs and APFS, overwriting does not guarantee that the data is gone.** Full-disk encryption
  (FileVault) is the dependable answer; this script is a convenience, not a guarantee.
- **The final message does not check the result.** It is printed unconditionally and does not inspect the
  exit status of `srm` or `rm`.
- **Files only.** The header comment mentions folders, but the script passes no recursive flag.
- Encryption uses `aes-256-cbc` with OpenSSL's default key derivation; newer OpenSSL versions recommend
  `-pbkdf2` for stronger password hashing.

## Verified

I ran the argument checks (no argument, missing file) and the delete path without `srm` on a Linux machine.
Those behave as described above. The `diskutil` and `srm` parts only exist on macOS and were not run.

## License

No license has been chosen yet, so all rights are reserved.
