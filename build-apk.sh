#!/bin/bash

set -e

export ANDROID_HOME="$HOME/android-sdk"
export PATH="$PATH:$HOME/flutter/bin:$HOME/android-sdk/cmdline-tools/latest/bin:$HOME/android-sdk/platform-tools"

echo "=============================="
echo "🧹 Cleaning project"
echo "=============================="
flutter clean

echo "=============================="
echo "📦 Getting dependencies"
echo "=============================="
flutter pub get

echo "=============================="
echo "🚀 Building APK (release)"
echo "=============================="
flutter build apk --release

echo "=============================="
echo "📦 APK location:"
echo "build/app/outputs/flutter-apk/app-release.apk"
echo "=============================="

echo "✅ Build finished!"