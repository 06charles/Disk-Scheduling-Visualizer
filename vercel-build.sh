#!/bin/bash
echo "Installing Flutter..."
if [ -d "flutter" ]; then
  cd flutter
  git pull
  cd ..
else
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Enabling Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building for Web..."
flutter build web --release
