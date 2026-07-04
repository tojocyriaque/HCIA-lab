#!/bin/bash

set -e

echo "=============================="
echo "☕ Installing Java"
echo "=============================="
sudo apt update -y
sudo apt install -y openjdk-17-jdk unzip curl

echo "=============================="
echo "📦 Creating Android SDK folder"
echo "=============================="
mkdir -p $HOME/android-sdk/cmdline-tools
cd $HOME/android-sdk

echo "=============================="
echo "⬇️ Downloading Android cmdline tools"
echo "=============================="
curl -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

unzip sdk.zip
rm sdk.zip

mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true

echo "=============================="
echo "🌍 Setting environment variables"
echo "=============================="
echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc

export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

echo "=============================="
echo "📦 Installing Android packages"
echo "=============================="
yes | sdkmanager --sdk_root=$ANDROID_HOME \
  "platform-tools" \
    "platforms;android-34" \
      "build-tools;34.0.0"

      echo "=============================="
      echo "✅ Accepting licenses"
      echo "=============================="
      yes | sdkmanager --licenses

      echo "=============================="
      echo "🔍 Flutter doctor check"
      echo "=============================="
      flutter doctor

      echo "✅ Android setup complete!"