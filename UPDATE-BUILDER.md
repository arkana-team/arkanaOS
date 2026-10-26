# arkana-update-builder

`arkana-builder` can create the complete bootable ISO, a signed `.aup` delta,
or both in one run. The update package contains changed files and explicit file
deletions for systems that already have arkanaOS installed.

## Choose a build

```sh
./build.sh --iso       # the default; build the bootable ISO
./build.sh --update --base-root old-root --target-root new-root \
  --signing-key release.key --public-key release.pub
./build.sh --both --base-root old-root \
  --signing-key release.key --public-key release.pub
```

`--both` builds the ISO first and uses its validated `output/iso-root` as the
update target. The base tree and key arguments are required before the ISO
build starts. `--update` forwards its arguments to `build-update.sh`.

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

Create the release keypair with `arkup keygen` once. For local package builds,
keep the private key offline, outside Git, and backed up securely. The
container mounts both trees read-only, mounts the keys read-only, disables
network access at runtime, and uses bounded memory and one CPU for package
creation. Docker needs network access only while building the image to fetch
the pinned arkup source and Rust dependencies. The image defaults to the reviewed arkup commit
`f9b433bafacd00d7f1a29541e81b303b999c4d65`; set `ARKUP_GIT_REF` only when deliberately testing another reviewed
commit. Rootless Podman runs use `keep-id` so the unprivileged container can
read private input trees and signing keys owned by the invoking account.

## Weekly developer releases

The scheduled GitHub Actions run starts every Monday at 03:00 UTC and uses the
same staged ISO pipeline and release-note template as manual nightly builds.
It builds an update delta from the latest published arkanaOS ISO, then attaches
the ISO, `.aup`, checksum, and public verification key to the release. The
update is based on that prior release; users on older builds may need to
install intervening updates first. The release includes the public key so it
can be verified; installations must already trust that key before applying
updates.

Before the first scheduled run, configure repository secrets
`ARKUP_UPDATE_SIGNING_KEY_B64` and `ARKUP_UPDATE_PUBLIC_KEY_B64` with the
base64-encoded keypair files. The workflow checks that both exist before it
starts the multi-hour build and refuses to publish if signing or verification
fails. Restrict changes to the default branch and treat the private key as a
release credential.

Run the pure Python checks with:

```sh
python3 -m unittest discover -s tests -p 'test_update_builder.py' -v
```
