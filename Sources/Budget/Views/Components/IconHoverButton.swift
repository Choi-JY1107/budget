import SwiftUI

/// 아이콘 버튼. 마우스를 올리면 배경이 생겨 클릭 가능 영역이 분명하게 보인다.
struct IconHoverButton: View {
    let systemName: String
    var size: CGFloat = 11
    var hitSize: CGFloat = 26          // 실제 클릭 가능 영역
    var isActive: Bool = false         // 현재 선택/편집 중 강조
    var activeColor: Color = .accentColor
    var hoverColor: Color = .primary
    let action: () -> Void

    @State private var hovering = false

    private var fg: Color {
        if isActive { return activeColor }
        return hovering ? hoverColor : .secondary
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(fg)
                .frame(width: hitSize, height: hitSize)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(hovering ? hoverColor.opacity(0.14)
                              : isActive ? activeColor.opacity(0.12) : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
    }
}
