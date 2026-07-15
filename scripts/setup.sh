#!/usr/bin/env bash
# Manasal Solitaire — geliştirme ortamı kurulumu.
#
# Sabitlenmiş sürümlü Flutter SDK'yı ~/flutter altına kurar ve web'i etkinleştirir.
# Sürüm scripts/flutter-version.txt dosyasından okunur (CI aynı dosyayı kullanır).
#
# Kullanım:  bash scripts/setup.sh
# Sonra:     export PATH="$HOME/flutter/bin:$PATH"
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/scripts/flutter-version.txt")"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"

echo "==> Hedef Flutter sürümü: $VERSION"

if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "==> Flutter zaten kurulu: $FLUTTER_DIR"
else
  echo "==> Flutter klonlanıyor (stable, sığ)..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "==> Sürüm sabitleniyor: $VERSION"
git -C "$FLUTTER_DIR" fetch --depth 1 origin "refs/tags/$VERSION:refs/tags/$VERSION" 2>/dev/null || true
git -C "$FLUTTER_DIR" checkout "$VERSION" 2>/dev/null || echo "   (etikete geçilemedi; stable ucu kullanılıyor)"

echo "==> Yapılandırma..."
flutter config --no-analytics --enable-web >/dev/null
echo "==> Web artefaktları indiriliyor..."
flutter precache --web
echo "==> Bağımlılıklar..."
( cd "$ROOT" && flutter pub get )

echo ""
echo "==> Kurulum tamam. PATH'e ekleyin:"
echo "    export PATH=\"$FLUTTER_DIR/bin:\$PATH\""
flutter --version
