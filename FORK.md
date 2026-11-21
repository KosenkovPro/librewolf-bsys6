# This is a fork of LibreWolf bsys6

This repository is a **fork of [LibreWolf bsys6](https://codeberg.org/librewolf/bsys6)**,
mirrored from Codeberg and continued here on GitHub.

`bsys6` is LibreWolf's build system: it produces the Docker build environments and
packages LibreWolf for Linux, Windows and macOS.

## Upstream

| | Repository |
| --- | --- |
| Upstream (canonical) | <https://codeberg.org/librewolf/bsys6> |
| This fork | <https://github.com/KosenkovPro/librewolf-bsys6> |
| Patches (upstream) | <https://codeberg.org/librewolf/source> |
| Patches (this fork) | <https://github.com/KosenkovPro/librewolf-source> |

## Remotes

| Remote | URL | Purpose |
| --- | --- | --- |
| `origin` | `https://github.com/KosenkovPro/librewolf-bsys6.git` | This fork — push here |
| `upstream` | `https://codeberg.org/librewolf/bsys6.git` | Upstream LibreWolf — pull from here |

## Syncing with upstream

```bash
git fetch upstream
git log --oneline HEAD..upstream/master
git merge upstream/master
git push origin master
```

## Git LFS

Three files are stored in Git LFS — the PGO profiles used for optimised builds:

```
assets/linux.profdata
assets/macos.profdata
assets/windows.profdata
```

Clone with LFS enabled (the default) to get them, or run `git lfs pull` afterwards.

## CI on GitHub Actions

The upstream CI runs on Forgejo with self-hosted runners, a package registry and an S3
bucket. This fork ports it to GitHub Actions.

| Workflow | What it does |
| --- | --- |
| [`build-image.yml`](.github/workflows/build-image.yml) | Builds the Docker build environments (`assets/Dockerfile.*`) and pushes them to `ghcr.io/kosenkovpro/bsys6:<target>`. |
| [`build-release.yml`](.github/workflows/build-release.yml) | Builds the packages for Linux, Windows and macOS and publishes them as a GitHub release. |
| [`ci.yml`](.github/workflows/ci.yml) | Checks the shell scripts, the workflow files and the forge adapter. |

### The forge backend

The build system talked to a Forgejo instance directly. `FORGE_TYPE` selects the backend:

| `FORGE_TYPE` | Releases | Sources | Artifacts |
| --- | --- | --- | --- |
| `forgejo` (the default) | the forgejo API | the package registry | an S3 bucket |
| `github` | the GitHub release API | the assets of a GitHub release | the assets of a GitHub release |

[`src/exports/forge.sh`](src/exports/forge.sh) hides the difference: both backends expose
the same `/repos/<owner>/<repo>/...` routes, only the base URL and the authentication
header differ. With `FORGE_TYPE=github` the release, its assets and the source archive all
live in GitHub releases — GitHub has no package registry for personal accounts and the fork
does not have an S3 bucket. The upstream forge is used as a fallback for the repositories
that are not mirrored into this fork (`winupdater`, `vc_redist`, ...).

The Dockerfiles take a `SOURCE_URL` build argument, so the images can fetch the source
archive from a GitHub release instead of the package registry.

### The environment inside the container

GitHub Actions overrides `HOME` in the container jobs: it points to `/github/home`
and not to the `/root` the images were built with. The tools of the build system
live in the home directory of the image, so the workflows give their paths explicitly:

| Variable | Value | What it holds |
| --- | --- | --- |
| `MOZBUILD` | `/root/.mozbuild` | the toolchain of the compiler, the Windows SDK, chocolatey |
| `MOZBUILD_STATE_PATH` | `/root/.mozbuild` | the state directory of `mach`, it looks for the compiler there |
| `CARGO_HOME`, `RUSTUP_HOME` | `/root/.cargo`, `/root/.rustup` | the Rust compiler |
| `GIT_CONFIG_COUNT`, `GIT_CONFIG_KEY_0`, `GIT_CONFIG_VALUE_0` | `safe.directory` | the repository belongs to the runner, the container works as root |

The images carry the same values as `ENV`, so they also work on their own.

### The memory of the build

The rust part of a release build is compiled with link time optimization
(`-Clto`, `-Cembed-bitcode=yes`, `-C codegen-units=1`, `-C debuginfo=2`). The
compiler of a big crate such as `gkrust` needs more memory than the 16 GB of a
standard runner, and the kernel kills it without a trace (`signal: 9, SIGKILL`).
Three things keep the build alive:

* The build jobs run the container with `--privileged` and add a swap file of
  8 GB before the build starts. The file has to be in the workspace: it is a
  bind mount of a real file system, the overlay of the container cannot hold
  swap. The swap is a last resort, `vm.swappiness` is set to zero, a runner
  that swaps on its own loses the connection to the server.
* The `JOBS` variable limits the number of parallel compilations. The compiler
  of the rust code is the one that needs the memory, the C++ compiler is
  satisfied with much less. The variable is passed to `mach build -j`. The
  cross build of the Windows target is the heaviest one and runs with a single
  job.
* The `RUSTFLAGS` variable holds `-Cdebuginfo=0`. The debug information of the
  rust code is dropped, the release packages hold the stripped binaries anyway,
  but the compiler needs much less memory for it.

Without these the build dies after about half an hour, in the rust code of the
release.

### Repository settings

| Name | Kind | Purpose |
| --- | --- | --- |
| `BUILD_RUNNER_JSON` | variable | The runner for the build jobs, for example `["self-hosted","linux","x64"]`. Defaults to `["ubuntu-latest"]`. |
| `CROSS_BUILD_RUNNER_JSON` | variable | The runner for the Windows and macOS builds. They cross compile and need wine, and the docker of the `ubuntu-latest` runners blocks a syscall that wine needs ([runner-images#14790](https://github.com/actions/runner-images/issues/14790)). Defaults to `["ubuntu-24.04"]`. |
| `GHCR_OWNER` | variable | The owner of the images in the container registry. Defaults to `kosenkovpro`. |
| `SIGNING_KEY` | secret | The GPG key used to sign the artifacts. |
| `OSSIGN_CONFIG` | secret | The configuration of OSSign, a JSON with the certificate and the private key of the self-signed certificate for the Windows binaries. |
| `CHOCO_API_KEY` | secret | The Chocolatey API key, without it the Chocolatey push is skipped. |
| `MS_CLIENT_SECRET` | secret | The Microsoft Store secret, without it the Store push is skipped. |

### The signing keys

The keys of the fork are not in the repository. They live in the `.secret` directory
of the working copy, which is in `.gitignore`:

```
.secret/
  gpg/signing-key.asc        the private GPG key, the value of SIGNING_KEY
  gpg/signing-key.pub.asc    the public GPG key, the users import it
  gpg/signing-key.fpr        the fingerprint of the key
  gpg/signing-key.rev        the revocation certificate of the key
  ossign/cert.pem            the certificate for the Windows binaries
  ossign/key.pem             the private key of the certificate
  ossign/config.json         the configuration of OSSign, the value of OSSIGN_CONFIG
```

The GPG key signs every asset of the release. The publishing job runs
`gpg --detach-sign` on each of them and uploads the `.sig` next to the file it
belongs to. The public key of the release is the file `gpg/signing-key.pub.asc`.

The certificate of `ossign` is self-signed: it is not issued by a certificate
authority, so Windows still warns about an unknown publisher. It is used for the
installer of the Windows build, the binaries inside the build are signed by the
`Signed` tool of the upstream.

The private GPG key has no passphrase, otherwise the signing would stop and ask for
it in the middle of the non-interactive build. Keep the `.secret` directory safe,
whoever has it can sign packages under the name of the fork.

### What is not ported

* The auto-update distribution (the `.mar` files and `update.xml` on a CDN) needs the
  upstream S3 bucket and CDN. The fork publishes the update manifests as release assets
  instead, the automatic updates of an installed LibreWolf still point at the upstream CDN.
* The package registry of the forge has no equivalent for a personal GitHub account, the
  release assets take its place.
* A full Firefox build needs a lot of CPU time. The standard GitHub runners have four
  cores and 16 GB of RAM, the build fits on their disk (145 GB) but takes many hours
  and can run into the timeout of the job. Set `BUILD_RUNNER_JSON` to a self-hosted or
  a larger runner to make it faster.

### The upstream workflows that are not ported

| Upstream workflow | Why |
| --- | --- |
| `build-signmar.yml` | It builds the `signmar` tool and publishes it to the Forgejo package registry. The images of this fork take the upstream build from `librewolf.dev`, so nothing has to be built here. |
| `cleanup-artifacts.yml` | It deletes the old objects of the S3 artifacts bucket. The fork has no S3 bucket, GitHub removes the workflow artifacts after the retention time. |

### The order of the workflows

1. In `librewolf-source`, run **Create Source Code Release** — it publishes the source
   archive as a GitHub release.
2. In this repository, run **Docker Image** — it builds the build environments from that
   source archive.
3. Run **Build & Publish Release** — it builds the packages and publishes the release.

## Licence

Licensed under the **Mozilla Public License 2.0** (see [`LICENSE`](./LICENSE)), the same
licence as upstream LibreWolf. The upstream copyright notices are preserved.
