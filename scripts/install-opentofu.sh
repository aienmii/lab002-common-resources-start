#!/usr/bin/env bash
set -euo pipefail

if command -v tofu >/dev/null 2>&1; then
  tofu version
  exit 0
fi

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

curl --proto '=https' --tlsv1.2 -fsSL \
  https://get.opentofu.org/install-opentofu.sh \
  -o "$installer"
chmod 700 "$installer"
"$installer" --install-method deb

hash -r
tofu version
