# BRS Release Files

## v2.0 Release Files (Latest)
- `brs-v2.0.tar.gz` / `brs-v2.0.zip` - Release archives
- `brs-v2.0.sha256` / `brs-v2.0.sha512` - Checksums
- `brs-v2.0.tar.gz.asc` / `brs-v2.0.zip.asc` - GPG signatures (ASCII)
- `brs-v2.0.tar.gz.sig` / `brs-v2.0.zip.sig` - GPG signatures (binary)

## v1.0 Release Files (Legacy)
- `brs-v1.0.tar.gz` / `brs-v1.0.zip` - Release archives
- `brs-v1.0.sha256` / `brs-v1.0.sha512` - Checksums
- `brs-v1.0.tar.gz.asc` / `brs-v1.0.zip.asc` - GPG signatures (ASCII)
- `brs-v1.0.tar.gz.sig` / `brs-v1.0.zip.sig` - GPG signatures (binary)

## Verification Commands

### For v2.0:
```bash
# Verify GPG signatures
gpg --verify brs-v2.0.tar.gz.asc brs-v2.0.tar.gz
gpg --verify brs-v2.0.zip.asc brs-v2.0.zip

# Verify checksums
sha256sum -c brs-v2.0.sha256
sha512sum -c brs-v2.0.sha512
```

### For v1.0:
```bash
# Verify GPG signatures
gpg --verify brs-v1.0.tar.gz.asc brs-v1.0.tar.gz
gpg --verify brs-v1.0.zip.asc brs-v1.0.zip

# Verify checksums
sha256sum -c brs-v1.0.sha256
sha512sum -c brs-v1.0.sha512
```

## GPG Key Information
- Key ID: FECE5344ED1460A7
- Fingerprint: 24B2A5CC660558C27D3D7B63FECE5344ED1460A7
- Download: ../brs-signing-key.asc 