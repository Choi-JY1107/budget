import SwiftUI

/// 달력 상단의 "오늘 / ‹ / ›" 버튼 스타일. primary 불투명도를 써서
/// 라이트/다크 모두에서 자연스럽게 보인다.
struct NavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .frame(minWidth: 34, minHeight: 30)
            .padding(.horizontal, 6)
            .background(configuration.isPressed ? Color.primary.opacity(0.12) : Color.primary.opacity(0.05))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.15)))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.primary)
    }
}
