#!/bin/bash
# Launcher for the hand-installed cuda13-llama-cpp backend (installed by
# Muse on 2026-11-06 from the official LocalAI backend OCI image, because
# the backend gallery is not reachable from the Umbrel app proxy).
#
# Why not the stock run.sh? Files uploaded through Umbrel's file service
# land non-executable (0600) unless they are scripts, so neither the
# bundled lib/ld.so (glibc 2.35) nor the backend binary could be exec'd.
# The arrangement below is the stock geometry with a coherent runtime:
#   - lib-sys/ld.so is the glibc 2.39 loader copied (mode preserved) from
#     the installed cpu-llama-cpp backend; executing it puts the process
#     image in lib-sys/, where ggml discovers its backend libraries.
#   - lib-sys/ also holds the matching glibc 2.39 family copied from the
#     cpu bundle (libc/libm/libdl/libpthread/librt) plus this backend's
#     own non-glibc libraries (CUDA 13, ggml, llama). The CUDA bundle's
#     own glibc 2.35 in lib/ is intentionally NOT used: pairing the 2.39
#     loader with the 2.35 libc segfaults.
# The stock vendor run.sh is preserved in the workspace notes
# (~/workspace/umbrel-cuda-backend/run.sh.stock on Muse's machine).
CURDIR=$(dirname "$(realpath "$0")")
cd /
export LD_LIBRARY_PATH="$CURDIR/lib-sys"
exec "$CURDIR"/lib-sys/ld.so "$CURDIR"/llama-cpp-cpu-all "$@"
