#!/usr/bin/env bash
set -euo pipefail

log(){ echo "[WE-Comp] $*"; }

have(){ command -v "$1" >/dev/null 2>&1; }

arch_uname="$(uname -m)"
os_id=""
os_codename=""

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  os_codename="${VERSION_CODENAME:-}"
fi

if have gitui; then
  log "gitui already installed: $(gitui --version || true)"
  exit 0
fi

log "Installing gitui (arch=${arch_uname}, os=${os_id}, codename=${os_codename})..."

# Try apt first if available
if have apt-get; then
  if sudo apt-get update -y >/dev/null 2>&1; then
    if sudo apt-get install -y gitui >/dev/null 2>&1; then
      log "Installed gitui via apt."
      exit 0
    else
      log "gitui not available via apt on this system (expected on Bookworm)."
    fi
  fi
fi

# Fallback: GitHub release binary
# Map arch -> expected asset match
asset_pat=""
case "$arch_uname" in
  aarch64|arm64)
    asset_pat="aarch64|arm64"
    ;;
  armv7l|armv7|armhf)
    asset_pat="armv7|armhf"
    ;;
  *)
    log "Unsupported CPU arch for automatic gitui binary install: $arch_uname"
    log "You can install manually from GitUI releases."
    exit 1
    ;;
esac

# deps
if ! have curl; then
  log "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi
if ! have wget; then
  log "Installing wget..."
  sudo apt-get update -y
  sudo apt-get install -y wget
fi
if ! have tar; then
  log "Installing tar..."
  sudo apt-get update -y
  sudo apt-get install -y tar
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

log "Fetching latest GitUI release info..."
json="$(curl -fsSL https://api.github.com/repos/extrawurst/gitui/releases/latest)"

# Prefer musl builds if present; otherwise take any linux tar.gz matching arch
url="$(printf "%s" "$json" \
  | grep -Eo 'https://[^"]+' \
  | grep -Ei 'gitui.*linux.*(tar\.gz|tgz)' \
  | grep -Ei "$asset_pat" \
  | head -n 1 || true)"

if [ -z "$url" ]; then
  log "Could not find a suitable GitUI linux release asset for arch: $arch_uname"
  log "Open: https://github.com/extrawurst/gitui/releases and install manually."
  exit 1
fi

log "Downloading: $url"
cd "$tmpdir"
wget -q "$url" -O gitui.tar.gz

log "Extracting..."
tar xzf gitui.tar.gz

# The archive usually contains a single 'gitui' binary somewhere; find it:
bin_path="$(find "$tmpdir" -maxdepth 3 -type f -name gitui -perm -u+x | head -n 1 || true)"
if [ -z "$bin_path" ]; then
  # If not executable yet, locate and chmod
  bin_path="$(find "$tmpdir" -maxdepth 3 -type f -name gitui | head -n 1 || true)"
  [ -n "$bin_path" ] && chmod +x "$bin_path"
fi

if [ -z "$bin_path" ]; then
  log "Extracted archive but couldn't find gitui binary."
  exit 1
fi

log "Installing to /usr/local/bin/gitui"
sudo install -m 0755 "$bin_path" /usr/local/bin/gitui

log "Done: $(gitui --version || echo gitui installed)"