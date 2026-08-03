import Foundation

/// 하나의 소비 기록
struct Record: Identifiable, Codable {
    var id = UUID()
    var dateKey: String   // "yyyy-MM-dd"
    var amount: Int
    var desc: String
    var tag: String       // 대분류 (예: "생활비")
    var sub: String       // 세부 항목 (예: "식비")
}
