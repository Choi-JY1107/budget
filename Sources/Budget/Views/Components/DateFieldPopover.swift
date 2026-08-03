import SwiftUI

/// 날짜 입력 필드. 클릭하면 달력이 열리고, 날짜를 고르면 곧바로 닫힌다.
struct DateFieldPopover: View {
    @Binding var date: Date
    let theme: Theme

    @State private var showing = false
    @State private var hovering = false

    private var label: String {
        let c = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
        let names = ["", "일", "월", "화", "수", "목", "금", "토"]
        return "\(c.year!)년 \(c.month!)월 \(c.day!)일 (\(names[c.weekday!]))"
    }

    var body: some View {
        Button { showing.toggle() } label: {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 11)).foregroundColor(.secondary)
                Text(label).font(.system(size: 12, weight: .semibold))
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 9).padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(hovering ? Color.primary.opacity(0.08) : Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(showing ? theme.accent : Color.primary.opacity(0.15),
                            lineWidth: showing ? 1.5 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .popover(isPresented: $showing, arrowEdge: .bottom) {
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(10)
                .frame(width: 250)
                // 날짜를 고르면 달력을 닫는다
                .onChange(of: date) { _, _ in showing = false }
        }
    }
}
