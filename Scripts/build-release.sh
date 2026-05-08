#!/usr/bin/env bash
set -euo pipefail

version="${1:-0.1.0}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
derived_data="${root}/DerivedData"
release_dir="${root}/release"

cd "${root}"

xcodegen generate
xcodebuild \
  -project Sentinel.xcodeproj \
  -scheme Sentinel \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "${derived_data}" \
  build \
  -quiet

app_path="${derived_data}/Build/Products/Release/Sentinel.app"
if [[ ! -d "${app_path}" ]]; then
  echo "Sentinel.app was not produced at ${app_path}" >&2
  exit 1
fi

codesign --force --deep --sign - "${app_path}"

rm -rf "${release_dir}"
mkdir -p "${release_dir}"
dmg_path="${release_dir}/Sentinel-${version}.dmg"

if command -v create-dmg >/dev/null 2>&1; then
  create-dmg \
    --volname "Sentinel" \
    --window-pos 200 120 \
    --window-size 560 360 \
    --icon-size 96 \
    --app-drop-link 380 170 \
    "${dmg_path}" \
    "${app_path}"
else
  hdiutil create -volname "Sentinel" -srcfolder "${app_path}" -ov -format UDZO "${dmg_path}"
fi

shasum -a 256 "${dmg_path}"
