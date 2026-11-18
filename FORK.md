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

## Licence

Licensed under the **Mozilla Public License 2.0** (see [`LICENSE`](./LICENSE)), the same
licence as upstream LibreWolf. The upstream copyright notices are preserved.
