import SwiftUI

/// 최상위 레이아웃: 왼쪽 달력 + 오른쪽 사이드바(태그별 현황 / 날짜 상세)
struct ContentView: View {
    @State private var store = BudgetStore()
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewDate = Date()             // 현재 보고 있는 달의 기준 날짜
    @State private var selectedKey: String? = nil    // 날짜를 클릭해야 값이 생긴다

    private var theme: Theme { Theme(scheme: colorScheme) }
    private var cal: Calendar { Calendar.current }
    private var year: Int { cal.component(.year, from: viewDate) }
    private var month: Int { cal.component(.month, from: viewDate) }

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // 왼쪽: 태그별 현황
            ScrollView {
                TagSummaryView(store: store, theme: theme, year: year, month: month)
            }
            .frame(width: 288)

            // 가운데: 달력
            CalendarView(store: store, theme: theme, viewDate: $viewDate, selectedKey: $selectedKey)

            // 오른쪽: 검색 + 선택 날짜 상세
            ScrollView {
                VStack(spacing: 20) {
                    SearchView(store: store, theme: theme, selectedKey: $selectedKey)
                    if let key = selectedKey {
                        DetailPanelView(store: store, theme: theme, selectedKey: key)
                    } else {
                        hintCard
                    }
                }
            }
            .frame(width: 308)
        }
        // 타이틀바를 숨겼으므로 상단에 신호등 버튼 공간을 비워둔다
        .padding(.top, 38)
        .padding([.horizontal, .bottom], 20)
        .background(theme.page)
    }

    /// 날짜 미선택 시 안내 카드
    private var hintCard: some View {
        VStack(spacing: 8) {
            Text("📅").font(.system(size: 30))
            Text("날짜를 선택하세요")
                .font(.system(size: 14, weight: .bold))
            Text("달력에서 날짜를 클릭하면\n그날의 지출 기록이 여기에 표시됩니다.")
                .font(.system(size: 12)).foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.shadow, radius: 12, y: 2)
    }
}
