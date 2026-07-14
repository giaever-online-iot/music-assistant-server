# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is an **unofficial snap package** of the Music Assistant server (not related to or endorsed by the official project). It contains **no application source code** — only packaging. The actual server code is fetched at build time from `https://github.com/music-assistant/server.git`, pinned to the git tag matching the `version:` field in `snap/snapcraft.yaml`.

**To upgrade to a new Music Assistant release:** bump `version:` in `snap/snapcraft.yaml`. That version must correspond to an existing tag on the upstream server repo (the `music-assistant` part uses `source-tag: ${SNAPCRAFT_PROJECT_VERSION}`).

## Commands

```bash
snapcraft                 # Build the snap (uses LXD/Multipass; produces music-assistant-server_<version>_<arch>.snap)
snapcraft clean           # Clean build state (add a part name to clean just one part)
sudo snap install ./music-assistant-server_<version>_amd64.snap --dangerous   # Install a local build for testing
sudo snap logs music-assistant-server.music-assistant   # Inspect the running daemon
```

```bash
for t in .github/scripts/*.test.sh; do bash "$t"; done   # CI helper unit tests (offline, fixture-driven)
shellcheck .github/scripts/*.sh && shellcheck --severity=warning -x src/*   # what the lint workflows run
```

Built `.snap` files in the repo root are build artifacts, not source.

## Architecture

Everything is defined in `snap/snapcraft.yaml` (base `core24`, strict confinement, amd64 + arm64). It has three parts:

- **`music-assistant`** — the main part. Python plugin building the upstream server from `requirements_all.txt`. Pulls ffmpeg/snapserver and multimedia libs as stage packages, using the deb-multimedia.org apt repository (declared under `package-repositories`) for codec packages.
- **`snapcraft-preload`** — cmake-built LD_PRELOAD shim (from sergiusens/snapcraft-preload) that redirects hardcoded paths so the app works under strict confinement.
- **`cmd`** — dumps `src/` into the snap, organizing `env-wrapper` into `cmd-chain/`.

**Runtime launch chain:** the `music-assistant` app is a simple daemon (`restart-condition: always`) started via `command-chain`: `bin/snapcraft-preload` → `cmd-chain/env-wrapper` → `bin/mass --config $SNAP_DATA --log-level debug`. The `src/env-wrapper` script appends every subdirectory of `$SNAP/usr/lib/<arch>-linux-gnu` (e.g. pulseaudio) to `LD_LIBRARY_PATH` before exec'ing the command.

`vivid/` holds Snap Store listing graphics (banner, screenshots) — not part of the build.

## CI / release pipeline

Releases are PR-driven (ported from `giaever-online-iot/zwave-js-ui`); direct pushes to main are never built. A PR touching `snap/**` or `src/**` triggers `pr-build-snap.yml`: Launchpad remote-build per arch, upload to the per-PR store channel `v<MM>/edge/<PR#>` (the version track is auto-created if missing), sticky PR comment with install instructions. Merging triggers `release-on-merge.yml`, which **promotes the PR's exact revisions** (no rebuild) to `v<MM>/stable` and gated `latest/*` channels, then updates the default track. `block-fork-prs.yml` auto-closes fork PRs — that is what makes it safe for `pull_request` jobs to receive store secrets.

Key adaptations vs. the zwave-js-ui original: Music Assistant versions are bare (`2.9.8`, no `v`) while tracks keep the `v2.9` form, and the `latest/stable` bump fires on a new **minor** line (`needs-stable-bump` compares `v<major>.<minor>` lines, not majors) because upstream stays on major 2 indefinitely.

All version/channel math and `snapcraft status` parsing lives in `.github/scripts/snap-release.sh` (fixture-tested; never do ad-hoc awk against snapcraft output in workflow YAML). Secrets required: `SNAPCRAFT_STORE_CREDENTIALS` (macaroon), `LAUNCHPAD_CREDENTIALS` (remote-build), `SNAPCRAFT_SESSION_COOKIE` (storefront create-track; expires periodically — refresh when ensure-track 302/401s). Track creation additionally needs the store's track-creation guardrail approved (request draft: `docs/snap-store-track-request.md`).
