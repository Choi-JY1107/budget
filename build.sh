#!/bin/bash
# 가계부 맥 앱 빌드 스크립트
# 사용법: ./build.sh   →   build/가계부.app 생성
set -e
cd "$(dirname "$0")"

APP="build/가계부.app"
EXE_NAME="Budget"
BUNDLE_ID="com.jy.budget"
TARGET="arm64-apple-macosx14.0"

echo "▶ 컴파일 중..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Sources 아래 모든 .swift 파일을 함께 컴파일
SWIFT_FILES=$(find Sources -name '*.swift')

swiftc -O -parse-as-library \
  -target "$TARGET" \
  -framework SwiftUI -framework AppKit \
  -o "$APP/Contents/MacOS/$EXE_NAME" \
  $SWIFT_FILES

# 앱 아이콘 복사
if [ -f "Resources/AppIcon.icns" ]; then
  cp "Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

# 커피 브랜드 로고 복사 (있으면)
if [ -d "Resources/BrandLogos" ]; then
  cp -R "Resources/BrandLogos" "$APP/Contents/Resources/BrandLogos"
fi

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>가계부</string>
    <key>CFBundleDisplayName</key>     <string>가계부</string>
    <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>CFBundleIdentifier</key>      <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>         <string>1.0</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>LSMinimumSystemVersion</key>  <string>14.0</string>
    <key>NSHighResolutionCapable</key> <true/>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.finance</string>
</dict>
</plist>
PLIST

# 로컬 실행용 임시(ad-hoc) 서명 — Gatekeeper 경고 완화
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "✅ 완료: $APP"
echo "   실행: open \"$APP\"  또는 Finder에서 더블클릭"
