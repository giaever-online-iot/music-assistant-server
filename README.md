# music-assistant
Music Assistant is a free, opensource Media library manager that connects to your streaming services and a wide range of connected speakers. The server is the beating heart, the core of Music Assistant and must run on an always-on device like a Raspberry Pi, a NAS or an Intel NUC or alike.

# Package version
This is the snap package of this software. At the moment it's considered to be bleeding edge. Please use with caution and report bugs. This project needs help. Maintainers (help) wanted.

This project is not related to the official project, nor endorsed by it.

# Release channels
- `latest/edge` — every mainline build.
- `latest/candidate` — the newest release of the current version line (rolling).
- `latest/stable` — the final release of the previous version line; advances when a new line (e.g. v2.9 → v2.10) ships.
- `v<major>.<minor>` tracks (e.g. `v2.9`) — pin a version line and receive only its patch releases:

```
sudo snap install music-assistant-server --channel=v2.9
```

Releases are driven by pull requests: a PR bumping `version:` in `snap/snapcraft.yaml` builds and publishes to the per-PR channel `v<MM>/edge/<PR#>` for testing; merging promotes those exact revisions to `v<MM>/stable` and the `latest/*` channels.