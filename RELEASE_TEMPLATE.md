# @@RELEASE_CHANNEL@@ Release

### @@RELEASE_NAME@@

### Testing Platform
Built by GitHub Actions on `ubuntu-latest`. This automated workflow does not boot the ISO or test physical hardware.

### Usability Status
@@RELEASE_STATUS@@

### Release Assets
Scheduled nightly releases and the Monday weekly developer release include the bootable ISO and signed arkup `.aup` update package or packages, checksums, and the verification public key. Manually triggered releases include the ISO.
Every ISO release includes `arkanaOS-update-client.txt`. Run All releases built from the default branch also include `arkanaOS-update-client-system-update.txt`, which binds scheduled updates to a verified base build.
Each update package filename includes `from-build-N`; use the package whose base build matches the build installed on your system. After applying it, choose the next package using your new build number. Nightly packages are based on the latest scheduled release. Monday's weekly release includes a package from the previous weekly build and, when those builds differ, a second package from Sunday's nightly build. This keeps both update paths available to weekly and nightly installations.
Update-base ISOs are downloaded from persistent GitHub Release assets and checked against GitHub's SHA-256 digest and the source workflow provenance. They do not depend on temporary Actions artifact retention.

Before applying the first scheduled update, download the verification key from the official arkanaOS release and trust it once on the installed system:

```sh
sudo arkup trust ./arkanaOS-update-signing.pub
sudo arkup apply ./path/to/update.aup
```

### Screenshots
Not captured by the automated workflow.

# GitHub Generated release notes
