import SwiftUI

/// 커피 전문점 브랜드. 기록의 `brand` 필드에 `id`가 저장된다.
struct CoffeeBrand: Identifiable {
    let id: String      // 저장용 키
    let name: String    // 표시 이름
    let short: String   // 아이콘에 넣을 짧은 글자
    let bg: Color       // 아이콘 배경색
    let fg: Color       // 아이콘 글자색
}

/// 지원하는 커피 브랜드 목록. 브랜드 고유 색을 참고한 자체 배지 아이콘을 쓴다.
let COFFEE_BRANDS: [CoffeeBrand] = [
    CoffeeBrand(id: "mega",     name: "메가커피",   short: "메",
                bg: Color(red: 1.00, green: 0.80, blue: 0.00), fg: .black),
    CoffeeBrand(id: "compose",  name: "컴포즈커피", short: "컴",
                bg: Color(red: 0.12, green: 0.12, blue: 0.13), fg: .white),
    CoffeeBrand(id: "paik",     name: "빽다방",     short: "빽",
                bg: Color(red: 0.04, green: 0.16, blue: 0.40), fg: Color(red: 1.0, green: 0.89, blue: 0.0)),
    CoffeeBrand(id: "mammoth",  name: "매머드커피", short: "매",
                bg: Color(red: 0.29, green: 0.17, blue: 0.10), fg: Color(red: 0.98, green: 0.94, blue: 0.86)),
    CoffeeBrand(id: "banapresso", name: "바나프레소", short: "바",
                bg: Color(red: 0.55, green: 0.76, blue: 0.29), fg: .black),
    CoffeeBrand(id: "baekeok",  name: "백억커피",   short: "백",
                bg: Color(red: 0.89, green: 0.23, blue: 0.23), fg: .white),
    CoffeeBrand(id: "starbucks", name: "스타벅스",  short: "스",
                bg: Color(red: 0.00, green: 0.44, blue: 0.29), fg: .white),
    CoffeeBrand(id: "etc",      name: "기타",       short: "?",
                bg: Color(red: 0.60, green: 0.63, blue: 0.69), fg: .white),
]

/// 브랜드 id로 조회
func brandFor(_ id: String?) -> CoffeeBrand? {
    guard let id else { return nil }
    return COFFEE_BRANDS.first { $0.id == id }
}

/// 브랜드 선택 UI를 노출할 세부 항목
let BRAND_SUB = "커피"
