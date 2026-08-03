import Foundation
import Observation

/// 앱의 모든 상태(기록 + 월별 세부 목표)를 보관하고 디스크에 저장하는 스토어.
/// 데이터는 ~/Library/Application Support/Budget/ 아래 JSON으로 저장된다.
@Observable
final class BudgetStore {
    private(set) var records: [Record] = []
    /// "yyyy-MM" → 태그(대분류) → 세부 항목 → 목표 금액
    private(set) var budgets: [String: [String: [String: Int]]] = [:]

    // MARK: 저장 위치

    private var dir: URL {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Budget", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }
    private var recordsURL: URL { dir.appendingPathComponent("records.json") }
    private var budgetsURL: URL { dir.appendingPathComponent("budgets.json") }

    init() { load() }

    private func load() {
        if let data = try? Data(contentsOf: recordsURL),
           let decoded = try? JSONDecoder().decode([Record].self, from: data) {
            records = decoded
        }
        if let data = try? Data(contentsOf: budgetsURL),
           let decoded = try? JSONDecoder().decode([String: [String: [String: Int]]].self, from: data) {
            budgets = decoded
        }
    }

    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) { try? data.write(to: recordsURL) }
    }
    private func saveBudgets() {
        if let data = try? JSONEncoder().encode(budgets) { try? data.write(to: budgetsURL) }
    }

    // MARK: 기록 (일 단위)

    func records(on key: String) -> [Record] {
        records.filter { $0.dateKey == key }
    }
    func total(on key: String) -> Int {
        records(on: key).reduce(0) { $0 + $1.amount }
    }
    func add(_ r: Record) { records.append(r); saveRecords() }
    func delete(_ r: Record) { records.removeAll { $0.id == r.id }; saveRecords() }
    func update(_ r: Record) {
        if let i = records.firstIndex(where: { $0.id == r.id }) { records[i] = r; saveRecords() }
    }

    // MARK: 월 단위 집계

    func monthTotal(year: Int, month: Int) -> Int {
        let p = monthKey(year, month)
        return records.filter { $0.dateKey.hasPrefix(p) }.reduce(0) { $0 + $1.amount }
    }

    /// 해당 월, 태그(대분류) 전체 지출
    func spent(year: Int, month: Int, tag: String) -> Int {
        let p = monthKey(year, month)
        return records
            .filter { $0.dateKey.hasPrefix(p) && $0.tag == tag }
            .reduce(0) { $0 + $1.amount }
    }

    /// 해당 월, 특정 세부 항목 지출
    func spent(year: Int, month: Int, tag: String, sub: String) -> Int {
        let p = monthKey(year, month)
        return records
            .filter { $0.dateKey.hasPrefix(p) && $0.tag == tag && $0.sub == sub }
            .reduce(0) { $0 + $1.amount }
    }

    /// 해당 월, 특정 세부 항목의 개별 내역 (날짜순)
    func records(year: Int, month: Int, tag: String, sub: String) -> [Record] {
        let p = monthKey(year, month)
        return records
            .filter { $0.dateKey.hasPrefix(p) && $0.tag == tag && $0.sub == sub }
            .sorted { $0.dateKey < $1.dateKey }
    }

    // MARK: 세부 항목별 월별 목표

    func target(year: Int, month: Int, tag: String, sub: String) -> Int {
        budgets[monthKey(year, month)]?[tag]?[sub] ?? 0
    }

    func setTarget(year: Int, month: Int, tag: String, sub: String, amount: Int) {
        let key = monthKey(year, month)
        var byTag = budgets[key] ?? [:]
        var bySub = byTag[tag] ?? [:]
        if amount <= 0 { bySub[sub] = nil } else { bySub[sub] = amount }
        byTag[tag] = bySub.isEmpty ? nil : bySub
        budgets[key] = byTag.isEmpty ? nil : byTag
        saveBudgets()
    }

    /// 해당 월, 태그(대분류)의 목표 합계 (세부 목표들의 합)
    func groupTarget(year: Int, month: Int, tag: String) -> Int {
        (budgets[monthKey(year, month)]?[tag] ?? [:]).values.reduce(0, +)
    }

    /// 해당 월 전체 목표 합계
    func monthTarget(year: Int, month: Int) -> Int {
        (budgets[monthKey(year, month)] ?? [:]).values.flatMap { $0.values }.reduce(0, +)
    }
}
