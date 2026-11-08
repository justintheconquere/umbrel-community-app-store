#!/usr/bin/env python3
"""Validate every app in this Umbrel Community App Store.

Checks (no Umbrel required):
  - umbrel-app-store.yml parses, store id present
  - every app folder name == manifest id, and id starts with "<store-id>-"
  - manifest has the required fields; ports are unique across apps
  - docker-compose.yml parses; every service image is pinned (no :latest
    unless the line carries a documented PIN EXCEPTION comment in the file)
  - app_proxy APP_HOST, when present, matches <app-id>_<service>_1
Run: python3 scripts/validate.py   (exit 1 on any failure)
"""
import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
errors = []
warnings = []


def err(msg):
    errors.append(msg)


store_file = ROOT / "umbrel-app-store.yml"
store = yaml.safe_load(store_file.read_text())
store_id = store.get("id")
if not store_id:
    err("umbrel-app-store.yml: missing store id")

ports = {}
for app_dir in sorted(ROOT.iterdir()):
    if not app_dir.is_dir() or app_dir.name.startswith((".", "scripts", "docker", "docs")):
        continue
    manifest_path = app_dir / "umbrel-app.yml"
    compose_path = app_dir / "docker-compose.yml"
    if not manifest_path.exists():
        continue  # not an app folder
    app = app_dir.name
    manifest = yaml.safe_load(manifest_path.read_text())
    if manifest.get("id") != app:
        err(f"{app}: folder name != manifest id ({manifest.get('id')})")
    if store_id and not app.startswith(store_id + "-"):
        err(f"{app}: id does not start with store prefix {store_id}-")
    for field in ("manifestVersion", "name", "version", "port", "category", "description"):
        if manifest.get(field) in (None, ""):
            err(f"{app}: manifest missing field {field}")
    port = manifest.get("port")
    if port in ports:
        err(f"{app}: port {port} already used by {ports[port]}")
    ports[port] = app

    if not compose_path.exists():
        err(f"{app}: missing docker-compose.yml")
        continue
    text = compose_path.read_text()
    compose = yaml.safe_load(text)
    services = (compose or {}).get("services", {})
    if not services:
        err(f"{app}: compose has no services")
    pin_exception = "PIN EXCEPTION" in text
    for svc, cfg in services.items():
        image = (cfg or {}).get("image", "")
        if svc == "app_proxy":
            continue
        if not image:
            warnings.append(f"{app}/{svc}: no image (build-based?)")
            continue
        if image.endswith(":latest") and not pin_exception:
            err(f"{app}/{svc}: image uses :latest without PIN EXCEPTION note: {image}")
        if ":" not in image.split("/")[-1] and "@sha256:" not in image:
            err(f"{app}/{svc}: image has no tag/digest: {image}")
    proxy = services.get("app_proxy")
    if proxy:
        env = proxy.get("environment", {})
        host = env.get("APP_HOST", "") if isinstance(env, dict) else ""
        m = re.fullmatch(re.escape(app) + r"_([a-z0-9-]+)_1", host or "")
        if not m:
            err(f"{app}: app_proxy APP_HOST '{host}' != <app-id>_<service>_1")
        elif m.group(1) not in services:
            err(f"{app}: app_proxy points at unknown service {m.group(1)}")

for w in warnings:
    print("WARN:", w)
if errors:
    for e in errors:
        print("ERROR:", e)
    sys.exit(1)
print(f"OK: {len(ports)} apps validated, ports unique, images pinned.")
