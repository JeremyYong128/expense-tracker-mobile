# App Store Publishing Guide

Follow these steps to publish a new version of Expense Tracker Mobile to the Apple App Store.

## Usage

We have fully automated the release process (including version bumping, compiling, App Store uploading, and Crashlytics dSYM uploading) into a single script.

To publish a new version, open your terminal in the root of the project and run:

```bash
./scripts/publish.sh <new_version>
```

For example, to publish version `1.1.2+5`:
```bash
./scripts/publish.sh 1.1.2+5
```

### What this script does automatically:
1. **Version Bump**: Updates `pubspec.yaml` to the new version provided.
2. **Build**: Compiles the release iOS App Bundle (`.ipa`).
3. **App Store Upload**: Uses your pre-configured App Store Connect API keys to upload the `.ipa` to Apple.
4. **dSYM Upload**: Securely uploads the new dSYM debug symbols to Firebase Crashlytics so your crashes are readable.

Once the script completes and says `Publish Complete!`, you can log into [App Store Connect](https://appstoreconnect.apple.com/) shortly after to release it via TestFlight or submit it for App Store review!
