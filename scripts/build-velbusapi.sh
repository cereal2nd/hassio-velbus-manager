#!/usr/bin/env bash
# Build published Velbus Manager binaries for a Home Assistant app architecture.
# Output: velbus-manager/velbusapi/<arch>/  (not committed; assembled in CI or local dev)
set -euo pipefail

usage() {
  echo "Usage: VELBUS_MANAGER_REF=main VELBUS_MANAGER_SRC=/path/to/manager $0 <aarch64|amd64|armv7|armhf>" >&2
  echo "  Or set VELBUS_MANAGER_REPO to clone upstream." >&2
}

ARCH="${1:-}"
if [[ -z "${ARCH}" ]]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT_DIR="${REPO_ROOT}/velbus-manager/velbusapi/${ARCH}"

VELBUS_MANAGER_REF="${VELBUS_MANAGER_REF:-main}"
VELBUS_MANAGER_REPO="${VELBUS_MANAGER_REPO:-}"
VELBUS_MANAGER_SRC="${VELBUS_MANAGER_SRC:-}"

case "${ARCH}" in
  aarch64) RID=linux-musl-arm64 ;;
  amd64) RID=linux-musl-x64 ;;
  armv7 | armhf) RID=linux-musl-arm ;;
  *)
    echo "Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

WORKDIR=""
if [[ -n "${VELBUS_MANAGER_SRC}" ]]; then
  SRC="$(cd "${VELBUS_MANAGER_SRC}" && pwd)"
elif [[ -n "${VELBUS_MANAGER_REPO}" ]]; then
  WORKDIR="$(mktemp -d)"
  trap 'rm -rf "${WORKDIR}"' EXIT
  git clone --depth 1 --branch "${VELBUS_MANAGER_REF}" "${VELBUS_MANAGER_REPO}" "${WORKDIR}/src"
  SRC="${WORKDIR}/src"
else
  echo "Set VELBUS_MANAGER_SRC or VELBUS_MANAGER_REPO." >&2
  usage
  exit 1
fi

RELEASE_CSPROJ="$(find "${SRC}" -type f -name 'Velbus.*.Release.csproj' | head -1)"
if [[ -z "${RELEASE_CSPROJ}" ]]; then
  echo "No Velbus.*.Release.csproj found under ${SRC}" >&2
  exit 1
fi

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/wwwroot"

echo "Publishing Velbus Manager (${RID}) to ${OUT_DIR}..."
dotnet publish "${RELEASE_CSPROJ}" \
  --framework net8.0 \
  -c Release \
  -r "${RID}" \
  --self-contained true \
  -p:PublishSingleFile=false \
  -p:DebugType=None \
  -o "${OUT_DIR}"

# Upstream may ship the entrypoint under a legacy Velbus.*.Release name; normalize for the app.
while IFS= read -r -d '' candidate; do
  if [[ "$(basename "${candidate}")" != "Velbus.Manager.Release" ]]; then
    mv "${candidate}" "${OUT_DIR}/Velbus.Manager.Release"
    break
  fi
done < <(find "${OUT_DIR}" -maxdepth 1 -type f -name 'Velbus.*.Release' -print0)

echo "Building Angular UI..."
(
  cd "${SRC}/velbus.angular.client"
  npm ci
  npm run build -- --configuration production
)
cp -a "${SRC}/velbus.angular.client/dist/velbus.angular.client/velbus-ui" \
  "${OUT_DIR}/wwwroot/velbus-ui"

echo "Done. Payload size:"
du -sh "${OUT_DIR}"