# sparkles-localai — LocalAI v4.12.1 with the CUDA 13 llama.cpp backend
# baked in, including the 2026-11-06 glibc fix, built for an RTX 5090
# (Blackwell, sm_120). Built by .github/workflows/build-images.yml and
# published to GHCR; never built on the Umbrel box.
#
# Why this exists: on 2026-11-06 the backend gallery was unreachable from
# the Umbrel app proxy, so the cuda13-llama-cpp backend was hand-installed
# on the box from the official backend OCI image, and its stock run.sh
# segfaulted (glibc 2.39 loader paired with the bundle's 2.35 libc). The
# working arrangement, preserved in ./run.sh next to this file:
#   lib-sys/ holds the glibc 2.39 loader + family copied from the CPU
#   backend, plus this backend's own non-glibc CUDA/ggml libs, and the
#   loader executes llama-cpp-cpu-all out of lib-sys/.
# This Dockerfile reproduces that arrangement at build time and FAILS THE
# BUILD LOUDLY if any piece is missing — the same fail-loud philosophy as
# the app's startup health gate (never silently fall back to CPU).

# Backend binaries: official LocalAI backend OCI image, digest pinned
# (digest recorded 2026-11-06 in backend_metadata.json on the build host).
FROM quay.io/go-skynet/local-ai-backends@sha256:856bc31f388ff1d2d2ccda827d1d76488fbb783de2a3ea502d0845a8b7384580 AS backend

# Main image. VERIFY the exact v4.12.1 CUDA tag on quay.io before the
# first CI run — LocalAI publishes variants like
# v4.12.1-cublas-cuda13-ffmpeg and -core; pick the cuda13 ffmpeg variant.
FROM quay.io/go-skynet/local-ai:v4.12.1-cublas-cuda13-ffmpeg AS runtime

ARG BACKEND_DIR=/backends/cuda13-llama-cpp
COPY --from=backend / ${BACKEND_DIR}-src/
COPY run.sh /tmp/fixed-run.sh

RUN set -eu; \
    # Locate the backend payload inside the copied OCI tree.
    BIN="$(find ${BACKEND_DIR}-src -name 'llama-cpp-cpu-all' -type f | head -1)"; \
    test -n "$BIN" || { echo 'FATAL: llama-cpp-cpu-all not found in backend image'; exit 1; }; \
    SRC="$(dirname "$BIN")"; \
    mkdir -p "${BACKEND_DIR}"; \
    cp -a "$SRC"/. "${BACKEND_DIR}/"; \
    # Build lib-sys/: glibc 2.39 loader + family from an installed CPU
    # backend in the main image (paths vary by variant — search for them).
    CPU_LD="$(find /backends /usr/local/share -name 'ld-linux-x86-64.so.2' 2>/dev/null | grep -v cuda13 || true)"; \
    CPU_LD="$(echo "$CPU_LD" | head -1)"; \
    test -n "$CPU_LD" || { echo 'FATAL: no CPU-backend glibc loader found to seed lib-sys'; exit 1; }; \
    CPU_DIR="$(dirname "$CPU_LD")"; \
    mkdir -p "${BACKEND_DIR}/lib-sys"; \
    for f in ld-linux-x86-64.so.2 libc.so.6 libm.so.6 libdl.so.2 libpthread.so.0 librt.so.1; do \
      if [ -e "$CPU_DIR/$f" ]; then cp -a "$CPU_DIR/$f" "${BACKEND_DIR}/lib-sys/"; \
      elif [ -e "$CPU_DIR/lib/$f" ]; then cp -a "$CPU_DIR/lib/$f" "${BACKEND_DIR}/lib-sys/"; fi; \
    done; \
    cp -a "${BACKEND_DIR}/lib-sys/ld-linux-x86-64.so.2" "${BACKEND_DIR}/lib-sys/ld.so"; \
    # The backend's own non-glibc libs (CUDA 13, ggml, llama) join lib-sys.
    if [ -d "${BACKEND_DIR}/lib" ]; then \
      find "${BACKEND_DIR}/lib" -maxdepth 1 -type f ! -name 'libc.so*' ! -name 'libm.so*' \
        ! -name 'libdl.so*' ! -name 'libpthread.so*' ! -name 'librt.so*' ! -name 'ld-*.so*' \
        -exec cp -a {} "${BACKEND_DIR}/lib-sys/" \; ; \
    fi; \
    test -e "${BACKEND_DIR}/lib-sys/libggml-cuda.so" || ls "${BACKEND_DIR}/lib-sys" | grep -qi cuda \
      || { echo 'FATAL: no CUDA ggml library in lib-sys — backend assembly wrong'; exit 1; }; \
    cp /tmp/fixed-run.sh "${BACKEND_DIR}/run.sh"; \
    chmod +x "${BACKEND_DIR}/run.sh" "${BACKEND_DIR}/llama-cpp-cpu-all" || true; \
    rm -rf "${BACKEND_DIR}-src" /tmp/fixed-run.sh; \
    echo "cuda13-llama-cpp backend assembled:"; ls "${BACKEND_DIR}" "${BACKEND_DIR}/lib-sys" | head -40

ENV LOCALAI_FORCE_META_BACKEND_CAPABILITY=nvidia

# Startup health gate lives in the app compose (entrypoint wrapper):
# the server refuses to start if nvidia-smi or the CUDA backend is absent.
