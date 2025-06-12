#!/bin/bash
set -euo pipefail

# Configuration
PROJECT_NAME="GEOSwiftCore"
SCHEME="GEOSwiftCore"
PACKAGE_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_PATH="$PACKAGE_ROOT/Project/${PROJECT_NAME}/${PROJECT_NAME}.xcodeproj"
ARCHIVE_DIR="$PACKAGE_ROOT/.build/geos_archives"
OUTPUT_DIR="$PACKAGE_ROOT/.build/geos_output"
FINAL_DEST="$PACKAGE_ROOT/Binaries"
XCFRAMEWORK_NAME="$SCHEME.xcframework"

# Clean old builds
echo "🧹 Cleaning..."
rm -rf "$ARCHIVE_DIR" "$OUTPUT_DIR" "$FINAL_DEST/$XCFRAMEWORK_NAME"
mkdir -p "$ARCHIVE_DIR" "$OUTPUT_DIR" "$FINAL_DEST"

# Build one archive per platform
archive_framework() {
  local platform="$1"
  local sdk="$2"
  local archive_path="$ARCHIVE_DIR/$3"

  echo "📦 Archiving for $platform..."
  xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "generic/platform=$platform" \
    -sdk "$sdk" \
    -archivePath "$archive_path" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ENABLE_BITCODE=NO \
    CLANG_ENABLE_MODULES=YES \
    > /dev/null
}

# Archive all supported platforms
archive_framework "iOS" iphoneos "ios"
archive_framework "iOS Simulator" iphonesimulator "ios-sim"
archive_framework "macOS" macosx "macos"

# Create .xcframework
echo "🔗 Creating $XCFRAMEWORK_NAME..."
xcodebuild -create-xcframework \
  -framework "$ARCHIVE_DIR/ios.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
  -framework "$ARCHIVE_DIR/ios-sim.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
  -framework "$ARCHIVE_DIR/macos.xcarchive/Products/Library/Frameworks/$SCHEME.framework" \
  -output "$FINAL_DEST/$XCFRAMEWORK_NAME" > /dev/null

echo "✅ Created: $FINAL_DEST/$XCFRAMEWORK_NAME"
