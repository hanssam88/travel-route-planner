# TODO — travel-route-planner (Flutter)

## Phase 1: 프로젝트 셋업
- [x] Flutter 프로젝트 생성
- [x] 의존성 추가 (Riverpod, go_router, http)
- [x] 모델 작성 (preference, place, route_segment, travel_route, chat_message)
- [x] API 서비스 작성
- [x] 프로바이더 작성 (preference, chat, route)
- [x] 화면 작성 (home, planner)
- [x] 위젯 작성 (preference_chips, chat_panel, route_timeline)
- [x] 라우팅 설정 (go_router)
- [x] 빌드 확인
- [x] 기본 테스트 작성

## Phase 2: 카카오 맵 통합
- [x] 의존성 변경 (flutter_naver_map → kakao_map_sdk)
- [x] web/index.html에 카카오 Maps JS SDK 추가
- [x] RouteMap 위젯 (카카오 맵 렌더링)
- [x] 장소 마커 표시 (번호 + 색상 구분)
- [x] 폴리라인 직선 연결
- [x] PlannerScreen route 단계 레이아웃 개편 (지도 40% + 리스트 60%)
- [x] 리스트-지도 인터랙션 (카드 탭 → 지도 이동, 마커 탭 → 리스트 스크롤)

## Phase 3: 반응형 + 폴리시
- [x] 모바일/웹 레이아웃 분기
- [x] 에러 처리 개선
- [x] 로딩 애니메이션

## Phase 4: 경유지 편집 + 실제 경로 + 로컬 저장 + iOS 빌드

### 사전 조건
- [ ] Flutter ↔ 배포된 백엔드 E2E 연동 테스트 (Phase 4 전 별도 세션)

### Session 1: 실제 경로 폴리라인
- [ ] `route_segment.dart` — `path` 필드 + `pathLatLngs` getter + `hasPath` + `toJson()`
- [ ] `route_map.dart` — segments 파라미터, 실제 경로 폴리라인 (파란색) / 직선 fallback (회색)
- [ ] `planner_screen.dart`, `route_desktop_view.dart` — segments 전달
- [ ] `constants.dart` — `polylineRealPathColor` 추가
- [ ] 테스트: `route_segment_test.dart` path 파싱/변환/hasPath

### Session 2: 경유지 편집
- [ ] `travel_route.dart` — `copyWith()`, `reorderPlaces()`, `removePlace()`
- [ ] `route_provider.dart` — 편집 모드, 재계산 디바운스 (1초), `/api/directions` 재호출
- [ ] 새 위젯 `editable_route_timeline.dart` — ReorderableListView + Dismissible
- [ ] `planner_screen.dart` — 편집 토글 버튼
- [ ] `route_map.dart` — 오버레이 cleanup + re-setup
- [ ] 테스트: route_provider, travel_route_reorder, editable_route_timeline

### Session 3: 로컬 저장
- [ ] 새 모델 `saved_route.dart`
- [ ] 기존 모델 `toJson()` 추가 (travel_route, place, route_segment)
- [ ] 새 서비스 `storage_service.dart` (SharedPreferences)
- [ ] 새 Provider `storage_provider.dart`
- [ ] `home_screen.dart` — 저장된 루트 섹션
- [ ] `planner_screen.dart` — 저장 버튼
- [ ] `pubspec.yaml` — `shared_preferences: ^2.3.0`
- [ ] 테스트: saved_route, storage_service, storage_provider

### Session 4: iOS 네이티브 빌드
- [ ] `kakao_map_sdk` iOS 지원 여부 pub.dev 확인 (필수 선행)
- [ ] `main.dart` — 플랫폼 조건부 Kakao SDK 초기화
- [ ] `ios/Runner/Info.plist` — Kakao SDK 필수 항목
- [ ] Kakao Developer Console — iOS 번들 ID 등록
- [ ] iOS 시뮬레이터 수동 테스트 (빌드, 지도, 마커, 폴리라인, 터치)
