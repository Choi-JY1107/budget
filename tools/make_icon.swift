import AppKit

// 가계부 앱 아이콘 렌더러
// 파란→보라 그라디언트 스퀘어클 + 흰색 ₩ 심볼
// 실행하면 build/AppIcon.iconset 에 필요한 크기의 PNG를 생성한다.

let outDir = "build/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// (픽셀 크기, 파일명) — iconutil 규격
let variants: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

func render(_ px: Int) -> Data {
    let size = CGFloat(px)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return Data() }
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    let g = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = g

    let margin = size * 0.085
    let rect = CGRect(x: margin, y: margin, width: size - 2*margin, height: size - 2*margin)
    let radius = rect.width * 0.2237
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

    // 1) 드롭 섀도우
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
    shadow.shadowBlurRadius = size * 0.045
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.02)
    shadow.set()
    NSColor.black.setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    // 2) 그라디언트 채우기 (파랑 → 보라)
    let top    = NSColor(calibratedRed: 0.36, green: 0.47, blue: 1.00, alpha: 1)
    let bottom = NSColor(calibratedRed: 0.55, green: 0.35, blue: 0.98, alpha: 1)
    NSGradient(colors: [top, bottom])!.draw(in: path, angle: -90)

    // 3) 상단 하이라이트
    NSGraphicsContext.saveGraphicsState()
    path.addClip()
    let sheen = NSGradient(colors: [NSColor.white.withAlphaComponent(0.22),
                                    NSColor.white.withAlphaComponent(0.0)])!
    sheen.draw(in: NSRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height/2), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // 4) 얇은 내부 테두리
    let inset = size * 0.02
    let innerRect = rect.insetBy(dx: inset, dy: inset)
    let inner = NSBezierPath(roundedRect: innerRect, xRadius: radius - inset, yRadius: radius - inset)
    inner.lineWidth = max(1, size * 0.010)
    NSColor.white.withAlphaComponent(0.18).setStroke()
    inner.stroke()

    // 5) ₩ 심볼
    NSGraphicsContext.saveGraphicsState()
    let glyphShadow = NSShadow()
    glyphShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    glyphShadow.shadowBlurRadius = size * 0.02
    glyphShadow.shadowOffset = NSSize(width: 0, height: -size * 0.01)
    glyphShadow.set()

    let para = NSMutableParagraphStyle(); para.alignment = .center
    let font = NSFont.systemFont(ofSize: size * 0.50, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font, .foregroundColor: NSColor.white, .paragraphStyle: para,
    ]
    let str = NSAttributedString(string: "₩", attributes: attrs)
    let ss = str.size()
    // 시각적 중앙 보정
    let drawRect = CGRect(x: rect.midX - ss.width/2,
                          y: rect.midY - ss.height/2 + size * 0.005,
                          width: ss.width, height: ss.height)
    str.draw(in: drawRect)
    NSGraphicsContext.restoreGraphicsState()

    g.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:]) ?? Data()
}

for (px, name) in variants {
    let data = render(px)
    let url = URL(fileURLWithPath: "\(outDir)/\(name)")
    try? data.write(to: url)
    print("  \(name)  (\(px)px)")
}
print("✅ iconset 생성 완료")
