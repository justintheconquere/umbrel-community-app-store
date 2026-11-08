# sparkles-arch-phosh — Arch Linux + Phosh phone shell in a container.
# Phosh's compositor (phoc) is wlroots-based and runs on the headless
# backend; wayvnc serves the session for browser control via noVNC.
# No systemd, no privileged mode: a plain entrypoint starts the stack.
# Built by .github/workflows/build-images.yml -> GHCR. Never built on
# the Umbrel box.
FROM archlinux:latest

RUN pacman -Syu --noconfirm \
      phosh phoc wayvnc squeekboard \
      gnome-console gnome-text-editor epiphany \
      xdg-desktop-portal xdg-desktop-portal-wlr \
      pipewire wireplumber \
      ttf-dejavu noto-fonts \
    && pacman -Scc --noconfirm \
    && useradd -m -s /bin/bash user

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER user
ENV HOME=/home/user
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
