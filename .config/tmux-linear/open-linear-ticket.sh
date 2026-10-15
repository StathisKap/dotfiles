#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"

if [[ -z "$URL" || "$URL" != https://linear.app/* ]]; then
    echo "Expected a Linear ticket URL." >&2
    exit 1
fi

# Prefer the native macOS app. If it is unavailable (or cannot open the URL),
# hand the same URL to the default browser.
if open -Ra Linear 2>/dev/null && open -a Linear "$URL" 2>/dev/null; then
    exit 0
fi

open "$URL"
