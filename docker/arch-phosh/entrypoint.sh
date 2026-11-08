#!/bin/bash
# Headless Phosh session for browser control (noVNC -> wayvnc -> phoc).
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/xdg-runtime}"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

# wlroots headless backend: no real display, no input devices.
export WLR_BACKENDS=headless
export WLR_LIBINPUT_NO_DEVICES=1
# Software rendering only — the container gets no GPU.
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_RENDERER=pixman
# Phone-shaped virtual output.
export WLR_HEADLESS_OUTPUTS=1
export PHOC_HEADLESS_WIDTH="${PHOC_HEADLESS_WIDTH:-720}"
export PHOC_HEADLESS_HEIGHT="${PHOC_HEADLESS_HEIGHT:-1440}"

# Start the compositor with the Phosh session inside it.
# phoc launches phosh via its session support; if the phoc build lacks
# -C session handling, fall back to running phosh against the socket.
phoc -C /usr/share/phosh/phoc.ini &
PHOC_PID=$!

# Wait for the Wayland socket, then serve it over VNC (internal only —
# the noVNC sidecar is the only thing that should ever reach this port).
for i in $(seq 1 30); do
  [ -S "$XDG_RUNTIME_DIR/wayland-0" ] && break
  sleep 1
done
export WAYLAND_DISPLAY=wayland-0
wayvnc --output=HEADLESS-1 --port=5900 0.0.0.0 &
VNC_PID=$!

wait -n $PHOC_PID $VNC_PID
