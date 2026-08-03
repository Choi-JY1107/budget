import SwiftUI

/// 태그별 이번 달 현황. 헤더를 클릭하면 펼쳐진다(기본 접힘).
/// 목표는 태그 전체가 아니라 세부 항목별로 설정한다.
/// "지정 변환"을 켜면 지출을 선택해 태그·세부 항목을 한 번에 바꿀 수 있다.
struct TagSummaryView: View {
    var store: BudgetStore
    let theme: Theme
    let year: Int
    let month: Int

    @State private var expanded = false
    @State private var selecting = false
    @State private var selectedIDs: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            if expanded {
                ForEach(TAG_GROUPS) { g in
                    TagBudgetRow(store: store, theme: theme, group: g, year: year, month: month,
                                 selecting: selecting, selectedIDs: $selectedIDs)
                        .id("\(year)-\(month)-\(g.name)")
                }
                // 맨 아래: 이름 일괄 변경
                Divider()
                renameToggle
                if selecting {
                    ConvertBar(store: store, theme: theme,
                               selectedIDs: $selectedIDs, selecting: $selecting)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.shadow, radius: 12, y: 2)
    }

    private var header: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() }
        } label: {
            HStack {
                Text("🏷️ 태그별 현황").font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(month)월").font(.system(size: 11)).foregroundColor(.secondary)
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// 맨 아래에 놓이는 "이름 일괄 변경" 토글 버튼
    private var renameToggle: some View {
        Button {
            selecting.toggle()
            if !selecting { selectedIDs.removeAll() }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: selecting ? "xmark.circle" : "square.and.pencil")
                    .font(.system(size: 10, weight: .bold))
                Text(selecting ? "선택 취소" : "이름 일괄 변경")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(selecting ? .primary : theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(selecting ? Color.primary.opacity(0.07) : theme.accent.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

/// 선택한 지출들의 이름(내용)을 한 번에 바꾸는 변환 바
struct ConvertBar: View {
    var store: BudgetStore
    let theme: Theme
    @Binding var selectedIDs: Set<UUID>
    @Binding var selecting: Bool

    @State private var newName = ""

    private var canApply: Bool {
        !selectedIDs.isEmpty && !newName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(selectedIDs.count)건 선택")
                    .font(.system(size: 11, weight: .bold)).foregroundColor(theme.accent)
                Spacer()
                if !selectedIDs.isEmpty {
                    Button("선택 해제") { selectedIDs.removeAll() }
                        .buttonStyle(.plain)
                        .font(.system(size: 10)).foregroundColor(.secondary)
                }
            }
            Text("아래 목록에서 지출을 골라 이름을 한 번에 바꿉니다.")
                .font(.system(size: 10)).foregroundColor(.secondary)

            TextField("새 이름 (예: 메가커피 아아)", text: $newName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 12))
                .onSubmit { if canApply { apply() } }

            Button(action: apply) {
                Text(buttonLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(canApply ? theme.accent : Color.secondary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(!canApply)
        }
        .padding(12)
        .background(theme.accent.opacity(0.06))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.accent.opacity(0.35), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var buttonLabel: String {
        if selectedIDs.isEmpty { return "지출을 선택하세요" }
        if newName.trimmingCharacters(in: .whitespaces).isEmpty { return "새 이름을 입력하세요" }
        return "\(selectedIDs.count)건 이름 변경"
    }

    private func apply() {
        store.bulkRename(ids: selectedIDs,
                         desc: newName.trimmingCharacters(in: .whitespaces))
        selectedIDs.removeAll()
        newName = ""
        selecting = false
    }
}

/// 태그(대분류) 한 그룹: 그룹 합계 진행 바 + 세부 항목별 목표 입력
struct TagBudgetRow: View {
    var store: BudgetStore
    let theme: Theme
    let group: TagGroup
    let year: Int
    let month: Int
    let selecting: Bool
    @Binding var selectedIDs: Set<UUID>

    @State private var expanded = false

    private var spent: Int { store.spent(year: year, month: month, tag: group.name) }
    private var target: Int { store.groupTarget(year: year, month: month, tag: group.name) }
    private var ratio: Double { target > 0 ? min(Double(spent) / Double(target), 1) : 0 }
    private var over: Bool { target > 0 && spent > target }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 그룹 헤더 (합계) — 클릭하면 세부 항목 펼침/접힘
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .bold)).foregroundColor(.secondary)
                        .frame(width: 9)
                    RoundedRectangle(cornerRadius: 4).fill(group.color).frame(width: 12, height: 12)
                    Text(group.name).font(.system(size: 13, weight: .bold)).foregroundColor(.primary)
                    Spacer()
                    Text(shortWon(spent))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(over ? theme.warning : .primary)
                    if target > 0 {
                        Text("/ \(shortWon(target))").font(.system(size: 11)).foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.border).frame(height: 5)
                    Capsule().fill(over ? theme.warning : group.color)
                        .frame(width: max(5, geo.size.width * ratio), height: 5)
                }
            }
            .frame(height: 5)

            // 세부 항목별 목표
            if expanded {
                VStack(spacing: 6) {
                    ForEach(group.items, id: \.self) { sub in
                        SubBudgetRow(store: store, theme: theme,
                                     group: group, sub: sub, year: year, month: month,
                                     selecting: selecting, selectedIDs: $selectedIDs)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }
}

/// 세부 항목 한 줄: 이름 · 사용액 · 목표 입력 · 진행률 (+ 선택 모드에서 체크박스)
struct SubBudgetRow: View {
    var store: BudgetStore
    let theme: Theme
    let group: TagGroup
    let sub: String
    let year: Int
    let month: Int
    let selecting: Bool
    @Binding var selectedIDs: Set<UUID>

    @State private var targetText: String = ""
    @State private var expanded = false

    private var spent: Int { store.spent(year: year, month: month, tag: group.name, sub: sub) }
    private var target: Int { store.target(year: year, month: month, tag: group.name, sub: sub) }
    private var ratio: Double { target > 0 ? min(Double(spent) / Double(target), 1) : 0 }
    private var over: Bool { target > 0 && spent > target }
    private var items: [Record] { store.records(year: year, month: month, tag: group.name, sub: sub) }
    private var allSelected: Bool {
        !items.isEmpty && items.allSatisfy { selectedIDs.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                // 이름 + 사용액 → 클릭하면 내역 펼침
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: expanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 8, weight: .bold)).foregroundColor(.secondary)
                            .frame(width: 8)
                        Text(sub).font(.system(size: 12)).foregroundColor(.primary).lineLimit(1)
                        Text(shortWon(spent))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(over ? theme.warning : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 4)

                if selecting {
                    // 이 항목의 지출 전체 선택/해제
                    Button {
                        if allSelected { items.forEach { selectedIDs.remove($0.id) } }
                        else { items.forEach { selectedIDs.insert($0.id) } }
                    } label: {
                        Text(allSelected ? "해제" : "모두")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(items.isEmpty ? .secondary : theme.accent)
                    }
                    .buttonStyle(.plain)
                    .disabled(items.isEmpty)
                } else {
                    TextField("목표", text: $targetText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(width: 60)
                        .onSubmit(commit)
                    Text("만원").font(.system(size: 10)).foregroundColor(.secondary)
                }
            }
            if target > 0 && !selecting {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.border).frame(height: 3)
                        Capsule().fill(over ? theme.warning : group.color)
                            .frame(width: max(3, geo.size.width * ratio), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.leading, 2)
            }
            if expanded {
                VStack(spacing: 3) {
                    if sub == BRAND_SUB && !selecting { brandBreakdown }
                    if items.isEmpty {
                        HStack {
                            Text("아직 지출 없음").font(.system(size: 11)).foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        ForEach(items) { r in
                            recordRow(r)
                        }
                    }
                }
                .padding(.leading, 13)
                .padding(.top, 1)
            }
        }
        .onAppear { targetText = manString(target) }
    }

    /// 내역 한 줄 (선택 모드면 체크박스로 고를 수 있다)
    @ViewBuilder
    private func recordRow(_ r: Record) -> some View {
        let picked = selectedIDs.contains(r.id)
        let row = HStack(spacing: 6) {
            if selecting {
                Image(systemName: picked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 11))
                    .foregroundColor(picked ? theme.accent : .secondary)
            }
            Text(shortDate(r.dateKey))
                .font(.system(size: 10)).foregroundColor(.secondary)
                .frame(width: 28, alignment: .leading)
            if let b = brandFor(r.brand) { BrandIcon(brand: b, size: 14) }
            Text(r.desc.isEmpty ? "(내용 없음)" : r.desc)
                .font(.system(size: 11)).lineLimit(1)
            Spacer(minLength: 4)
            Text(shortWon(r.amount)).font(.system(size: 11, weight: .semibold))
        }

        if selecting {
            Button {
                if picked { selectedIDs.remove(r.id) } else { selectedIDs.insert(r.id) }
            } label: {
                row.padding(.vertical, 2).padding(.horizontal, 3)
                    .background(picked ? theme.accent.opacity(0.10) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            row
        }
    }

    /// 커피 항목일 때: 브랜드별 아이콘 + 사용액 요약
    @ViewBuilder
    private var brandBreakdown: some View {
        let totals = Dictionary(grouping: items.filter { $0.brand != nil }, by: { $0.brand! })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)
        LazyVGrid(columns: cols, spacing: 5) {
            ForEach(COFFEE_BRANDS) { b in
                let amt = totals[b.id] ?? 0
                HStack(spacing: 3) {
                    BrandIcon(brand: b, size: 15).opacity(amt > 0 ? 1 : 0.3)
                    Text(amt > 0 ? shortWon(amt) : "-")
                        .font(.system(size: 9, weight: amt > 0 ? .bold : .regular))
                        .foregroundColor(amt > 0 ? .primary : .secondary)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }
                .help(b.name)
            }
        }
        .padding(.bottom, 3)
    }

    private func commit() {
        let v = parseManInput(targetText) ?? 0
        store.setTarget(year: year, month: month, tag: group.name, sub: sub, amount: v)
        targetText = manString(v)
    }
}
