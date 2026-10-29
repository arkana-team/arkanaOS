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

The base system build installs the pinned `arkup` client at `/usr/bin/arkup`,
so installed systems can verify and apply `.aup` update packages.

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
the pinned arkup source and Rust dependencies. The image and build script use
the same merged upstream arkup commit
`ab6a1b7ee9321587b3ab1d371f56b04362ac35cb`, which provides the `--system-file`
option required to mark release metadata as system-managed. Set
`ARKUP_GIT_REF` only when deliberately testing another reviewed compatible
commit. Rootless Podman runs use `keep-id` so the unprivileged container can read
private input trees and signing keys owned by the invoking account.

## Scheduled developer releases

GitHub Actions publishes a scheduled release every day at 03:00 UTC. Sunday
and Tuesday through Saturday are nightly builds; Monday is the weekly developer
release. Each scheduled release uses the same staged ISO pipeline and release
note template, and attaches the ISO and signed `.aup` delta package(s), their
checksums, and the public verification key. Every update filename includes its
required `from-build-N` base. Nightlies use the latest scheduled release as the
base. Monday publishes a package from the previous weekly build and, when
different, another from Sunday's nightly build. Users choose the package that
matches their installed build, then use the next package matching the new build
number. Installations must trust the published key before applying updates.

The base ISO is downloaded from its persistent GitHub Release asset. The
workflow validates the asset's GitHub SHA-256 digest, release marker, tag
commit, and successful default-branch Run All provenance before extracting the
filesystem. This avoids reliance on expiring Actions artifact storage.

Before the first scheduled update release, run `Run All Pipeline Stages` once
with `workflow_dispatch` on the default branch. That bootstrap release includes
the ISO and provenance marker needed to validate the persistent base release
asset; it does not include an update package. Scheduled releases then publish
both the ISO and update package assets.

Before scheduled runs, configure organization or repository Actions secrets
`ARKUP_UPDATE_SIGNING_KEY_B64` and `ARKUP_UPDATE_PUBLIC_KEY_B64` with the
base64-encoded keypair files. The workflow checks that both exist before it
starts the multi-hour build and refuses to publish if signing or verification
fails. Restrict changes to the default branch and treat the private key as a
release credential.

Run the pure Python checks with:

```sh
python3 -m unittest discover -s tests -p 'test_update_builder.py' -v
```
