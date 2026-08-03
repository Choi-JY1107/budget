import SwiftUI

/// 달력 영역: 상단 타이틀·테마 선택·이번 달 지출 + 월 이동 + 날짜 그리드
struct CalendarView: View {
    var store: BudgetStore
    let theme: Theme
    @Binding var viewDate: Date
    @Binding var selectedKey: String?

    private var cal: Calendar { Calendar.current }
    private var viewYear: Int { cal.component(.year, from: viewDate) }
    private var viewMonth: Int { cal.component(.month, from: viewDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            card
            Spacer()
        }
    }

    // MARK: 상단 헤더

    private var header: some View {
        HStack {
            Text("💰 가계부").font(.system(size: 22, weight: .bold))
            Spacer()
            AppearancePicker()
            VStack(alignment: .trailing, spacing: 2) {
                Text("이번 달 지출  ").foregroundColor(.secondary).font(.system(size: 12))
                    + Text(shortWon(store.monthTotal(year: viewYear, month: viewMonth)))
                        .font(.system(size: 15, weight: .bold))
                if store.monthTarget(year: viewYear, month: viewMonth) > 0 {
                    Text("목표 합계 \(shortWon(store.monthTarget(year: viewYear, month: viewMonth)))")
                        .foregroundColor(.secondary).font(.system(size: 11))
                }
            }
        }
    }

    // MARK: 달력 카드

    private var card: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(String(viewYear))년 \(viewMonth)월").font(.system(size: 18, weight: .bold))
                Spacer()
                Button("오늘") { viewDate = Date() }
                    .buttonStyle(NavButtonStyle())
                Button("‹") { shiftMonth(-1) }.buttonStyle(NavButtonStyle())
                Button("›") { shiftMonth(1) }.buttonStyle(NavButtonStyle())
            }
            weekdayHeader
            grid
        }
        .padding(20)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.shadow, radius: 12, y: 2)
    }

    private var weekdayHeader: some View {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { i in
                Text(weekdays[i])
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(i == 0 ? theme.warning : i == 6 ? theme.accent : .secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        return LazyVGrid(columns: cols, spacing: 6) {
            ForEach(gridCells(), id: \.self) { cell in
                if cell <= 0 {
                    // 달 시작 전 빈 칸
                    Color.clear.frame(height: 78)
                } else {
                    let date = cal.date(from: DateComponents(year: viewYear, month: viewMonth, day: cell))!
                    DayCellView(store: store, theme: theme, date: date, selectedKey: $selectedKey)
                }
            }
        }
    }

    // MARK: 헬퍼

    private func shiftMonth(_ delta: Int) {
        if let d = cal.date(byAdding: .month, value: delta, to: viewDate) { viewDate = d }
    }

    /// 앞쪽 빈 칸(음수 = 고유 placeholder)과 실제 날짜(1...n)를 담은 배열
    private func gridCells() -> [Int] {
        let first = cal.date(from: DateComponents(year: viewYear, month: viewMonth, day: 1))!
        let startDow = cal.component(.weekday, from: first) - 1   // 0 = 일요일
        let daysInMonth = cal.range(of: .day, in: .month, for: first)!.count
        var out: [Int] = []
        var placeholder = -1
        for _ in 0..<startDow { out.append(placeholder); placeholder -= 1 }
        out.append(contentsOf: Array(1...daysInMonth))
        return out
    }
}
