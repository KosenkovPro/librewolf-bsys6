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

### Repository settings

| Name | Kind | Purpose |
| --- | --- | --- |
| `BUILD_RUNNER_JSON` | variable | The runner for the build jobs, for example `["self-hosted","linux","x64"]`. Defaults to `["ubuntu-latest"]`. |
| `GHCR_OWNER` | variable | The owner of the images in the container registry. Defaults to `kosenkovpro`. |
| `SIGNING_KEY` | secret | The GPG key used to sign the artifacts. |
| `CHOCO_API_KEY` | secret | The Chocolatey API key, without it the Chocolatey push is skipped. |
| `MS_CLIENT_SECRET` | secret | The Microsoft Store secret, without it the Store push is skipped. |

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
