# MTGO OCI

Run [Magic: The Gathering Online](https://www.mtgo.com) on **Linux** and **macOS** using Docker.

Pre-built images running MTGO in Docker using [Wine](https://www.winehq.org) are available on Docker Hub, with additional containers for building and running [MTGOSDK](https://github.com/videre-project/MTGOSDK)-based applications.

## Quick Start

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS) or [Docker Engine](https://docs.docker.com/engine/install/) (Linux).

> [!TIP]
> **Automatic Installation**: MTGO will automatically download and install on the first run of a new container. You can disable this by setting `AUTO_INSTALL_MTGO=false`. once setup, launch the game with `mtgo`.

Then run the command for your platform:

<details open>
<summary><b>Linux (Wayland)</b></summary>

For modern desktops (GNOME 45+, KDE Plasma 6):
```bash
docker run -it --name mtgo \
  -e DISPLAY=$DISPLAY \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e XDG_RUNTIME_DIR=/tmp/runtime-dir \
  -v ${XDG_RUNTIME_DIR}/wayland-0:/tmp/runtime-dir/wayland-0 \
  videreproject/mtgo:wayland
```
</details>

<details>
<summary><b>Linux (X11)</b></summary>

For X11-based desktops or NVIDIA GPU users:
```bash
xhost +local:docker
docker run -it --name mtgo \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  videreproject/mtgo:x11
```
</details>

<details>
<summary><b>macOS (Headless + VNC) — Recommended</b></summary>

Runs a virtual desktop inside the container. All windows stay together.
```bash
docker run -it --name mtgo \
  -e DISPLAY=:99 \
  -e START_VNC=true \
  -p 5900:5900 \
  videreproject/mtgo:headless
```
Then open **Screen Sharing** (⌘+Space → "Screen Sharing") and connect to `vnc://localhost:5900`.

> [!TIP]
> MTGO's UI is not responsive in headless mode. The resolution is fixed at startup. Use "Scale to Fit" in Screen Sharing to adjust the view, or set a different `RESOLUTION` (see [Configuration](#configuration)).
</details>

<details>
<summary><b>macOS (XQuartz) — High Performance</b></summary>

Lower latency by forwarding windows directly to your desktop.

> [!WARNING]
> Pop-up windows and dialogs may sometimes get stuck behind the main window or lose focus.

1. `brew install --cask xquartz`
2. Open XQuartz → Preferences → Security → Check "Allow connections from network clients."
3. Restart XQuartz, then run `xhost +localhost`.
4. Run:
   ```bash
   docker run -it --name mtgo-x11 \
     -e DISPLAY=host.docker.internal:0 \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     videreproject/mtgo:x11
   ```
</details>

## Persistent Setup (Docker Compose)

The commands above work for quick sessions but **do not persist data** between runs. For regular use, use the Compose files in this repository to automatically manage volumes for your Wine settings, decklists, and login data.

1. [Download this repo as a ZIP](https://github.com/videre-project/mtgo-oci/archive/refs/heads/main.zip) or clone it with Git.
2. Run from the project root:
   ```bash
   # Linux (Wayland)
   docker compose -f mtgosdk/docker-compose.yml up -d mtgosdk-wayland

   # Linux (X11)
   docker compose -f mtgosdk/docker-compose.yml up -d mtgosdk-x11

   # macOS / headless
   docker compose -f mtgosdk/docker-compose.yml up -d mtgosdk-headless
   ```

## Available Images

| Image | Description |
|-------|-------------|
| `videreproject/mtgo` | MTGO runtime (Wine + .NET 4.8 + fonts) |
| `videreproject/mtgosdk` | Development environment (adds .NET SDK + auto-clones [MTGOSDK](https://github.com/videre-project/MTGOSDK)) |

Replace `videreproject/mtgo` with `videreproject/mtgosdk` in any command above to use the SDK variant.

## Configuration

> [!NOTE]
> These variables primarily control the **Headless** environment. In Wayland/X11 modes, your host desktop manages the display natively.

| Variable | Description | Default |
|----------|-------------|---------|
| `START_VNC` | Starts the x11vnc server (Headless only) | `false` |
| `WINE_VIRTUAL_DESKTOP` | Enables Wine's "Emulate Virtual Desktop" for window stability (Headless only) | `true` |
| `RESOLUTION` | Sets the Xvfb and Virtual Desktop resolution (Headless only) | `1280x1024x24` |
| `AUTO_INSTALL_MTGO` | Automatically runs `install-mtgo.sh` if MTGO is missing | `true` |
| `MTGOSDK_PATH` | Path to your local [MTGOSDK](https://github.com/videre-project/MTGOSDK) repository | `../../MTGOSDK` |

## Reference

| Action | Command |
|--------|---------|
| Install MTGO | `install-mtgo.sh` |
| Run MTGO | `mtgo` |
| Pull latest image | `docker pull videreproject/mtgo:latest` |
| Open a shell | `docker exec -it mtgo /bin/bash` |
| Stop | `docker stop mtgo` |
| Remove | `docker rm mtgo` |
| View logs | `docker logs -f mtgo` |



<details>
<summary><b>Building Locally</b></summary>

To modify and rebuild the images yourself:
```bash
git clone https://github.com/videre-project/mtgo-oci.git && cd mtgo-oci
docker compose -f mtgo/docker-compose.yml build
docker compose -f mtgosdk/docker-compose.yml build
```
</details>

## License

This project is licensed under the [Apache-2.0 License](/LICENSE).
