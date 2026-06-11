#!/bin/bash
# Builds the Mac version of NeonSiege and packages it as NeonSiege.dmg.
# Requirements: Xcode installed. Run from the project folder:
#   cd NeonSiege && ./make_dmg.sh
set -euo pipefail

echo "==> Building NeonSiegeMac (Release)..."
xcodebuild -project NeonSiege.xcodeproj \
           -target NeonSiegeMac \
           -configuration Release \
           SYMROOT="$(pwd)/build" \
           build

APP="build/Release/NeonSiegeMac.app"
if [ ! -d "$APP" ]; then
  echo "ERROR: build product not found at $APP" >&2
  exit 1
fi

echo "==> Staging DMG contents..."
STAGE="build/dmg_staging"
rm -rf "$STAGE" NeonSiege.dmg
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/NeonSiege.app"
ln -s /Applications "$STAGE/Applications"

echo "==> Creating NeonSiege.dmg..."
hdiutil create -volname "NeonSiege" -srcfolder "$STAGE" -ov -format UDZO NeonSiege.dmg

rm -rf "$STAGE"
echo ""
echo "Done! -> $(pwd)/NeonSiege.dmg"
echo "Open it and drag NeonSiege.app to Applications."
