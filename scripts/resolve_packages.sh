#!/bin/bash

# Script to resolve Swift packages if they're missing
# This prevents the need to manually reinstall packages after deleting derived data
#
# Usage:
#   - Run manually: ./scripts/resolve_packages.sh
#   - Or add as a "Run Script" build phase in Xcode (before "Compile Sources")

set -e

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
PROJECT_PATH="$PROJECT_ROOT/Shortlist/Shortlist.xcodeproj"

# Use SRCROOT if available (when run from Xcode), otherwise use PROJECT_ROOT
if [ -z "$SRCROOT" ]; then
    SRCROOT="$PROJECT_ROOT/Shortlist"
fi

PACKAGE_RESOLVED="$SRCROOT/Shortlist.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

if [ -f "$PACKAGE_RESOLVED" ]; then
    echo "📦 Resolving Swift packages from Package.resolved..."
    cd "$SRCROOT"
    xcodebuild -project "$PROJECT_PATH" -resolvePackageDependencies 2>&1 | grep -v "note:" || true
    echo "✅ Swift packages resolved successfully."
else
    echo "⚠️  Warning: Package.resolved not found at $PACKAGE_RESOLVED"
    echo "   Packages may need manual resolution in Xcode."
fi

