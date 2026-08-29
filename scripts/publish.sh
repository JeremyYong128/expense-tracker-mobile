#!/bin/bash

# Example command: ./scripts/publish.sh 1.1.2+1

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Expense Tracker Mobile Publisher ===${NC}"

# Load API keys from environment file
if [ ! -f "scripts/publish.env" ]; then
    echo -e "${RED}Error: scripts/publish.env not found!${NC}"
    echo "Please create scripts/publish.env with APPSTORE_API_KEY and APPSTORE_API_ISSUER."
    exit 1
fi
source scripts/publish.env

# 1. Validate Input
VERSION=$1
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: You must provide a version string.${NC}"
    echo "Usage: ./scripts/publish.sh <version>"
    echo "Example: ./scripts/publish.sh 1.1.2+5"
    exit 1
fi

echo -e "${YELLOW}Step 1: Bumping version to $VERSION...${NC}"
# Use sed to update the version in pubspec.yaml
# We use an empty string for the backup extension to work across both macOS and Linux sed
sed -i '' "s/^version: .*/version: $VERSION/" pubspec.yaml
echo -e "${GREEN}✓ Version updated in pubspec.yaml${NC}"

echo -e "\n${YELLOW}Step 2: Cleaning build directory...${NC}"
# 2. Clean build folder
if ! flutter clean; then
    echo -e "${RED}Error: flutter clean failed.${NC}"
    echo "This is usually because you have an active 'flutter run' session holding a lock on the build folder."
    echo "Please stop any running flutter terminals (Control + C) and try again."
    exit 1
fi

echo -e "\n${YELLOW}Step 3: Building iOS App Bundle (IPA)...${NC}"
# 3. Build the app
flutter build ipa --release
echo -e "${GREEN}✓ Build completed successfully${NC}"

IPA_PATH="build/ios/ipa/expense_tracker_mobile.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}Error: IPA not found at $IPA_PATH${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 4: Uploading to App Store Connect...${NC}"
# 4. Upload to App Store
xcrun altool --upload-app --type ios -f "$IPA_PATH" --apiKey "$APPSTORE_API_KEY" --apiIssuer "$APPSTORE_API_ISSUER"
echo -e "${GREEN}✓ Successfully uploaded to App Store Connect${NC}"

echo -e "\n${YELLOW}Step 5: Uploading dSYMs to Firebase Crashlytics...${NC}"
# 5. Upload dSYMs
UPLOAD_SYMBOLS="build/ios/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
DSYM_DIR="build/ios/archive/Runner.xcarchive/dSYMs"
PLIST_PATH="$PWD/ios/Runner/GoogleService-Info.plist"

if [ -f "$UPLOAD_SYMBOLS" ] && [ -d "$DSYM_DIR" ] && [ -f "$PLIST_PATH" ]; then
    echo "Uploading dSYMs to Firebase Crashlytics..."
    "$UPLOAD_SYMBOLS" -gsp "$PLIST_PATH" -p ios "$DSYM_DIR"
else
    echo "Error: Required files or directories not found."
    [ ! -f "$UPLOAD_SYMBOLS" ] && echo "Missing binary: $UPLOAD_SYMBOLS"
    [ ! -d "$DSYM_DIR" ] && echo "Missing dSYM dir: $DSYM_DIR"
    [ ! -f "$PLIST_PATH" ] && echo "Missing plist: $PLIST_PATH"
    exit 1
fi

echo -e "\n${GREEN}=== Publish Complete! ===${NC}"
echo "You can now log into App Store Connect to release the app via TestFlight or submit for review."
