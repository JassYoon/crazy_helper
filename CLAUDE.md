# 제정신 지킴이 (Crazy Helper) — 위젯 유틸리티 앱

## 목적

컴퓨터/모바일에서 위젯 형태로 사용할 수 있는 유틸리티 애플리케이션.
위젯을 클릭하면 메뉴 바가 나타나고, 사용자가 원하는 세부 기능들을 메뉴에 등록하여 빠르게 접근할 수 있는 구조.

## 핵심 컨셉

- **위젯 기반 UI**: 항상 화면에 떠 있는 56×56px 원형 위젯 → 클릭 시 메뉴 바 확장
- **모듈식 기능**: 각 기능은 독립된 모듈로 개발, 위젯 메뉴 관리 패널에서 등록/해제 가능
- **듀얼 모드**: Home 모드(420×680px, 모듈 브라우저) ↔ Widget 모드(플로팅 위젯)
- **크로스 플랫폼**: 데스크톱(Windows, macOS, Linux) + 모바일(Android, iOS) 지원

## 구현 완료 기능

### 1. 심호흡 타이머 (anti_a_timer)

- **호흡 모드**: 4-4-4 (박스 호흡), 4-7-8 (불안 해소) + 커스텀 호흡 주기 추가/재정렬/삭제
- **시각화**: 도넛 차트 애니메이션 (들이쉬기 파란/참기 보라/내쉬기 초록)
- **세션 관리**: 세트 수 설정 (1-20), 진행 상황 표시
- **휴식 알림**: N회 반복 후 휴식 모달 (토글 가능)
- **고정밀 타이밍**: Ticker 기반 delta 타이밍

### 2. 할 일 (todolist)

- **체크리스트**: 번호/내용/중요도(별 0-3)/완료 체크, 중요도 정렬, 일괄 완료
- **타임테이블**: 06시~05시 24칸, 시간대별 할 일 추가
- **콤보 박스**로 목록 유형 전환 (데이터 유지)
- **자동 리셋**: 날짜 변경 시 전체 미완료 처리
- SharedPreferences 영속 저장

## 기술 스택

- **프레임워크**: Flutter (Dart)
- **상태 관리**: ChangeNotifier + setState
- **데스크톱 창 제어**: window_manager
- **로컬 저장소**: SharedPreferences (JSON 직렬화)
- **폰트**: KoddiUD 온고딕 (assets/fonts/ 번들)
- **테마**: Material 3, 밝은 테마 (#8BC34A 기반 연녹색 계열)

## 프로젝트 구조

```
lib/
├── main.dart                  # 진입점, AppMode(home/widget) 분기
├── app.dart                   # MaterialApp 설정
├── core/
│   ├── theme.dart             # AppColors, appStyle(), AppFloatingChrome
│   ├── module_registry.dart   # 모듈 등록/해제 관리 (ChangeNotifier)
│   └── app_text_input.dart    # 공통 텍스트 입력 위젯
├── models/
│   └── app_module.dart        # AppModule 데이터 클래스, allModules 목록
├── screens/
│   └── home_screen.dart       # 홈 화면 (벤토 박스 그리드, 위젯 메뉴 관리)
├── widgets/
│   ├── floating_widget.dart   # 플로팅 위젯 화면 (드래그, 메뉴 토글)
│   ├── logo_widget.dart       # 커스텀 페인터 로고 (방패 + 새싹)
│   ├── menu_bar_widget.dart   # 메뉴 바 (등록된 모듈 아이콘 표시)
│   └── module_icon_widget.dart
└── features/
    ├── anti_a_timer/
    │   ├── models/
    │   │   └── breathing_mode.dart    # BreathingMode, BreathingPhase, BreathingModeStore
    │   ├── screens/
    │   │   ├── timer_screen.dart      # 타이머 메인 (Ticker 기반)
    │   │   └── info_screen.dart
    │   └── widgets/
    │       ├── timer_donut.dart       # 도넛 차트 커스텀 페인터
    │       ├── custom_breathing_dialog.dart
    │       ├── progress_bar.dart
    │       └── rest_modal.dart
    └── todolist/
        ├── models/
        │   ├── todo_item.dart         # TodoItem 데이터 클래스
        │   ├── todo_list_type.dart    # checklist / timetable enum
        │   └── todo_store.dart        # TodoStore (ChangeNotifier, 자동 리셋)
        ├── screens/
        │   └── todo_screen.dart
        └── widgets/
            ├── checklist_view.dart
            ├── timetable_view.dart
            ├── star_rating.dart
            └── todo_list_shortcut_icon.dart
```

## 개발 규칙

- 각 기능 모듈은 `lib/features/<기능명>/` 내에서 독립적으로 동작하며, 다른 모듈에 의존하지 않는다
- 새 기능 추가 절차: `features/` 디렉토리 생성 → `allModules` 목록에 등록 → `_openModuleById()`에 라우팅 추가
- 위젯 메뉴 바에 등록/해제가 런타임에 가능해야 한다
- 기능은 하나씩 순차적으로 개발·완성한다
- UI 색상은 AppColors 참조, 텍스트 스타일은 appStyle() 사용
