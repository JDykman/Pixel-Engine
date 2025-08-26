#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Build
"$SCRIPT_DIR/build_linux.sh"

ensure_link() {
  local dir="$1"; local base="$2"; local ver="${3:-14}"
  if [[ -f "$dir/$base.so" && ! -e "$dir/$base.so.$ver" ]]; then
    ln -sf "$dir/$base.so" "$dir/$base.so.$ver"
  fi
}

# Run
"$SCRIPT_DIR/build/linux_debug/game"
