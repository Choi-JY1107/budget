import SwiftUI

/// 태그 대분류와 그에 속한 세부 항목들
struct TagGroup: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let items: [String]
}

/// 앱 전체에서 사용하는 태그 정의
let TAG_GROUPS: [TagGroup] = [
    TagGroup(name: "고정 비용", color: Color(red: 1.0, green: 0.48, blue: 0.35),
             items: ["월세", "관리비", "교통비", "통신비", "보험료", "구독 서비스", "부모님 용돈"]),
    TagGroup(name: "비상금", color: Color(red: 1.0, green: 0.72, blue: 0.30),
             items: ["가족행사", "경조사비", "기타 지출"]),
    TagGroup(name: "저축", color: Color(red: 0.21, green: 0.79, blue: 0.55),
             items: ["적금", "대출이자", "주택청약", "증권계좌"]),
    TagGroup(name: "생활비", color: Color(red: 0.30, green: 0.44, blue: 1.0),
             items: ["식비", "커피", "생활비", "유흥", "뽑기", "약속"]),
    TagGroup(name: "기타", color: Color(red: 0.55, green: 0.57, blue: 0.64),
             items: ["출처 모름", "멍청 비용"]),
]

/// 태그 이름으로 대표 색상 조회
func colorFor(tag: String) -> Color {
    TAG_GROUPS.first { $0.name == tag }?.color ?? .gray
}
