#!/bin/bash

set -e

echo "============================"
echo "📦 Updating system packages"
echo "============================"
sudo apt update -y

echo "============================"
echo "📦 Installing dependencies"
echo "============================"
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa openjdk-17-jdk

echo "============================"
echo "📦 Installing Flutter SDK"
echo "============================"
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
  else
    echo "Flutter already installed"
    fi

    echo "============================"
    echo "📦 Setting PATH"
    echo "============================"
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    export PATH="$PATH:$HOME/flutter/bin"

    echo "============================"
    echo "📦 Flutter version"
    echo "============================"
    flutter --version

    echo "============================"
    echo "📦 Running flutter doctor"
    echo "============================"
    flutter doctor || true

    echo "============================"
    echo "📦 Android licenses (manual step may be needed)"
    echo "Run: flutter doctor --android-licenses"
    echo "============================"

    echo "✅ Setup finished!"
    echo "👉 Next steps:"
    echo "   1. flutter doctor --android-licenses"
    echo "   2. flutter pub get"
    echo "   3. flutter build apk --release"