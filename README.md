# 가계부 (Budget)

macOS용 네이티브 SwiftUI 가계부 앱. 달력에서 날짜별 소비를 기록하고, 태그별 월간 목표와 사용 현황을 한눈에 확인한다.

## 빌드 & 실행

```bash
./build.sh          # build/가계부.app 생성
open build/가계부.app # 실행
```

- `build/가계부.app` 을 **응용 프로그램 폴더나 Dock으로 드래그**하면 일반 앱처럼 쓸 수 있다.
- 첫 실행 시 Gatekeeper 경고가 뜨면 **우클릭 → 열기**를 한 번 해주면 이후엔 그냥 열린다.
- 요구 사항: macOS 14 이상, Swift 6 (Xcode 또는 Command Line Tools).

아이콘을 다시 만들려면:

```bash
swift tools/make_icon.swift                                  # build/AppIcon.iconset 생성
iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
```

## 기능

- 이번 달 달력 표시, 월 이동(‹ ›)과 "오늘" 버튼
- **날짜를 클릭해야** 그날 기록이 사이드바에 표시됨 → 소비 추가(금액·내용·태그·세부 항목)
- 사이드바의 "태그별 현황" 헤더를 **클릭하면 펼쳐짐**
- 목표는 **세부 항목별로** 설정 (예: 식비 20만 원, 유흥 10만 원) — 태그 합계는 자동 계산, 달마다 따로 저장
- 태그별/세부별 **사용 금액 / 목표 / 진행률** 표시, 목표 초과 시 빨간색 강조
- 시스템 / 라이트 / 다크 테마 선택
- 데이터는 `~/Library/Application Support/Budget/` 에 JSON으로 자동 저장

## 태그 구성

| 대분류 | 세부 항목 |
| --- | --- |
| 고정 비용 | 월세, 관리비, 교통비, 통신비, 보험료, 구독 서비스, 부모님 용돈 |
| 비상금 | 가족행사, 경조사비, 기타 지출 |
| 저축 | 적금, 대출이자, 주택청약, 증권계좌 |
| 생활비 | 식비, 생활비, 유흥, 약속 |

## 프로젝트 구조

SwiftUI에서 널리 쓰이는 **MVVM 계층 구조**를 따른다.

```
budget/
├── build.sh                     # swiftc로 .app 번들을 만드는 빌드 스크립트
├── README.md
├── Resources/
│   └── AppIcon.icns             # 앱 아이콘 (tools/make_icon.swift로 생성)
├── tools/
│   └── make_icon.swift          # 아이콘 렌더러(선택 실행): iconset PNG 생성
├── build/                       # 빌드 산출물 (가계부.app, AppIcon.iconset)
└── Sources/Budget/
    ├── App/
    │   └── BudgetApp.swift       # @main 진입점, 윈도우/테마 설정
    ├── Models/                   # 순수 데이터 모델
    │   ├── Record.swift          #   소비 기록
    │   └── Tag.swift             #   태그 대분류/세부 항목 정의
    ├── Stores/
    │   └── BudgetStore.swift     # @Observable 상태 저장소(기록·목표 + 영속화)
    ├── Theme/
    │   └── Theme.swift           # 라이트/다크 적응형 색상
    ├── Utilities/
    │   └── Formatters.swift      # 날짜 키·금액 포맷 헬퍼
    └── Views/
        ├── ContentView.swift     # 최상위 레이아웃
        ├── CalendarView.swift    # 달력(헤더 + 그리드)
        ├── DayCellView.swift     # 달력의 하루 칸
        ├── TagSummaryView.swift  # 태그별 현황 + 목표 입력
        ├── DetailPanelView.swift # 선택 날짜 상세 + 소비 추가 폼
        └── Components/
            ├── AppearancePicker.swift  # 테마 선택 세그먼트
            └── NavButtonStyle.swift    # 달력 이동 버튼 스타일
```

**계층 역할**
- **Models** — 저장·표시할 순수 데이터 구조 (`Codable`)
- **Stores** — `@Observable` 클래스가 앱 상태를 보유하고 디스크에 영속화 (MVVM의 ViewModel/Store 역할)
- **Views** — 상태를 표시하고 사용자 입력을 스토어로 전달
- **Theme / Utilities** — 뷰에서 공용으로 쓰는 색상·포맷 헬퍼
