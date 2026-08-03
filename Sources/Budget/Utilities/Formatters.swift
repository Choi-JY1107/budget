import Foundation

/// Date → "yyyy-MM-dd" 키 문자열
func dateKey(_ d: Date) -> String {
    let c = Calendar.current.dateComponents([.year, .month, .day], from: d)
    return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
}

/// (year, month) → "yyyy-MM" 키 문자열
func monthKey(_ year: Int, _ month: Int) -> String {
    String(format: "%04d-%02d", year, month)
}

/// "yyyy-MM-dd" → "M/d" (예: "2026-07-02" → "7/2")
func shortDate(_ key: String) -> String {
    let p = key.split(separator: "-").compactMap { Int($0) }
    guard p.count == 3 else { return key }
    return "\(p[1])/\(p[2])"
}

/// 정수 금액 → "1,234원" 형식
func wonFmt(_ n: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return (f.string(from: NSNumber(value: n)) ?? "\(n)") + "원"
}

/// 금액을 만원 단위 축약으로 표시한다.
/// 예) 15000→"1.5만원", 200000→"20만원", 3000→"3천원", 500→"500원", 12345→"1.23만원"
func shortWon(_ n: Int) -> String {
    if n == 0 { return "0원" }
    let neg = n < 0
    let a = abs(n)
    let body: String
    if a >= 10_000 {
        body = trimNum(Double(a) / 10_000) + "만원"
    } else if a >= 1_000 {
        body = trimNum(Double(a) / 1_000) + "천원"
    } else {
        body = "\(a)원"
    }
    return neg ? "-" + body : body
}

/// 소수점 아래 최대 2자리, 뒤따르는 0은 제거 (1.5 → "1.5", 20.0 → "20", 1.23 → "1.23")
private func trimNum(_ x: Double) -> String {
    let r = (x * 100).rounded() / 100
    if r == r.rounded() { return String(Int(r)) }
    var s = String(format: "%.2f", r)
    while s.hasSuffix("0") { s.removeLast() }
    if s.hasSuffix(".") { s.removeLast() }
    return s
}

/// 만원 단위로 입력한 값을 금액(원)으로 해석한다.
/// 예) "1.5"→15000, "20"→200000, "0.3"→3000, "1.5만"→15000
func parseManInput(_ raw: String) -> Int? {
    let s = raw.replacingOccurrences(of: ",", with: "")
               .replacingOccurrences(of: " ", with: "")
               .replacingOccurrences(of: "만원", with: "")
               .replacingOccurrences(of: "만", with: "")
               .replacingOccurrences(of: "원", with: "")
    if s.isEmpty { return nil }
    guard let v = Double(s) else { return nil }
    return Int((v * 10_000).rounded())
}

/// 금액(원)을 만원 단위 입력 문자열로 변환 (예: 15000 → "1.5", 200000 → "20")
func manString(_ n: Int) -> String {
    n == 0 ? "" : trimNum(Double(n) / 10_000)
}

/// 축약 입력을 금액(정수)으로 해석한다.
/// 예) "15000"→15000, "1.5만"→15000, "20만"→200000, "3천"→3000,
///     "만"→10000, "1억"→100000000, "3만5000"→35000, "1,234"→1234
/// 해석 불가하면 nil.
func parseAmount(_ raw: String) -> Int? {
    var s = raw.replacingOccurrences(of: ",", with: "")
               .replacingOccurrences(of: " ", with: "")
               .replacingOccurrences(of: "원", with: "")
    if s.isEmpty { return nil }

    // 단위 없는 순수 숫자
    if let n = Int(s) { return n }

    // 억 → 만 → 천 순서로 누적
    let units: [(String, Double)] = [("억", 100_000_000), ("만", 10_000), ("천", 1_000)]
    var total = 0.0
    var matched = false
    for (u, mult) in units {
        guard let range = s.range(of: u) else { continue }
        let numPart = String(s[s.startIndex..<range.lowerBound])
        let value = numPart.isEmpty ? 1.0 : Double(numPart)
        guard let v = value else { return nil }
        total += v * mult
        matched = true
        s = String(s[range.upperBound...])   // 단위 뒤 나머지
    }

    // 단위 뒤에 남은 숫자 (예: "3만5000"의 "5000")
    if !s.isEmpty {
        guard let n = Double(s) else { return nil }
        total += n
    }

    guard matched else { return Double(raw).map { Int($0.rounded()) } }
    return Int(total.rounded())
}
