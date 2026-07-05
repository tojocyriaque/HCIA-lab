#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/android-sdk}"
export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

echo "=============================="
echo "☕ Installing Java"
echo "=============================="
sudo apt update -y
sudo apt install -y openjdk-17-jdk unzip curl

echo "=============================="
echo "📦 Creating Android SDK folder"
echo "=============================="
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
cd "$ANDROID_SDK_ROOT"

echo "=============================="
echo "⬇️ Downloading Android cmdline tools"
echo "=============================="
curl -L -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

unzip sdk.zip
rm sdk.zip

mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

echo "=============================="
echo "🌍 Setting environment variables"
echo "=============================="
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT="$ANDROID_HOME"' >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.bashrc

source ~/.bashrc

echo "=============================="
echo "📦 Installing Android packages"
echo "=============================="
yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "cmake;3.22.1" \
  "ndk;28.2.13676358"

      echo "=============================="
      echo "✅ Accepting licenses"
      echo "=============================="
      yes | sdkmanager --licenses

      echo "=============================="
      echo "🔍 Flutter doctor check"
      echo "=============================="
      flutter doctor

      echo "✅ Android setup complete!"