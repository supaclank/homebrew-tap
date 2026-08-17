#!/usr/bin/env bash
# Repoints Formula/clank-voice.rb at a released supaclank/clank tag:
#   ./scripts/bump-voice.sh v0.3.0
# Fetches the tag's source tarball, computes its sha256, rewrites url +
# sha256 in place, and prints the diff. Commit and push the result.
set -euo pipefail

tag="${1:?usage: $0 vX.Y.Z}"
case "$tag" in v*) ;; *) echo "tag must start with v (got '$tag')" >&2; exit 1 ;; esac

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
formula="$repo_root/Formula/clank-voice.rb"
url="https://github.com/supaclank/clank/archive/refs/tags/${tag}.tar.gz"

echo "fetching $url" >&2
sha="$(curl -fsSL "$url" | shasum -a 256 | awk '{print $1}')"

sed -i '' \
  -e "s#^  url \".*\"#  url \"${url}\"#" \
  -e "s#^  sha256 \".*\"#  sha256 \"${sha}\"#" \
  "$formula"

git -C "$repo_root" --no-pager diff -- "$formula"
