#!/usr/bin/env bash
set -euo pipefail

# Settings
DIST="${DIST:-trixie}"
ARCH="${ARCH:-amd64}"

PROJECT_DIR="/work/project"
INPUT_DIR="/work/input"
OUT_DIR="/work/out"

# Show settings
echo "==> Using DIST=${DIST}, ARCH=${ARCH}"
echo "==> Project:  ${PROJECT_DIR}"
echo "==> Input:    ${INPUT_DIR}"
echo "==> Out:      ${OUT_DIR}"

mkdir -p "${PROJECT_DIR}" "${OUT_DIR}"

cd "${PROJECT_DIR}"

echo "==> Cleaning old artifacts.."
lb clean --purge || true

# Generate baseline config
lb config \
  --distribution "${DIST}" \
  --architectures "${ARCH}" \
  --debian-installer live \
  --binary-images iso-hybrid \
  --mirror-bootstrap "https://deb.debian.org/debian" \
  --mirror-chroot "https://deb.debian.org/debian" \
  --mirror-chroot-security "https://security.debian.org/debian-security" \
  --mirror-debian-installer "https://deb.debian.org/debian" \

# Copy custom config etc.
mkdir -p config/package-lists config/includes.chroot \
  config/includes.installer config/hooks

# Overwrite if existing
if [ -d "${INPUT_DIR}/package-lists" ]; then
  rsync -a --delete "${INPUT_DIR}/package-lists/" config/package-lists/
fi

if [ -d "${INPUT_DIR}/includes.chroot" ]; then
  rsync -a --delete "${INPUT_DIR}/includes.chroot/" config/includes.chroot/
fi

if [ -d "${INPUT_DIR}/includes.installer" ]; then
  rsync -a --delete "${INPUT_DIR}/includes.installer/" config/includes.installer/
fi

if [ -d "${INPUT_DIR}/hooks" ]; then
  rsync -a --delete "${INPUT_DIR}/hooks/" config/hooks/
fi

# Make hooks executable
if [ -d config/hooks ]; then
  find config/hooks -type f -name "*.chroot" -exec chmod +x {} \; || true
fi

echo "==> Building ISO.."
lb build

ISO="$(ls -1 live-image-*.hybrid.iso | head -n 1)"
if [ -z "${ISO}" ]; then
  echo "[ERROR] ISO not found after build"
  exit 1
fi

echo "==> Copying ${ISO} to ${OUT_DIR} .."
cp -v "${ISO}" "${OUT_DIR}/"

echo "==> Done"
