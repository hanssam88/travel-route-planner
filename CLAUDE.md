@AGENTS.md

# travel-route-planner (AI 여행 루트 플래너 Flutter 앱)

## 프로젝트 개요

AI가 사용자 취향을 분석하여 국내 맛집/카페 하루 루트를 추천해주는 Flutter 앱.
백엔드 API(travel-route-api)와 통신하여 동작한다.

- **위치**: `David/projects/travel_route_planner/`
- **기술 스택**: Flutter 3.41, Dart 3.11, Riverpod, go_router, flutter_naver_map, http
- **백엔드**: `David/projects/travel-route-api/` (Next.js 16, Vercel)
- **플랫폼**: Web (MVP), iOS/Android (추후)

## 화면 구성

| 경로 | 화면 | 설명 |
|------|------|------|
| `/` | HomeScreen | 랜딩 (시작 버튼) |
| `/plan` | PlannerScreen | 3단계 플로우: 취향 → AI 대화 → 루트 결과 |

## 상태 관리 (Riverpod)

| Provider | 역할 |
|----------|------|
| preferenceProvider | 지역/음식/예산/이동수단 취향 상태 |
| chatProvider | AI 대화 메시지 목록 + 로딩/에러 |
| routeProvider | 생성된 루트 (장소 + 경로) |
| apiServiceProvider | 백엔드 API 서비스 싱글톤 |

## 자기 검증

```bash
flutter analyze
flutter test
flutter build web
```

## 환경변수

`--dart-define=API_BASE_URL=https://your-api.vercel.app`으로 백엔드 URL 설정
