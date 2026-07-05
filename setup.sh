#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source ~/.bashrc

export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/android-sdk}"
export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$HOME/flutter/bin:$PATH"

echo "============================"
echo "📦 Updating system packages"
echo "============================"
sudo apt update -y

echo "============================"
echo "📦 Installing dependencies"
echo "============================"
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa openjdk-17-jdk cmake ninja-build pkg-config libgtk-3-dev

echo "============================"
echo "📦 Installing Flutter SDK"
echo "============================"
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
else
  echo "Flutter already installed"
fi

echo "============================"
echo "📦 Setting PATH"
echo "============================"
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT="$ANDROID_HOME"' >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$HOME/flutter/bin:$PATH"' >> ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$HOME/flutter/bin:$PATH"

echo "============================"
echo "📦 Flutter version"
echo "============================"
flutter --version

echo "============================"
echo "📦 Running flutter doctor"
echo "============================"
flutter config --android-sdk "$ANDROID_SDK_ROOT" >/dev/null 2>&1 || true
flutter config --jdk-dir "$JAVA_HOME" >/dev/null 2>&1 || true
flutter doctor || true

echo "============================"
echo "📦 Android licenses"
echo "============================"
if [ -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
fi

echo "✅ Setup finished!"
echo "👉 Next steps:"
echo "   1. flutter pub get"
echo "   2. ./build-apk.sh"