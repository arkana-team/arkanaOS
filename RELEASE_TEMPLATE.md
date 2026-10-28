# @@RELEASE_CHANNEL@@ Release

### @@RELEASE_NAME@@

### Testing Platform
Built by GitHub Actions on `ubuntu-latest`. This automated workflow does not boot the ISO or test physical hardware.

### Usability Status
@@RELEASE_STATUS@@

### Release Assets
Scheduled nightly releases include the bootable ISO. The Monday weekly developer release also includes a signed arkup `.aup` update package, checksum, and verification public key. Manually triggered releases include the ISO.
Every ISO release includes `arkanaOS-update-client.txt`. Run All releases built from the default branch also include `arkanaOS-update-client-system-update.txt`, which binds weekly updates to a verified base build.

Before applying the first weekly update, download the verification key from the official arkanaOS release and trust it once on the installed system:

```sh
sudo arkup trust ./arkanaOS-update-signing.pub
sudo arkup apply ./path/to/update.aup
```

### Screenshots
Not captured by the automated workflow.

# GitHub Generated release notes
