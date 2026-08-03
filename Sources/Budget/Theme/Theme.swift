import SwiftUI

/// 라이트/다크 모드에 맞춰 적응하는 색상 팔레트
struct Theme {
    let scheme: ColorScheme
    var isDark: Bool { scheme == .dark }

    var page: Color   { isDark ? Color(red: 0.11, green: 0.12, blue: 0.14) : Color(red: 0.96, green: 0.965, blue: 0.972) }
    var card: Color   { isDark ? Color(red: 0.17, green: 0.18, blue: 0.21) : .white }
    var border: Color { isDark ? Color(white: 0.32) : Color(white: 0.90) }
    var shadow: Color { isDark ? .black.opacity(0.35) : .black.opacity(0.06) }

    let accent  = Color(red: 0.30, green: 0.44, blue: 1.0)
    let warning = Color(red: 1.0, green: 0.36, blue: 0.43)   // 초과/일요일 강조
}

/// 사용자 설정 문자열 → SwiftUI ColorScheme (nil = 시스템 설정 따름)
func schemeFor(_ s: String) -> ColorScheme? {
    switch s {
    case "light": return .light
    case "dark":  return .dark
    default:      return nil
    }
}
