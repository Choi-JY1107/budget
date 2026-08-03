import SwiftUI

/// 달력의 하루 칸: 날짜, 태그 색 점, 합계 금액. 클릭하면 선택된다.
struct DayCellView: View {
    var store: BudgetStore
    let theme: Theme
    let date: Date
    @Binding var selectedKey: String?

    private var cal: Calendar { Calendar.current }

    var body: some View {
        let key = dateKey(date)
        let day = cal.component(.day, from: date)
        let dow = cal.component(.weekday, from: date)   // 1 = 일 ... 7 = 토
        let recs = store.records(on: key)
        let isToday = key == dateKey(Date())
        let isSelected = key == selectedKey

        Button { selectedKey = key } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(day)")
                        .font(.system(size: 13, weight: isToday ? .heavy : .semibold))
                        .foregroundColor(isToday ? theme.accent
                                         : dow == 1 ? theme.warning
                                         : dow == 7 ? theme.accent : .primary)
                    if isToday {
                        Text("오늘")
                            .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                if !recs.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(Array(Set(recs.map { $0.tag })), id: \.self) { t in
                            Circle().fill(colorFor(tag: t)).frame(width: 6, height: 6)
                        }
                    }
                    Spacer(minLength: 0)
                    Text(shortWon(store.total(on: key)))
                        .font(.system(size: 11, weight: .bold)).foregroundColor(.primary)
                        .lineLimit(1).minimumScaleFactor(0.7)
                } else {
                    Spacer(minLength: 0)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
            .background(theme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.accent : theme.border, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
