import Foundation

// MARK: - 날짜

/// Date → "yyyy-MM-dd" 키 문자열
func dateKey(_ d: Date) -> String {
    let c = Calendar.current.dateComponents([.year, .month, .day], from: d)
    return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
}

/// (year, month) → "yyyy-MM" 키 문자열
func monthKey(_ year: Int, _ month: Int) -> String {
    String(format: "%04d-%02d", year, month)
}

/// "yyyy-MM-dd" → Date
func dateFromKey(_ key: String) -> Date? {
    let p = key.split(separator: "-").compactMap { Int($0) }
    guard p.count == 3 else { return nil }
    return Calendar.current.date(from: DateComponents(year: p[0], month: p[1], day: p[2]))
}

/// "yyyy-MM-dd" → "M/d" (예: "2026-07-02" → "7/2")
func shortDate(_ key: String) -> String {
    let p = key.split(separator: "-").compactMap { Int($0) }
    guard p.count == 3 else { return key }
    return "\(p[1])/\(p[2])"
}

// MARK: - 금액 표시
//
// 금액은 항상 1원 단위 정수로 보관하고, 표시·입력 변환에 반올림을 하지 않는다.
// (반올림하면 기록을 수정할 때 금액이 조금씩 달라진다)

/// 정수 금액 → "1,234원"
func wonFmt(_ n: Int) -> String { commaNum(n) + "원" }

/// 천 단위 쉼표
private func commaNum(_ n: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return f.string(from: NSNumber(value: n)) ?? "\(n)"
}

/// 금액을 만원 단위로 표시한다. 보기 좋게 소수점 둘째 자리까지만 표시하며,
/// 저장되는 값은 언제나 1원 단위 정수 그대로다(표시용 반올림이 값에 영향을 주지 않는다).
/// 예) 200000→"20만원", 15000→"1.5만원", 52251→"5.23만원", 8180→"8,180원", 1→"1원"
func shortWon(_ n: Int) -> String {
    if n == 0 { return "0원" }
    let a = abs(n)
    // 1만원 미만은 만원으로 쓰면 "0.01만원"처럼 되므로 원 단위로 그대로 표시
    let body = a >= 10_000 ? manRounded2(a) + "만원" : commaNum(a) + "원"
    return (n < 0 ? "-" : "") + body
}

/// 표시 전용: 원 금액을 만원 단위 소수점 둘째 자리까지로 반올림한 문자열
/// (정수 연산으로 계산하며 뒤따르는 0은 제거한다)
private func manRounded2(_ a: Int) -> String {
    let hundredths = (a + 50) / 100          // 만원의 1/100 단위로 반올림
    var s = String(hundredths / 100)
    let frac = hundredths % 100
    if frac > 0 {
        var f = String(format: "%02d", frac)
        while f.hasSuffix("0") { f.removeLast() }
        s += "." + f
    }
    return s
}

// MARK: - 금액 입력 변환 (만원 단위)

/// 금액(원) → 만원 단위 입력 문자열. 정확한 값을 그대로 되돌려준다.
/// 예) 200000→"20", 15000→"1.5", 8180→"0.818", 1→"0.0001"
func manString(_ n: Int) -> String {
    if n == 0 { return "" }
    let a = abs(n)
    var s = String(a / 10_000)
    let frac = a % 10_000
    if frac > 0 {
        var f = String(format: "%04d", frac)
        while f.hasSuffix("0") { f.removeLast() }
        s += "." + f
    }
    return (n < 0 ? "-" : "") + s
}

/// 입력 문자열을 금액(원)으로 변환한다. 기본 단위는 만원.
/// 예) "1.5"→15000, "20"→200000, "0.818"→8180, "0.0001"→1,
///     "8180원"→8180 (원 단위 직접 입력), "2만"→20000
/// 부동소수 오차 없이 정수 연산으로 계산하며, 1원 미만은 버린다.
func parseManInput(_ raw: String) -> Int? {
    var s = raw.replacingOccurrences(of: ",", with: "")
               .replacingOccurrences(of: " ", with: "")
    if s.isEmpty { return nil }

    // "…원"으로 끝나면 원 단위 그대로 (단 "만원"은 만원 단위)
    if s.hasSuffix("원") && !s.hasSuffix("만원") {
        s.removeLast()
        return s.isEmpty ? nil : Int(s)
    }
    s = s.replacingOccurrences(of: "만원", with: "")
         .replacingOccurrences(of: "만", with: "")
    return manToWon(s)
}

/// "1.2345" 형태의 만원 값을 원 단위 정수로 정확히 변환
private func manToWon(_ raw: String) -> Int? {
    let neg = raw.hasPrefix("-")
    let body = neg ? String(raw.dropFirst()) : raw
    if body.isEmpty { return nil }

    let parts = body.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count <= 2 else { return nil }

    let wholeText = parts[0].isEmpty ? "0" : String(parts[0])
    guard wholeText.allSatisfy(\.isNumber), let whole = Int(wholeText) else { return nil }
    var won = whole * 10_000

    if parts.count == 2 {
        var frac = String(parts[1])
        guard frac.allSatisfy(\.isNumber) else { return nil }
        if frac.isEmpty { frac = "0" }
        if frac.count > 4 { frac = String(frac.prefix(4)) }   // 1원 미만은 버림
        while frac.count < 4 { frac += "0" }
        guard let f = Int(frac) else { return nil }
        won += f
    }
    return neg ? -won : won
}
