#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/android-sdk}"
export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"

if [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
elif [ -d "/usr/lib/jvm/java-1.17.0-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-1.17.0-openjdk-amd64"
else
  echo "Java 17 is required for this project. Install it first." >&2
  exit 1
fi

export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$HOME/flutter/bin:$PATH"

echo "Using Java: $JAVA_HOME"
java -version

if command -v flutter >/dev/null 2>&1; then
  flutter config --android-sdk "$ANDROID_SDK_ROOT" >/dev/null 2>&1 || true
  flutter config --jdk-dir "$JAVA_HOME" >/dev/null 2>&1 || true
fi

if [ -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
  "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" "platforms;android-36" "build-tools;36.0.0" "platform-tools" "cmake;3.22.1" "ndk;28.2.13676358" >/dev/null 2>&1 || true
fi

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