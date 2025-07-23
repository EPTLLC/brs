# 🔐 BRS Release Verification

**How to verify the authenticity and integrity of Brabus Recon Suite (BRS) releases**

---

### ✅ 1. Download & Import the Public Key

```bash
# Download BRS-specific signing key and metadata
curl -O https://www.easypro.tech/keys/brs/brs-signing-key-v2.0.asc
curl -O https://www.easypro.tech/keys/brs/RELEASE_METADATA.txt
curl -O https://www.easypro.tech/keys/brs/brs-trust-v2.0.txt

# Verify key fingerprint from metadata
cat RELEASE_METADATA.txt | grep "Key Fingerprint"

# Import the key
gpg --import brs-signing-key-v2.0.asc
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
gpg --fingerprint mail@easypro.tech
```

Expected output:

```
Key fingerprint = 7A69 B983 BB4F 3081 84FD 2122 9E8D B39D CFFF 51D8
```

✅ If the fingerprint **matches exactly**, you can trust the key.

---

### 📆 3. Verify the Release Files

#### For `.tar.gz`:

```bash
gpg --verify brs-v2.0.tar.gz.asc brs-v2.0.tar.gz
```

#### For `.zip`:

```bash
gpg --verify brs-v2.0.zip.asc brs-v2.0.zip
```

#### Check SHA integrity:

```bash
sha256sum -c brs-v2.0.sha256
sha512sum -c brs-v2.0.sha512
```

---

## 🔑 BRS Key Details

| Field                | Value                                                              |
| -------------------- | ------------------------------------------------------------------ |
| **Key ID**           | `9E8DB39DCFFF51D8`                                                 |
| **Fingerprint**      | `7A69B983BB4F308184FD21229E8DB39DCFFF51D8`                         |
| **Key SHA256**       | `7e97952082610f28a4ce89d11f8f97a414ce80bf3146b5364f494805f6e23c73` |
| **Key Type**         | RSA 4096-bit                                                       |
| **Email (GPG only)** | `mail@easypro.tech`                                               |
| **Website**          | [https://www.easypro.tech/keys/brs/](https://www.easypro.tech/keys/brs/)   |

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

* Telegram: [@easyprotechaifactory](https://t.me/easyprotechaifactory)
* Website: [www.easypro.tech](https://www.easypro.tech)
* BRS Keys: [www.easypro.tech/keys/brs/](https://www.easypro.tech/keys/brs/)

---

## ✅ You are safe if:

* `gpg --verify` = OK
* `sha256sum -c` = OK  
* Fingerprint matches: `7A69B983BB4F308184FD21229E8DB39DCFFF51D8`
* Key SHA256 matches: `7e97952082610f28a4ce89d11f8f97a414ce80bf3146b5364f494805f6e23c73`
