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
