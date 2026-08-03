import SwiftUI

/// 시스템 / 라이트 / 다크 테마를 고르는 세그먼트 컨트롤.
/// 선택값은 @AppStorage("appearance")에 저장되어 앱 전체에 반영된다.
struct AppearancePicker: View {
    @AppStorage("appearance") private var appearance = "system"

    var body: some View {
        Picker("", selection: $appearance) {
            Text("시스템").tag("system")
            Text("라이트").tag("light")
            Text("다크").tag("dark")
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 190)
    }
}
