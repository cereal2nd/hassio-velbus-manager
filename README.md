# hassio-velbus-manager

Home Assistant **app** (formerly add-on) repository that runs the [Velbus Manager](https://github.com/velbus/velbus-manager) gateway on Home Assistant OS.

Velbus Manager exposes the Velbus installation through HTTP on port **4201** (`/velbus/api/v2/…`, WebSocket, and `/velbus-ui/`). It talks to the Velbus bus **directly** (USB/serial) or over **TCP** (network gateway or remote host). Pair it with the **Velbus** custom integration (`velbus-home-assistant-integration`) for Home Assistant.

Documentation for authoring apps: [Home Assistant Apps](https://contributors.home-assistant.io/apps/).

## Install

1. **Settings → Apps → Repositories** → add `https://github.com/cereal2nd/hassio-velbus-manager`
2. Refresh, open **Velbus Manager**, install, and start.
3. Open the UI from the sidebar (ingress) or enable host port **4201** if you need direct access.
4. Configure the bus in the Manager UI under **Bus connections** (USB/serial or TCP). For a USB Velbus interface on Home Assistant OS, map the device in the app configuration (see [DOCS](velbus-manager/DOCS.md)).

## Configuration

| Option | Default | Purpose |
|--------|---------|---------|
| `gateway_host` | `172.30.32.1` | Optional: TCP host used only when seeding the **first** gateway on an empty installation |
| `gateway_port` | `27015` | TCP port for that seeded gateway (standard Velbus TCP port) |
| `authentication` | `false` | JWT introspection for the API (leave off for the Home Assistant integration) |
| `log_level` | `Information` | .NET console log level |

The `gateway_*` options do **not** replace the Manager UI: they only auto-create one TCP gateway when none exist yet. Serial/USB buses are added in **Bus connections** after passing the device through to the container.

Installation data is stored under `/data` (mapped volume `data`).

## Development

The app **image does not build from source**. It only copies pre-built binaries from `velbus-manager/velbusapi/<arch>/` (published .NET 8 **musl** payload plus `wwwroot/velbus-ui`). That keeps the Docker build fast and avoids shipping C#/TypeScript sources in the image layer.

### 1. Compile the payload

Point at a local Velbus Manager checkout:

```bash
VELBUS_MANAGER_SRC=/path/to/velbus-manager ./scripts/build-velbusapi.sh amd64
```

Or let the script clone upstream (set `VELBUS_MANAGER_REPO` and optional `VELBUS_MANAGER_REF`; not stored in the image):

```bash
VELBUS_MANAGER_REF=main VELBUS_MANAGER_REPO=https://github.com/example/velbus-manager.git ./scripts/build-velbusapi.sh aarch64
```

GitHub Actions uses the repository variable `VELBUS_MANAGER_REPOSITORY` the same way for CI builds.

### 2. Build the container

```bash
cd velbus-manager
docker buildx build \
  --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23 \
  --build-arg BUILD_ARCH=amd64 \
  --build-arg BUILD_VERSION=local \
  --build-arg BUILD_REF=local \
  --build-arg BUILD_NAME="Velbus Manager" \
  --build-arg BUILD_DESCRIPTION="Local build" \
  --platform linux/amd64 \
  -t velbus-manager:local \
  .
```

GitHub Actions runs `build-velbusapi.sh` per architecture, then invokes the [Home Assistant builder](https://github.com/home-assistant/builder). Published images use `image: ghcr.io/cereal2nd/velbus-manager`, so Home Assistant normally **pulls** the image and does not compile on the device.

## Related projects

- [velbus-manager](https://github.com/velbus/velbus-manager) — upstream gateway
- [velbus-aio](https://github.com/Cereal2nd/velbus-aio) — Python library (Velbus Manager backend)