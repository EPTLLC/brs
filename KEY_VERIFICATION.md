# 🔐 BRS Release Verification
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

**How to verify the authenticity and integrity of Brabus Recon Suite (BRS) releases**

---

### ✅ 1. Download & Import the Public Key

```bash
# Download BRS-specific signing key and metadata
curl -O https://www.easypro.tech/keys/brs/brs-signing-key.asc
curl -O https://www.easypro.tech/keys/brs/RELEASE_METADATA.txt
curl -O https://www.easypro.tech/keys/brs/brs-trust.txt

# Verify key fingerprint from metadata
cat RELEASE_METADATA.txt | grep "Key Fingerprint"

# Import the key
gpg --import brs-signing-key.asc
```

---

### 📋 1.1. Additional Verification Files

BRS provides additional verification files for enhanced security:

```bash
# Download additional metadata
curl -O https://www.easypro.tech/keys/brs/RELEASE_METADATA.txt
curl -O https://www.easypro.tech/keys/brs/brs-trust.txt

# View release metadata
cat RELEASE_METADATA.txt

# View trust information
cat brs-trust.txt
```

---

### 🔎 2. Verify the Key Fingerprint

```bash
gpg --fingerprint noreply@easypro.tech
```

Expected output:

```
Key fingerprint = 24B2 A5CC 6605 58C2 7D3D 7B63 FECE 5344 ED14 60A7
```

✅ If the fingerprint **matches exactly**, you can trust the key.

---

### 📆 3. Verify the Release Files

#### For `.tar.gz`:

```bash
gpg --verify brs-v1.0.tar.gz.asc brs-v1.0.tar.gz
```

#### For `.zip`:

```bash
gpg --verify brs-v1.0.zip.asc brs-v1.0.zip
```

#### Check SHA integrity:

```bash
sha256sum -c brs-v1.0.sha256
sha512sum -c brs-v1.0.sha512
```

---

## 🔑 BRS Key Details

| Field                | Value                                                              |
| -------------------- | ------------------------------------------------------------------ |
| **Key ID**           | `9E8DB39DCFFF51D8`                                                 |
| **Fingerprint**      | `7A69B983BB4F308184FD21229E8DB39DCFFF51D8`                         |
| **Key SHA256**       | `7e97952082610f28a4ce89d11f8f97a414ce80bf3146b5364f494805f6e23c73` |
| **Key Type**         | RSA 4096-bit                                                       |
| **Email (GPG only)** | `mail@easypro.tech`                                                |
| **Website**          | [https://easypro.tech/keys/brs/](https://easypro.tech/keys/brs/)   |

---

## ⚠️ Security Advice

* ✅ Always verify the **GPG signature**
* ✅ Always confirm the **key fingerprint**
* ❌ Never run BRS without verifying the archive
* 🔐 Only download keys and releases from official source

> **Tampered or fake releases can compromise your system. Always verify.**

---

## 📞 Support

For licensing or verification questions:

* Telegram: [@easyprotech](https://t.me/easyprotech)
* Website: [www.easypro.tech](https://www.easypro.tech)
* BRS Keys: [www.easypro.tech/keys/brs/](https://www.easypro.tech/keys/brs/)

---

## ✅ You are safe if:

* `gpg --verify` = OK
* `sha256sum -c` = OK  
* Fingerprint matches: `24B2A5CC660558C27D3D7B63FECE5344ED1460A7`
* Key SHA256 matches: `8e8cba1ab634e752eaae0708c13de47ef27b266aa39bd6cdf5e6158ac489203d`
