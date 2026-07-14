# Snap Store track request (TCG) — draft for forum.snapcraft.io

Post to: https://forum.snapcraft.io/ — category **store-requests**.
Once approved, the `ensure-track` CI job can self-create `v<major>.<minor>` tracks
via the storefront `create-track` endpoint (see `.github/scripts/snap-create-track.sh`).

---

**Title:** Track guardrail request for music-assistant-server (`v<major>.<minor>` pattern)

**Category:** store-requests

---

Hi store team,

I'd like to request **track creation guardrails** for my snap, so that new
version tracks matching a fixed pattern can be created automatically by CI,
per the simplified track request process.

**Snap:** `music-assistant-server` — https://snapcraft.io/music-assistant-server
**Publisher:** giaever-online (Giaever.online)
**Requested guardrail pattern:** `^v[0-9]+\.[0-9]+$` (e.g. `v2.6`, `v2.9`, `v2.10`)
**Initial tracks (if easier to create along with the guardrail):** `v2.6`, `v2.9`

### What the snap is

An (unofficial, clearly labelled as such) snap packaging of the Music Assistant
server (https://github.com/music-assistant/server), a self-hosted media library
manager that runs as an always-on daemon on devices like a Raspberry Pi or NAS.

### Why tracks

Upstream releases a new **minor line every 1–3 months** with frequent patch
releases in between (recent lines: 2.6 → Nov 2025, 2.7 → Mar 2026, 2.8 → Jun 2026,
2.9 → Jul 2026; the 2.9 line shipped four patch releases in the first two weeks of
July 2026 alone). Because this is an always-on home server, users want to **pin a
minor line** (`--channel=v2.9`) and receive only its patch releases, upgrading
lines on their own schedule, while `latest/*` keeps rolling forward.

### Track naming and lifecycle

- One track per upstream minor line, named `v<major>.<minor>` — mirrors the
  upstream version exactly (snap version `2.9.8` → track `v2.9`).
- Tracks are created by CI when the first build of a new upstream line lands
  (roughly monthly, matching the upstream cadence above).
- The **default track always points at the newest line** (set automatically on
  release), so `snap install music-assistant-server` never gets a stale version.
- Older tracks remain available for pinned users; they simply stop receiving
  releases when upstream stops patching that line.

### How releases work (automation)

CI (GitHub Actions) builds each release PR for amd64 + arm64 via Launchpad
remote-build, publishes to the per-PR branch channel `v<MM>/edge/<PR#>` for
testing, and on merge promotes those exact revisions to `v<MM>/stable` and the
`latest/*` channels. Track creation is the only step that needs the guardrail.

### Precedent

This publisher account has a long-standing precedent for exactly this model:
our `home-assistant-snap` (https://snapcraft.io/home-assistant-snap) ships one
track per upstream release line — more than 50 tracks to date, from `2021.8`
through `2025.11` — so users pin a Home Assistant version line and move to new
lines manually, since each line may bring breaking changes. This request applies
the same per-line track scheme to Music Assistant, with the guardrail replacing
per-track forum requests at the ~monthly upstream cadence.

Thanks!
