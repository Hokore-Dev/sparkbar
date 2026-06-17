#!/bin/bash
#
# Build script for SparkBar.
# Produces a universal (arm64 + x86_64) menu bar app, ad-hoc signed so it
# runs locally without a paid Apple Developer ID.

set -e

echo "Building SparkBar..."

APP_NAME="SparkBar.app"
APP_PATH="build/$APP_NAME"

# Fresh build directory (stale xattrs from prior signs can break codesign).
rm -rf build
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"

# App bundle metadata
cp Info.plist "$APP_PATH/Contents/"
echo -n "APPL????" > "$APP_PATH/Contents/PkgInfo"

# App icon
if [ ! -f "SparkBar.icns" ]; then
    echo "Creating app icon..."
    ./make_app_icon.sh >/dev/null 2>&1 || true
fi
if [ -f "SparkBar.icns" ]; then
    cp SparkBar.icns "$APP_PATH/Contents/Resources/"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string SparkBar" "$APP_PATH/Contents/Info.plist" 2>/dev/null \
        || /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile SparkBar" "$APP_PATH/Contents/Info.plist"
fi

# Compile each architecture, then lipo into a universal binary.
for ARCH in arm64 x86_64; do
    swiftc -parse-as-library -O \
        -o "$APP_PATH/Contents/MacOS/SparkBar_$ARCH" \
        Sources/*.swift \
        -framework SwiftUI \
        -framework AppKit \
        -target "${ARCH}-apple-macos12.0"
done

lipo -create -output "$APP_PATH/Contents/MacOS/SparkBar" \
    "$APP_PATH/Contents/MacOS/SparkBar_arm64" \
    "$APP_PATH/Contents/MacOS/SparkBar_x86_64"
rm "$APP_PATH/Contents/MacOS/SparkBar_arm64" "$APP_PATH/Contents/MacOS/SparkBar_x86_64"
chmod 755 "$APP_PATH/Contents/MacOS/SparkBar"

# Strip detritus that codesign rejects, then ad-hoc sign.
xattr -cr "$APP_PATH"
find "$APP_PATH" -name '._*' -delete 2>/dev/null || true
find "$APP_PATH" -name '.DS_Store' -delete 2>/dev/null || true
codesign --force --deep --sign - "$APP_PATH"
codesign --verify --verbose=2 "$APP_PATH"

echo "Build successful: $APP_PATH"

# Launch only on a developer machine; skip in headless CI.
if [ -z "$CI" ]; then
    echo "Launching..."
    open "$APP_PATH"
fi
