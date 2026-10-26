# arkana-update-builder

`arkana-builder` creates the complete bootable ISO. `arkana-update-builder`
creates a signed `.aup` delta for systems that already have arkanaOS installed.
The update package contains only changed files and explicit file deletions.

## Build an update

Use a root tree from the installed base release and the root tree for the new
release. Both trees must include matching release metadata under `/etc`; the
target build number must be greater than the base build number. A nightly base
can advance to an alpha release because the build number is the monotonic update
sequence.

```sh
./build-update.sh \
  --base-root /path/to/base-root \
  --target-root /path/to/output/iso-root \
  --signing-key /offline/keys/release.key \
  --public-key /offline/keys/release.pub \
  --output-dir /path/to/update-output
```

The builder validates `/etc/os-release`, the arkanaOS release identity, and the
build sequence before comparing file contents and modes. It excludes mutable
runtime and package-manager state, including `/etc/ld.so.cache`, `/etc/localtime`,
`/etc/resolv.conf`, `/home`, `/root`, `/srv`, `/usr/local`, and `/var/lib`. It
refuses file/directory transitions and directory permission changes that the
current `.aup` format cannot represent. The output is verified with the supplied
public key and includes a SHA-256 sidecar.

The pack marks release identity files (`/etc/os-release`, `/etc/issue`, and the
`/etc/arkana-*` release metadata) as system-managed so an upgrade advances the
reported version. Other `/etc` files continue to use arkup's local-configuration
preservation and `.arkup-new` behavior.

## Signing and resource use

Create the release keypair with `arkup keygen` once. Keep the private key
offline, outside Git, and backed up securely. The container mounts both trees
read-only, mounts the keys read-only, disables network access at runtime, and
uses bounded memory and one CPU for package creation. Docker needs network
access only while building the image to fetch the pinned arkup source and Rust
dependencies. The image defaults to the reviewed arkup commit
`f9b433bafacd00d7f1a29541e81b303b999c4d65`; set `ARKUP_GIT_REF` only when deliberately testing another reviewed
commit. Rootless Podman runs use `keep-id` so the unprivileged container can
read private input trees and signing keys owned by the invoking account.

Run the pure Python checks with:

```sh
python3 -m unittest discover -s tests -p 'test_update_builder.py' -v
```
