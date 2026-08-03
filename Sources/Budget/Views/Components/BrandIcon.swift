import SwiftUI
import AppKit

/// 앱 번들의 Resources/BrandLogos/<id>.png 로고를 불러와 캐시한다.
@MainActor
enum BrandLogoStore {
    private static var cache: [String: NSImage?] = [:]

    static func image(for id: String) -> NSImage? {
        if let cached = cache[id] { return cached }
        var img: NSImage? = nil
        for ext in ["png", "jpg", "jpeg"] {
            if let url = Bundle.main.url(forResource: id, withExtension: ext, subdirectory: "BrandLogos"),
               let loaded = NSImage(contentsOf: url) {
                img = loaded
                break
            }
        }
        cache[id] = img
        return img
    }
}

/// 커피 브랜드 아이콘. 실제 로고 이미지가 있으면 그것을, 없으면 색상 배지를 보여준다.
struct BrandIcon: View {
    let brand: CoffeeBrand
    var size: CGFloat = 16

    var body: some View {
        if let logo = BrandLogoStore.image(for: brand.id) {
            Image(nsImage: logo)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary.opacity(0.15), lineWidth: 0.5))
        } else {
            Text(brand.short)
                .font(.system(size: size * 0.52, weight: .black))
                .foregroundColor(brand.fg)
                .frame(width: size, height: size)
                .background(Circle().fill(brand.bg))
                .overlay(Circle().stroke(Color.primary.opacity(0.12), lineWidth: 0.5))
        }
    }
}

/// 브랜드 선택용 아이콘 버튼 묶음 (선택된 항목은 테두리로 강조)
struct BrandPicker: View {
    let theme: Theme
    @Binding var selected: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("커피 브랜드").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            // 브랜드가 늘어나 한 줄이 좁아지므로 5칸씩 2줄로 배치
            let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 5)
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(COFFEE_BRANDS) { b in
                    Button {
                        selected = (selected == b.id) ? nil : b.id
                    } label: {
                        BrandIcon(brand: b, size: 24)
                            .overlay(
                                Circle().stroke(selected == b.id ? theme.accent : .clear, lineWidth: 2)
                                    .padding(-2)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(b.name)
                }
            }
            if let b = brandFor(selected) {
                Text(b.name).font(.system(size: 10)).foregroundColor(theme.accent)
            }
        }
    }
}
