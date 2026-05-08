#!/usr/bin/env bash

# Exit on error
set -e

# Define Flutter version
FLUTTER_VERSION="3.22.0" # Or whichever stable version you prefer
FLUTTER_CHANNEL="stable"

# Install Flutter
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter..."
  curl -C - -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  tar xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
  rm flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter commands
flutter doctor
flutter pub get
flutter build web --release
