# Velbus Manager

## Overview

This app runs Velbus Manager: a gateway between your Velbus installation and HTTP/WebSocket clients (including Home Assistant). The Manager connects to the bus over **USB/serial** or **TCP**; no separate serial-to-TCP proxy is required.

## Typical setup

### USB / serial Velbus interface (common on Home Assistant OS)

1. Attach the Velbus USB interface to the host.
2. In the app **Configuration**, under **Devices**, map the serial device into the container (for example `/dev/serial/by-id/usb-…` → `/dev/ttyVelbus`).
3. Start the app and open **Bus connections** in the Manager UI. Add a **USB** connection and select the mapped device.
4. Add the **Velbus** integration in Home Assistant and point it at this app (`velbus_manager` on the internal network, or ingress).

### TCP (network Velbus gateway or remote bus)

1. Install and start this app.
2. In **Bus connections**, add a **TCP** connection with the gateway host and port (Velbus TCP is usually port **27015**), or use the app options below to seed the first TCP gateway on a fresh install.
3. Add the **Velbus** integration as above.

The optional **gateway host** / **gateway port** settings only apply when the installation has no gateways yet: they create one default TCP gateway at startup. Change or remove gateways anytime in the UI.

## Web interface

After start, open the app from the sidebar. The UI is served under `/velbus-ui/`. The REST API is under `/velbus/api/v2`.

## Data

Velbus installation files (gateways, modules, VLP data) live in the app’s `/data` volume. They survive app restarts and are included in backups when the app is backed up.

## Authentication

Keep **authentication** disabled unless you operate Velbus Manager with a separate auth server. The Home Assistant integration expects an open local API on the internal network.