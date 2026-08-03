import SwiftUI

/// 선택한 날짜의 기록 목록 + 새 소비 추가 폼
struct DetailPanelView: View {
    var store: BudgetStore
    let theme: Theme
    let selectedKey: String

    @State private var amount = ""
    @State private var desc = ""
    @State private var selectedTag = TAG_GROUPS[0].name
    @State private var selectedSub = TAG_GROUPS[0].items[0]
    @State private var editingID: UUID? = nil   // nil이면 추가, 값이 있으면 수정 모드

    private var cal: Calendar { Calendar.current }

    private var subItems: [String] {
        TAG_GROUPS.first { $0.name == selectedTag }?.items ?? []
    }

    private var titleText: String {
        let parts = selectedKey.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3,
              let date = cal.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
        else { return selectedKey }
        let names = ["", "일", "월", "화", "수", "목", "금", "토"]
        return "\(parts[1])월 \(parts[2])일 (\(names[cal.component(.weekday, from: date)]))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleText).font(.system(size: 15, weight: .bold))
            Text("합계  ").foregroundColor(.secondary).font(.system(size: 12))
                + Text(shortWon(store.total(on: selectedKey))).font(.system(size: 15, weight: .bold))

            recordList
            addForm
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: theme.shadow, radius: 12, y: 2)
        .onChange(of: selectedKey) { _, _ in cancelEdit() }
    }

    // MARK: 기록 목록

    @ViewBuilder
    private var recordList: some View {
        let recs = store.records(on: selectedKey)
        if recs.isEmpty {
            Text("아직 기록이 없어요.\n아래에서 소비를 추가해보세요.")
                .font(.system(size: 13)).foregroundColor(.secondary)
                .frame(maxWidth: .infinity).multilineTextAlignment(.center)
                .padding(.vertical, 16)
        } else {
            VStack(spacing: 0) {
                ForEach(recs) { r in
                    HStack(alignment: .top, spacing: 10) {
                        RoundedRectangle(cornerRadius: 4).fill(colorFor(tag: r.tag)).frame(width: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.desc.isEmpty ? "(내용 없음)" : r.desc)
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(r.tag) · \(r.sub)").font(.system(size: 11)).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(shortWon(r.amount)).font(.system(size: 14, weight: .bold))
                        Button { startEdit(r) } label: {
                            Image(systemName: "pencil").font(.system(size: 11))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(editingID == r.id ? theme.accent : .secondary)
                        Button { deleteRecord(r) } label: {
                            Image(systemName: "xmark").font(.system(size: 11))
                        }
                        .buttonStyle(.plain).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 6)
                    .background(editingID == r.id ? theme.accent.opacity(0.08) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    Divider()
                }
            }
        }
    }

    // MARK: 추가 폼

    private var addForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            field("금액 (만원)") {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        TextField("예: 1.5, 20", text: $amount)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(submit)
                        Text("만원").font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    if let v = parseManInput(amount) {
                        Text("= \(shortWon(v))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(theme.accent)
                    }
                }
            }
            field("내용") {
                TextField("예: 점심 김밥", text: $desc).textFieldStyle(.roundedBorder)
            }
            HStack(spacing: 10) {
                field("태그") {
                    Picker("", selection: $selectedTag) {
                        ForEach(TAG_GROUPS) { g in Text(g.name).tag(g.name) }
                    }
                    .labelsHidden()
                    .onChange(of: selectedTag) { _, _ in
                        if !subItems.contains(selectedSub) { selectedSub = subItems.first ?? "" }
                    }
                }
                field("세부") {
                    Picker("", selection: $selectedSub) {
                        ForEach(subItems, id: \.self) { Text($0).tag($0) }
                    }
                    .labelsHidden()
                }
            }
            HStack(spacing: 8) {
                if editingID != nil {
                    Button(action: cancelEdit) {
                        Text("취소")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.primary)
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                Button(action: submit) {
                    Text(editingID == nil ? "+ 소비 추가" : "수정 완료")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }

    private func field<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            content()
        }
    }

    // MARK: 추가 / 수정 동작

    private func submit() { editingID == nil ? addRecord() : saveEdit() }

    private func addRecord() {
        guard let amt = parseManInput(amount), amt > 0 else { return }
        store.add(Record(dateKey: selectedKey, amount: amt,
                         desc: desc.trimmingCharacters(in: .whitespaces),
                         tag: selectedTag, sub: selectedSub))
        clearForm()
    }

    private func startEdit(_ r: Record) {
        editingID = r.id
        selectedTag = r.tag
        selectedSub = r.sub
        amount = manString(r.amount)
        desc = r.desc
    }

    private func saveEdit() {
        guard let id = editingID, let amt = parseManInput(amount), amt > 0 else { return }
        store.update(Record(id: id, dateKey: selectedKey, amount: amt,
                            desc: desc.trimmingCharacters(in: .whitespaces),
                            tag: selectedTag, sub: selectedSub))
        clearForm()
    }

    private func deleteRecord(_ r: Record) {
        if editingID == r.id { clearForm() }
        store.delete(r)
    }

    private func cancelEdit() { clearForm() }

    private func clearForm() {
        editingID = nil; amount = ""; desc = ""
    }
}
