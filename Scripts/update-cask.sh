#!/usr/bin/env bash
set -euo pipefail

version="${1:?version is required}"
sha256="${2:?sha256 is required}"
owner="${3:-USER}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cask="${root}/Casks/sentinel.rb"

perl -0pi -e "s/version \".*?\"/version \"${version}\"/s" "${cask}"
perl -0pi -e "s/sha256 \".*?\"/sha256 \"${sha256}\"/s" "${cask}"
perl -0pi -e "s#https://github.com/[^/]+/homebrew-sentinel#https://github.com/${owner}/homebrew-sentinel#g" "${cask}"
