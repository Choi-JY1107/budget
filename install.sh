#!/bin/bash
# 가계부 앱을 빌드해서 응용 프로그램 폴더에 설치한다.
set -e
cd "$(dirname "$0")"

# 1) 최신 빌드
./build.sh

# 2) 설치 위치 결정 (/Applications 우선, 권한 없으면 ~/Applications)
DEST="/Applications"
if [ ! -w "$DEST" ]; then
  DEST="$HOME/Applications"
  mkdir -p "$DEST"
fi

APP="$DEST/가계부.app"
echo "▶ 설치 중: $APP"

# 3) 실행 중이면 종료 후 교체
pkill -x Budget 2>/dev/null || true
sleep 1
rm -rf "$APP"
cp -R "build/가계부.app" "$APP"

# 4) 격리 속성 제거 + 임시 서명 (Gatekeeper 경고 방지)
xattr -cr "$APP" 2>/dev/null || true
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "✅ 설치 완료: $APP"
echo "   Launchpad / Spotlight(⌘Space) 에서 '가계부' 검색해 실행하세요."
