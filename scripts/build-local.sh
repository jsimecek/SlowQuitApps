#!/usr/bin/env bash
# Build SlowQuitApps locally, sign it with a stable identity, optionally install to /Applications.
# Usage: scripts/build-local.sh [--install]
# Env: SIGN_IDENTITY (default "Apple Development", "-" for ad-hoc), CONFIGURATION (default Release)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-Release}"
SIGN_IDENTITY="${SIGN_IDENTITY:-Apple Development}"
DERIVED="$ROOT/build"
APP="$DERIVED/Build/Products/$CONFIGURATION/SlowQuitApps.app"
HELPER="$APP/Contents/Library/LoginItems/SlowQuitAppsLauncher.app"
DEST="/Applications/SlowQuitApps.app"

# Project pins 10.14, current Xcode supports 12.0+.
xcodebuild \
  -project "$ROOT/SlowQuitApps.xcodeproj" \
  -scheme SlowQuitApps \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED" \
  MACOSX_DEPLOYMENT_TARGET=12.0 \
  -quiet build

if [ "$SIGN_IDENTITY" != "-" ] && ! security find-identity -v -p codesigning | grep -q "\"$SIGN_IDENTITY"; then
  echo "Signing identity '$SIGN_IDENTITY' not found, falling back to ad-hoc." >&2
  echo "Ad-hoc builds lose the Accessibility grant on every rebuild." >&2
  SIGN_IDENTITY="-"
fi

# Sign inside-out; sqa script sits in Contents/MacOS so it counts as nested code.
codesign --force --timestamp=none --sign "$SIGN_IDENTITY" "$APP/Contents/MacOS/sqa"
codesign --force --timestamp=none --sign "$SIGN_IDENTITY" "$HELPER"
codesign --force --timestamp=none --sign "$SIGN_IDENTITY" "$APP"
codesign --verify --deep --strict "$APP"
echo "Built and signed: $APP"

if [ "${1:-}" = "--install" ]; then
  killall SlowQuitApps 2>/dev/null || true
  rm -rf "$DEST"
  ditto "$APP" "$DEST"
  open "$DEST"
  echo "Installed and launched: $DEST"
fi
