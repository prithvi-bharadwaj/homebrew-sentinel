#!/usr/bin/env bash
set -euo pipefail

project_file="${1:-Sentinel.xcodeproj/project.pbxproj}"

if [[ ! -f "${project_file}" ]]; then
  echo "Project file not found: ${project_file}" >&2
  exit 1
fi

# XcodeGen follows the newest installed Xcode when choosing objectVersion.
# GitHub's macos-14 image may select an older Xcode that cannot open objectVersion 77.
perl -0pi -e 's/objectVersion = 77;/objectVersion = 56;/' "${project_file}"
