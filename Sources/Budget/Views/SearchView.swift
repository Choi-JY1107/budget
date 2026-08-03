import SwiftUI

/// 키워드로 지출을 검색하는 카드. 결과를 클릭하면 그 날짜가 선택된다.
struct SearchView: View {
    var store: BudgetStore
    let theme: Theme
    @Binding var selectedKey: String?

    @State private var query = ""

    private var results: [Record] { store.search(query) }
    private var total: Int { results.reduce(0) { $0 + $1.amount } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11)).foregroundColor(.secondary)
                TextField("지출 검색 (예: 커피, 식비, 마라탕)", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 11))
                    }
                    .buttonStyle(.plain).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 9))

            if !query.isEmpty {
                HStack {
                    Text("\(results.count)건").font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("합계 \(shortWon(total))")
                        .font(.system(size: 11, weight: .bold)).foregroundColor(theme.accent)
                }

                if results.isEmpty {
                    Text("검색 결과가 없어요.")
                        .font(.system(size: 12)).foregroundColor(.secondary)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                } else {
                    VStack(spacing: 0) {
                        ForEach(results) { r in
                            Button { selectedKey = r.dateKey } label: {
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(colorFor(tag: r.tag)).frame(width: 3, height: 26)
                                    Text(shortDate(r.dateKey))
                                        .font(.system(size: 10)).foregroundColor(.secondary)
                                        .frame(width: 30, alignment: .leading)
                                    if let b = brandFor(r.brand) { BrandIcon(brand: b, size: 14) }
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(r.desc.isEmpty ? "(내용 없음)" : r.desc)
                                            .font(.system(size: 12)).lineLimit(1)
                                        Text(r.sub).font(.system(size: 10)).foregroundColor(.secondary)
                                    }
                                    Spacer(minLength: 4)
                                    Text(shortWon(r.amount)).font(.system(size: 11, weight: .bold))
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.shadow, radius: 12, y: 2)
    }
}
