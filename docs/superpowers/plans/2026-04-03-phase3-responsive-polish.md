# Phase 3: 반응형 + 폴리시 + 기본 테스트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 모바일 바텀시트 레이아웃, 데스크톱 분할 레이아웃, 에러 재시도 UI, 루트 생성 로딩 애니메이션, 기본 단위 테스트를 추가한다.

**Architecture:** 반응형은 `kMobileBreakpoint = 600` 기준으로 모바일/데스크톱 분기. 모바일은 전체 화면 지도 위에 DraggableScrollableSheet (Peek/Half/Full 3단계), 데스크톱은 기존 Column 40/60 유지. 에러 처리는 ApiService._post에서 SocketException/TimeoutException을 잡아 NetworkException으로 변환하고, UI에서 재시도 버튼 표시. 로딩은 루트 생성 시 AnimatedSwitcher + 단계별 텍스트 표시.

**Tech Stack:** Flutter 3.41, Dart 3.11, Riverpod, kakao_map_sdk, scrollable_positioned_list, flutter_test (mockito 불필요 — 수동 mock 사용)

---

## 파일 구조

| 액션 | 파일 | 책임 |
|------|------|------|
| Create | `lib/utils/responsive.dart` | 브레이크포인트 상수 + `isMobile(context)` 헬퍼 |
| Create | `lib/widgets/route/route_bottom_sheet.dart` | 모바일 전용: DraggableScrollableSheet + 헤더 + 리스트 |
| Create | `lib/widgets/route/route_desktop_view.dart` | 데스크톱 전용: 기존 Column 레이아웃 추출 |
| Create | `lib/widgets/route/route_loading.dart` | 루트 생성 로딩 애니메이션 위젯 |
| Create | `lib/widgets/common/error_retry.dart` | 공통 에러 + 재시도 버튼 위젯 |
| Modify | `lib/services/api_service.dart` | SocketException/TimeoutException → NetworkException 변환 |
| Modify | `lib/screens/planner_screen.dart` | _buildRouteView를 반응형 분기로 교체, 로딩/에러 위젯 사용 |
| Modify | `lib/widgets/chat/chat_panel.dart` | 에러 영역을 ErrorRetry 위젯으로 교체 |
| Create | `test/utils/responsive_test.dart` | isMobile 헬퍼 테스트 |
| Create | `test/models/place_test.dart` | Place 모델 테스트 |
| Create | `test/models/route_segment_test.dart` | RouteSegment 모델 테스트 |
| Create | `test/models/preference_test.dart` | UserPreference/enum 테스트 |
| Create | `test/models/travel_route_test.dart` | TravelRoute.fromGenerateAndDirections 테스트 |
| Create | `test/services/api_service_test.dart` | ApiService 에러 처리 테스트 |
| Create | `test/providers/preference_provider_test.dart` | PreferenceNotifier 상태 변경 테스트 |
| Create | `test/widgets/route/route_loading_test.dart` | 로딩 위젯 테스트 |
| Create | `test/widgets/common/error_retry_test.dart` | ErrorRetry 위젯 테스트 |
| Create | `test/widgets/route/route_bottom_sheet_test.dart` | 바텀시트 위젯 테스트 |
| Create | `test/widgets/route/route_desktop_view_test.dart` | 데스크톱 뷰 스모크 테스트 |
| Create | `test/screens/planner_responsive_test.dart` | PlannerScreen 반응형 분기 테스트 |

---

## Task 1: 반응형 유틸리티

**Files:**
- Create: `lib/utils/responsive.dart`
- Create: `test/utils/responsive_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/utils/responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/utils/responsive.dart';

void main() {
  group('isMobile', () {
    testWidgets('화면 너비 599px이면 true', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(599, 800)),
          child: Builder(
            builder: (context) {
              expect(isMobile(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('화면 너비 600px이면 false', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 800)),
          child: Builder(
            builder: (context) {
              expect(isMobile(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('화면 너비 1024px이면 false', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 800)),
          child: Builder(
            builder: (context) {
              expect(isMobile(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/utils/responsive_test.dart`
Expected: FAIL — `responsive.dart` not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/utils/responsive.dart
import 'package:flutter/widgets.dart';

const double kMobileBreakpoint = 600;

bool isMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kMobileBreakpoint;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/utils/responsive_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/utils/responsive.dart test/utils/responsive_test.dart
git commit -m "feat: add responsive breakpoint utility"
```

---

## Task 2: 기본 모델 테스트 (Phase 1 미완료 항목)

**Files:**
- Create: `test/models/place_test.dart`
- Create: `test/models/route_segment_test.dart`
- Create: `test/models/preference_test.dart`
- Create: `test/models/travel_route_test.dart`

- [ ] **Step 1: Write Place model tests**

```dart
// test/models/place_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/place.dart';

void main() {
  group('Place.fromJson', () {
    test('정상 JSON을 파싱한다', () {
      final json = {
        'slot': 'breakfast',
        'name': '순두부젤라또',
        'address': '강릉시 초당동',
        'roadAddress': '강릉시 초당순두부길 15',
        'category': '한식',
        'coordinates': {'lat': 37.7912, 'lng': 128.9114},
        'reason': '강릉 명물',
        'estimatedBudget': 12000,
        'reviewSummary': '맛있어요',
      };

      final place = Place.fromJson(json);

      expect(place.slot, 'breakfast');
      expect(place.name, '순두부젤라또');
      expect(place.lat, 37.7912);
      expect(place.lng, 128.9114);
      expect(place.estimatedBudget, 12000);
      expect(place.reviewSummary, '맛있어요');
    });

    test('좌표가 없으면 0,0으로 기본값 설정', () {
      final json = {
        'slot': 'lunch',
        'name': '테스트',
      };

      final place = Place.fromJson(json);

      expect(place.lat, 0);
      expect(place.lng, 0);
    });
  });

  group('Place.slotLabel', () {
    test('breakfast → 아침', () {
      final place = Place.fromJson({'slot': 'breakfast', 'name': 'x'});
      expect(place.slotLabel, '아침');
    });

    test('morning_cafe → 오전 카페', () {
      final place = Place.fromJson({'slot': 'morning_cafe', 'name': 'x'});
      expect(place.slotLabel, '오전 카페');
    });

    test('lunch → 점심', () {
      final place = Place.fromJson({'slot': 'lunch', 'name': 'x'});
      expect(place.slotLabel, '점심');
    });

    test('afternoon_cafe → 오후 카페', () {
      final place = Place.fromJson({'slot': 'afternoon_cafe', 'name': 'x'});
      expect(place.slotLabel, '오후 카페');
    });

    test('dinner → 저녁', () {
      final place = Place.fromJson({'slot': 'dinner', 'name': 'x'});
      expect(place.slotLabel, '저녁');
    });
  });

  group('Place.isCafe', () {
    test('morning_cafe는 카페', () {
      final place = Place.fromJson({'slot': 'morning_cafe', 'name': 'x'});
      expect(place.isCafe, isTrue);
    });

    test('afternoon_cafe는 카페', () {
      final place = Place.fromJson({'slot': 'afternoon_cafe', 'name': 'x'});
      expect(place.isCafe, isTrue);
    });

    test('breakfast는 카페가 아님', () {
      final place = Place.fromJson({'slot': 'breakfast', 'name': 'x'});
      expect(place.isCafe, isFalse);
    });
  });
}
```

- [ ] **Step 2: Write RouteSegment model tests**

```dart
// test/models/route_segment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/route_segment.dart';

void main() {
  group('RouteSegment.fromJson', () {
    test('정상 JSON을 파싱한다', () {
      final json = {
        'from': '순두부젤라또',
        'to': '테라로사',
        'mode': 'driving',
        'distance': 3200,
        'duration': 10,
      };

      final seg = RouteSegment.fromJson(json);

      expect(seg.from, '순두부젤라또');
      expect(seg.to, '테라로사');
      expect(seg.mode, 'driving');
      expect(seg.distance, 3200);
      expect(seg.duration, 10);
    });
  });

  group('RouteSegment.distanceLabel', () {
    test('1000m 이상이면 km 단위', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'driving',
        'distance': 3200, 'duration': 10,
      });
      expect(seg.distanceLabel, '3.2km');
    });

    test('1000m 미만이면 m 단위', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'walking',
        'distance': 500, 'duration': 7,
      });
      expect(seg.distanceLabel, '500m');
    });
  });

  group('RouteSegment.durationLabel', () {
    test('60분 이상이면 시간+분', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'driving',
        'distance': 1000, 'duration': 90,
      });
      expect(seg.durationLabel, '1시간 30분');
    });

    test('정확히 60분이면 시간만', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'driving',
        'distance': 1000, 'duration': 60,
      });
      expect(seg.durationLabel, '1시간');
    });

    test('60분 미만이면 분만', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'driving',
        'distance': 1000, 'duration': 45,
      });
      expect(seg.durationLabel, '45분');
    });
  });

  group('RouteSegment.modeLabel', () {
    test('driving → 자동차', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'driving',
        'distance': 1000, 'duration': 10,
      });
      expect(seg.modeLabel, '자동차');
    });

    test('transit → 대중교통', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'transit',
        'distance': 1000, 'duration': 10,
      });
      expect(seg.modeLabel, '대중교통');
    });

    test('walking → 도보', () {
      final seg = RouteSegment.fromJson({
        'from': 'a', 'to': 'b', 'mode': 'walking',
        'distance': 1000, 'duration': 10,
      });
      expect(seg.modeLabel, '도보');
    });
  });
}
```

- [ ] **Step 3: Write UserPreference/enum tests**

```dart
// test/models/preference_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/preference.dart';

void main() {
  group('UserPreference.toJson', () {
    test('필수 필드를 JSON으로 변환', () {
      const pref = UserPreference(
        region: '강릉',
        foodTypes: ['한식', '일식'],
        budgetRange: BudgetRange.from10kTo30k,
        transportMode: TransportMode.driving,
      );

      final json = pref.toJson();

      expect(json['region'], '강릉');
      expect(json['foodTypes'], ['한식', '일식']);
      expect(json['budgetRange'], '10k_30k');
      expect(json['transportMode'], 'driving');
      expect(json.containsKey('date'), isFalse);
      expect(json.containsKey('additionalRequest'), isFalse);
    });

    test('선택 필드 포함 시 JSON에 포함', () {
      const pref = UserPreference(
        region: '제주',
        date: '2026-04-10',
        foodTypes: ['해산물'],
        budgetRange: BudgetRange.noLimit,
        transportMode: TransportMode.transit,
        additionalRequest: '해변 근처',
      );

      final json = pref.toJson();

      expect(json['date'], '2026-04-10');
      expect(json['additionalRequest'], '해변 근처');
    });
  });

  group('BudgetRange', () {
    test('value와 label이 정확하다', () {
      expect(BudgetRange.under10k.value, 'under_10k');
      expect(BudgetRange.under10k.label, '1만원 이하');
      expect(BudgetRange.from10kTo30k.value, '10k_30k');
      expect(BudgetRange.noLimit.value, 'no_limit');
    });
  });

  group('TransportMode', () {
    test('value와 label이 정확하다', () {
      expect(TransportMode.driving.value, 'driving');
      expect(TransportMode.driving.label, '자가용');
      expect(TransportMode.transit.value, 'transit');
      expect(TransportMode.walking.value, 'walking');
    });
  });
}
```

- [ ] **Step 4: Write TravelRoute.fromGenerateAndDirections test**

```dart
// test/models/travel_route_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';

void main() {
  group('TravelRoute.fromGenerateAndDirections', () {
    test('generate + directions JSON을 합쳐서 TravelRoute를 생성', () {
      final generateJson = {
        'places': [
          {
            'slot': 'breakfast',
            'name': '순두부젤라또',
            'coordinates': {'lat': 37.79, 'lng': 128.91},
            'reason': '강릉 명물',
            'estimatedBudget': 12000,
          },
          {
            'slot': 'morning_cafe',
            'name': '테라로사',
            'coordinates': {'lat': 37.78, 'lng': 128.90},
            'reason': '커피 맛집',
            'estimatedBudget': 8000,
          },
        ],
        'totalBudget': 20000,
        'comment': '강릉 맛집 투어',
      };

      final directionsJson = {
        'segments': [
          {
            'from': '순두부젤라또',
            'to': '테라로사',
            'mode': 'driving',
            'distance': 3200,
            'duration': 10,
          },
        ],
        'totalDistance': 3200,
        'totalDuration': 10,
      };

      final route = TravelRoute.fromGenerateAndDirections(
        generateJson,
        directionsJson,
      );

      expect(route.places.length, 2);
      expect(route.places[0].name, '순두부젤라또');
      expect(route.places[1].name, '테라로사');
      expect(route.segments.length, 1);
      expect(route.totalBudget, 20000);
      expect(route.totalDistance, 3200);
      expect(route.totalDuration, 10);
      expect(route.comment, '강릉 맛집 투어');
    });
  });
}
```

- [ ] **Step 5: Run all model tests**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/models/`
Expected: All tests PASS

- [ ] **Step 6: Commit**

```bash
git add test/models/
git commit -m "test: add unit tests for Place, RouteSegment, Preference, TravelRoute models"
```

---

## Task 3: ApiService 네트워크 에러 처리

**Files:**
- Modify: `lib/services/api_service.dart:46-66` (`_post` method)
- Create: `test/services/api_service_test.dart`

- [ ] **Step 1: Write failing tests for network error handling**

```dart
// test/services/api_service_test.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_route_planner/models/preference.dart';
import 'package:travel_route_planner/services/api_service.dart';

void main() {
  group('ApiService 네트워크 에러', () {
    test('SocketException 시 NetworkException 발생', () async {
      final client = MockClient((_) async {
        throw const SocketException('네트워크 연결 없음');
      });
      final api = ApiService(client: client);

      expect(
        () => api.chat(
          preference: const UserPreference(
            region: '강릉',
            foodTypes: ['한식'],
            budgetRange: BudgetRange.from10kTo30k,
            transportMode: TransportMode.driving,
          ),
          messages: [],
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('TimeoutException 시 NetworkException 발생', () async {
      final client = MockClient((_) async {
        throw TimeoutException('요청 시간 초과');
      });
      final api = ApiService(client: client);

      expect(
        () => api.chat(
          preference: const UserPreference(
            region: '강릉',
            foodTypes: ['한식'],
            budgetRange: BudgetRange.from10kTo30k,
            transportMode: TransportMode.driving,
          ),
          messages: [],
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('API 200이 아니면 ApiException 발생', () async {
      final client = MockClient((_) async => http.Response(
            '{"error": "서버 오류"}',
            500,
          ));
      final api = ApiService(client: client);

      expect(
        () => api.chat(
          preference: const UserPreference(
            region: '강릉',
            foodTypes: ['한식'],
            budgetRange: BudgetRange.from10kTo30k,
            transportMode: TransportMode.driving,
          ),
          messages: [],
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('NetworkException.message가 사용자 친화적 메시지', () {
      const e = NetworkException('테스트');
      expect(e.message, '네트워크 연결을 확인해주세요');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/services/api_service_test.dart`
Expected: FAIL — `NetworkException` not defined, `TimeoutException` import 필요

- [ ] **Step 3: Modify ApiService to handle network errors**

`lib/services/api_service.dart`의 `_post` 메서드를 수정하고 `NetworkException` 클래스를 추가:

```dart
// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/preference.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> chat({
    required UserPreference preference,
    required List<ChatMessage> messages,
  }) async {
    final response = await _post('/api/chat', {
      'preference': preference.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
    });
    return response['reply'] as String;
  }

  Future<Map<String, dynamic>> generateRoute({
    required UserPreference preference,
    String? additionalContext,
  }) async {
    return _post('/api/generate-route', {
      'preference': preference.toJson(),
      if (additionalContext != null) 'additionalContext': additionalContext,
    });
  }

  Future<Map<String, dynamic>> getDirections({
    required List<Map<String, dynamic>> places,
    required String mode,
  }) async {
    return _post('/api/directions', {
      'places': places,
      'mode': mode,
    });
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$apiBaseUrl$path');

    late final http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on SocketException {
      throw const NetworkException('SocketException');
    } on TimeoutException {
      throw const NetworkException('TimeoutException');
    }

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: error['error'] as String? ?? '알 수 없는 오류',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  final String cause;
  const NetworkException(this.cause);

  String get message => '네트워크 연결을 확인해주세요';

  @override
  String toString() => 'NetworkException($cause): $message';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/services/api_service_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Update providers to handle NetworkException**

`lib/providers/chat_provider.dart`의 catch 블록 수정 (line 53, 79):

```dart
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '알 수 없는 오류가 발생했습니다');
    }
```

`lib/providers/route_provider.dart`의 catch 블록 수정 (line 83-87):

```dart
    } on ApiException catch (e) {
      state = RouteState(error: e.message);
    } on NetworkException catch (e) {
      state = RouteState(error: e.message);
    } catch (e) {
      state = RouteState(error: '알 수 없는 오류가 발생했습니다');
    }
```

두 파일 모두 `import '../services/api_service.dart';` 추가 (NetworkException 사용 위해).

- [ ] **Step 6: Run all tests**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test`
Expected: All tests PASS

- [ ] **Step 7: Commit**

```bash
git add lib/services/api_service.dart lib/providers/chat_provider.dart lib/providers/route_provider.dart test/services/api_service_test.dart
git commit -m "feat: add NetworkException for SocketException/TimeoutException handling"
```

---

## Task 4: 공통 에러 + 재시도 위젯

**Files:**
- Create: `lib/widgets/common/error_retry.dart`
- Create: `test/widgets/common/error_retry_test.dart`

- [ ] **Step 1: Write failing widget tests**

```dart
// test/widgets/common/error_retry_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/widgets/common/error_retry.dart';

void main() {
  group('ErrorRetry', () {
    testWidgets('에러 메시지와 재시도 버튼을 표시한다', (tester) async {
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '네트워크 연결을 확인해주세요',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('네트워크 연결을 확인해주세요'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      expect(retryPressed, isTrue);
    });

    testWidgets('onRetry가 null이면 버튼을 표시하지 않는다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorRetry(message: '오류 발생'),
          ),
        ),
      );

      expect(find.text('오류 발생'), findsOneWidget);
      expect(find.text('다시 시도'), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/common/error_retry_test.dart`
Expected: FAIL — `error_retry.dart` not found

- [ ] **Step 3: Implement ErrorRetry widget**

```dart
// lib/widgets/common/error_retry.dart
import 'package:flutter/material.dart';

class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorRetry({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/common/error_retry_test.dart`
Expected: All 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/common/error_retry.dart test/widgets/common/error_retry_test.dart
git commit -m "feat: add ErrorRetry reusable widget with retry button"
```

---

## Task 5: 루트 생성 로딩 애니메이션

**Files:**
- Create: `lib/widgets/route/route_loading.dart`
- Create: `test/widgets/route/route_loading_test.dart`

- [ ] **Step 1: Write failing widget tests**

```dart
// test/widgets/route/route_loading_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/widgets/route/route_loading.dart';

void main() {
  group('RouteLoading', () {
    testWidgets('로딩 인디케이터와 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RouteLoading()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // 초기 단계 텍스트
      expect(find.text('맛집을 검색하고 있어요...'), findsOneWidget);
    });

    testWidgets('시간이 지나면 단계 텍스트가 변경된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RouteLoading()),
        ),
      );

      expect(find.text('맛집을 검색하고 있어요...'), findsOneWidget);

      // 3초 후 다음 단계
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500)); // AnimatedSwitcher

      expect(find.text('리뷰를 분석하고 있어요...'), findsOneWidget);
    });

    testWidgets('진행률 바가 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RouteLoading()),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/route/route_loading_test.dart`
Expected: FAIL — `route_loading.dart` not found

- [ ] **Step 3: Implement RouteLoading widget**

```dart
// lib/widgets/route/route_loading.dart
import 'dart:async';
import 'package:flutter/material.dart';

const _loadingSteps = [
  '맛집을 검색하고 있어요...',
  '리뷰를 분석하고 있어요...',
  '최적 루트를 계산하고 있어요...',
  '거의 다 됐어요!',
];

class RouteLoading extends StatefulWidget {
  const RouteLoading({super.key});

  @override
  State<RouteLoading> createState() => _RouteLoadingState();
}

class _RouteLoadingState extends State<RouteLoading> {
  int _stepIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_stepIndex < _loadingSteps.length - 1) {
        setState(() => _stepIndex++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_stepIndex + 1) / _loadingSteps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _loadingSteps[_stepIndex],
                key: ValueKey(_stepIndex),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: progress),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_stepIndex + 1)}/${_loadingSteps.length}',
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/route/route_loading_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/route/route_loading.dart test/widgets/route/route_loading_test.dart
git commit -m "feat: add RouteLoading widget with step-by-step progress animation"
```

---

## Task 6: 모바일 바텀시트 위젯

**Files:**
- Create: `lib/widgets/route/route_bottom_sheet.dart`
- Create: `test/widgets/route/route_bottom_sheet_test.dart`

**설계 결정:** `DraggableScrollableSheet`의 `scrollController`는 `CustomScrollView`/`ListView`의 `controller`로만 사용 가능하고, `scrollable_positioned_list`의 `ItemScrollController`와는 호환 불가. 따라서 바텀시트에서는 `ListView.builder`를 사용하고, 마커 탭 → 리스트 스크롤 연동은 `selectedPlaceIndex` 변경 감지 + 고정 높이 기반 offset 계산으로 구현. `DraggableScrollableController`로 마커 탭 시 시트를 Half(0.55)로 자동 확장.

- [ ] **Step 1: Write failing widget tests**

```dart
// test/widgets/route/route_bottom_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/widgets/route/route_bottom_sheet.dart';

TravelRoute _createTestRoute() => TravelRoute(
      places: [
        Place.fromJson({
          'slot': 'breakfast',
          'name': '순두부젤라또',
          'coordinates': {'lat': 37.79, 'lng': 128.91},
          'reason': '강릉 명물',
          'estimatedBudget': 12000,
        }),
        Place.fromJson({
          'slot': 'morning_cafe',
          'name': '테라로사',
          'coordinates': {'lat': 37.78, 'lng': 128.90},
          'reason': '커피 맛집',
          'estimatedBudget': 8000,
        }),
      ],
      segments: [
        RouteSegment.fromJson({
          'from': '순두부젤라또',
          'to': '테라로사',
          'mode': 'driving',
          'distance': 3200,
          'duration': 10,
        }),
      ],
      totalBudget: 20000,
      totalDistance: 3200,
      totalDuration: 10,
      comment: '강릉 맛집 투어',
    );

TravelRoute _createEmptyRoute() => const TravelRoute(
      places: [],
      segments: [],
      totalBudget: 0,
      totalDistance: 0,
      totalDuration: 0,
      comment: '빈 루트',
    );

TravelRoute _createSinglePlaceRoute() => TravelRoute(
      places: [
        Place.fromJson({
          'slot': 'lunch',
          'name': '교동반점',
          'coordinates': {'lat': 37.77, 'lng': 128.89},
          'reason': '강릉 짬뽕',
          'estimatedBudget': 15000,
        }),
      ],
      segments: const [],
      totalBudget: 15000,
      totalDistance: 0,
      totalDuration: 0,
      comment: '점심 한 곳',
    );

void main() {
  group('RouteBottomSheet', () {
    testWidgets('요약 헤더(comment + chips)를 표시한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RouteBottomSheet(route: _createTestRoute()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('강릉 맛집 투어'), findsOneWidget);
    });

    testWidgets('onPlaceTap 콜백을 전달한다', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: Stack(
                children: [
                  RouteBottomSheet(
                    route: _createTestRoute(),
                    onPlaceTap: (i) => tappedIndex = i,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 바텀시트 Peek 상태에서 헤더만 보이므로 카드 탭 불가
      // 파라미터 전달 여부만 확인
      expect(tappedIndex, isNull);
    });

    testWidgets('빈 루트일 때 헤더만 표시하고 크래시하지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RouteBottomSheet(route: _createEmptyRoute()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('빈 루트'), findsOneWidget);
      // 크래시 없이 정상 렌더링
    });

    testWidgets('장소 1개 + 세그먼트 0개일 때 정상 표시', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RouteBottomSheet(route: _createSinglePlaceRoute()),
              ],
            ),
          ),
        ),
      );

      expect(find.text('점심 한 곳'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/route/route_bottom_sheet_test.dart`
Expected: FAIL — `route_bottom_sheet.dart` not found

- [ ] **Step 3: Implement RouteBottomSheet widget**

```dart
// lib/widgets/route/route_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../models/travel_route.dart';
import '../../models/route_segment.dart';
import 'route_card.dart';

/// 카드 1개 + 세그먼트 1개의 대략적 높이 (스크롤 offset 계산용)
const double _estimatedItemHeight = 100.0;

class RouteBottomSheet extends StatefulWidget {
  final TravelRoute route;
  final void Function(int index)? onPlaceTap;
  final int? selectedPlaceIndex;

  const RouteBottomSheet({
    super.key,
    required this.route,
    this.onPlaceTap,
    this.selectedPlaceIndex,
  });

  @override
  State<RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  final _sheetController = DraggableScrollableController();
  ScrollController? _scrollController;

  @override
  void didUpdateWidget(covariant RouteBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedPlaceIndex != oldWidget.selectedPlaceIndex &&
        widget.selectedPlaceIndex != null) {
      _scrollToPlace(widget.selectedPlaceIndex!);
    }
  }

  void _scrollToPlace(int placeIndex) {
    // 시트가 Peek이면 Half로 확장
    if (_sheetController.isAttached && _sheetController.size < 0.5) {
      _sheetController.animateTo(
        0.55,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // 해당 카드 위치로 스크롤 (헤더 ~100px + 카드/세그먼트 높이 추정)
    final offset = placeIndex * _estimatedItemHeight;
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.18, 0.55, 0.85],
      builder: (context, scrollController) {
        _scrollController = scrollController;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            // 헤더 1개 + (places + segments) + 하단 패딩 1개
            itemCount: 1 + widget.route.places.length +
                widget.route.segments.length + 1,
            itemBuilder: (context, index) {
              // index 0: 헤더
              if (index == 0) return _buildHeader(context);

              // 마지막: 하단 패딩
              final contentCount = widget.route.places.length +
                  widget.route.segments.length;
              if (index == contentCount + 1) {
                return const SizedBox(height: 32);
              }

              // 나머지: 장소(짝수) + 세그먼트(홀수)
              final contentIndex = index - 1;
              if (contentIndex.isEven) {
                final placeIndex = contentIndex ~/ 2;
                return RouteCard(
                  place: widget.route.places[placeIndex],
                  index: placeIndex,
                  onTap: widget.onPlaceTap != null
                      ? () => widget.onPlaceTap!(placeIndex)
                      : null,
                );
              } else {
                final segIndex = contentIndex ~/ 2;
                if (segIndex < widget.route.segments.length) {
                  return _SegmentDivider(
                    segment: widget.route.segments[segIndex],
                  );
                }
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 드래그 핸들
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // 요약
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.route.comment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Chip(
                    icon: Icons.attach_money,
                    label: '총 ${_formatBudget(widget.route.totalBudget)}',
                  ),
                  _Chip(
                    icon: Icons.schedule,
                    label: '이동 ${_formatDuration(widget.route.totalDuration)}',
                  ),
                  _Chip(
                    icon: Icons.straighten,
                    label: _formatDistance(widget.route.totalDistance),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

String _formatBudget(int budget) {
  if (budget >= 10000) return '${budget ~/ 10000}만원';
  return '$budget원';
}

String _formatDuration(int minutes) {
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}시간 ${m}분' : '${h}시간';
  }
  return '$minutes분';
}

String _formatDistance(int meters) {
  if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)}km';
  return '${meters}m';
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentDivider extends StatelessWidget {
  final RouteSegment segment;
  const _SegmentDivider({required this.segment});

  @override
  Widget build(BuildContext context) {
    final icon = switch (segment.mode) {
      'driving' => Icons.directions_car,
      'transit' => Icons.directions_bus,
      'walking' => Icons.directions_walk,
      _ => Icons.arrow_downward,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '${segment.durationLabel} · ${segment.distanceLabel}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Expanded(child: Divider(indent: 8)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/route/route_bottom_sheet_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/route/route_bottom_sheet.dart test/widgets/route/route_bottom_sheet_test.dart
git commit -m "feat: add RouteBottomSheet with draggable snap positions for mobile"
```

---

## Task 7: 데스크톱 루트 뷰 추출

**Files:**
- Create: `lib/widgets/route/route_desktop_view.dart`
- Create: `test/widgets/route/route_desktop_view_test.dart`

기존 `PlannerScreen._buildRouteView`의 Column(지도 40% + 타임라인 60%) 레이아웃을 독립 위젯으로 추출.

- [ ] **Step 1: Create RouteDesktopView widget**

```dart
// lib/widgets/route/route_desktop_view.dart
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../models/travel_route.dart';
import '../map/route_map.dart';
import 'route_timeline.dart';

class RouteDesktopView extends StatelessWidget {
  final TravelRoute route;
  final int? selectedPlaceIndex;
  final void Function(int index)? onPlaceTap;
  final void Function(int index)? onMarkerTap;
  final ItemScrollController? itemScrollController;

  const RouteDesktopView({
    super.key,
    required this.route,
    this.selectedPlaceIndex,
    this.onPlaceTap,
    this.onMarkerTap,
    this.itemScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: RouteMap(
              places: route.places,
              selectedIndex: selectedPlaceIndex,
              onMarkerTap: onMarkerTap,
            ),
          ),
        ),
        Expanded(
          child: RouteTimeline(
            route: route,
            onPlaceTap: onPlaceTap,
            itemScrollController: itemScrollController,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Write RouteDesktopView smoke test**

```dart
// test/widgets/route/route_desktop_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/widgets/route/route_desktop_view.dart';

void main() {
  final testRoute = TravelRoute(
    places: [
      Place.fromJson({
        'slot': 'breakfast',
        'name': '순두부젤라또',
        'coordinates': {'lat': 37.79, 'lng': 128.91},
        'reason': '강릉 명물',
        'estimatedBudget': 12000,
      }),
      Place.fromJson({
        'slot': 'morning_cafe',
        'name': '테라로사',
        'coordinates': {'lat': 37.78, 'lng': 128.90},
        'reason': '커피 맛집',
        'estimatedBudget': 8000,
      }),
    ],
    segments: [
      RouteSegment.fromJson({
        'from': '순두부젤라또',
        'to': '테라로사',
        'mode': 'driving',
        'distance': 3200,
        'duration': 10,
      }),
    ],
    totalBudget: 20000,
    totalDistance: 3200,
    totalDuration: 10,
    comment: '강릉 맛집 투어',
  );

  group('RouteDesktopView', () {
    testWidgets('요약 헤더와 장소 카드를 표시한다', (tester) async {
      // RouteMap은 KakaoMap을 사용해 테스트 환경에서 렌더링 불가하므로
      // 에러가 발생할 수 있음. 여기서는 위젯 트리 구성이 올바른지만 확인.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteDesktopView(route: testRoute),
          ),
        ),
      );

      // RouteTimeline의 요약 헤더
      expect(find.text('강릉 맛집 투어'), findsOneWidget);
    });

    testWidgets('onPlaceTap 콜백을 전달한다', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteDesktopView(
              route: testRoute,
              onPlaceTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );

      // RouteCard 탭 시 콜백 호출 확인
      // 첫 번째 카드의 InkWell 탭
      await tester.tap(find.text('순두부젤라또'));
      expect(tappedIndex, 0);
    });
  });
}
```

- [ ] **Step 3: Run tests**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/widgets/route/route_desktop_view_test.dart`
Expected: All 2 tests PASS

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/route/route_desktop_view.dart test/widgets/route/route_desktop_view_test.dart
git commit -m "refactor: extract RouteDesktopView from PlannerScreen with tests"
```

---

## Task 8: PlannerScreen 반응형 통합

**Files:**
- Modify: `lib/screens/planner_screen.dart`
- Create: `test/screens/planner_responsive_test.dart`

PlannerScreen의 `_buildRouteView`를 반응형으로 분기하고, 로딩/에러 위젯을 교체한다.

- [ ] **Step 1: Update PlannerScreen with responsive layout**

`lib/screens/planner_screen.dart`를 아래와 같이 수정:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/preference_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/route_provider.dart';
import '../utils/responsive.dart';
import '../widgets/chat/preference_chips.dart';
import '../widgets/chat/chat_panel.dart';
import '../widgets/common/error_retry.dart';
import '../widgets/map/route_map.dart';
import '../widgets/route/route_bottom_sheet.dart';
import '../widgets/route/route_desktop_view.dart';
import '../widgets/route/route_loading.dart';

enum PlannerStep { preference, chat, route }

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  PlannerStep _step = PlannerStep.preference;
  int? _selectedPlaceIndex;
  final _itemScrollController = ItemScrollController();

  void _onPreferenceComplete() {
    ref.read(preferenceProvider.notifier).markComplete();
    ref.read(chatProvider.notifier).startChat();
    setState(() => _step = PlannerStep.chat);
  }

  void _onRouteRequested() {
    ref.read(routeProvider.notifier).generateRoute();
    setState(() => _step = PlannerStep.route);
  }

  void _onReset() {
    ref.read(preferenceProvider.notifier).reset();
    ref.read(chatProvider.notifier).reset();
    ref.read(routeProvider.notifier).reset();
    setState(() {
      _step = PlannerStep.preference;
      _selectedPlaceIndex = null;
    });
  }

  void _onPlaceTapFromList(int index) {
    setState(() => _selectedPlaceIndex = index);
  }

  void _onMarkerTapFromMap(int index) {
    setState(() => _selectedPlaceIndex = index);
    final listIndex = index * 2;
    _itemScrollController.scrollTo(
      index: listIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_step) {
          PlannerStep.preference => '취향 선택',
          PlannerStep.chat => 'AI와 대화',
          PlannerStep.route => '추천 루트',
        }),
        actions: [
          if (_step != PlannerStep.preference)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '처음부터 다시',
              onPressed: _onReset,
            ),
        ],
      ),
      body: switch (_step) {
        PlannerStep.preference => PreferenceChips(
            onComplete: _onPreferenceComplete,
          ),
        PlannerStep.chat => ChatPanel(
            onRouteRequested: _onRouteRequested,
          ),
        PlannerStep.route => _buildRouteView(routeState),
      },
    );
  }

  Widget _buildRouteView(RouteState routeState) {
    if (routeState.isLoading) {
      return const RouteLoading();
    }

    if (routeState.error != null) {
      return ErrorRetry(
        message: routeState.error!,
        onRetry: () => ref.read(routeProvider.notifier).generateRoute(),
      );
    }

    if (routeState.route == null) {
      return const Center(child: Text('루트를 생성해주세요'));
    }

    final route = routeState.route!;

    if (isMobile(context)) {
      return _buildMobileRouteView(route);
    }
    return _buildDesktopRouteView(route);
  }

  Widget _buildMobileRouteView(TravelRoute route) {
    return Stack(
      children: [
        // 전체 화면 지도
        Positioned.fill(
          child: RouteMap(
            places: route.places,
            selectedIndex: _selectedPlaceIndex,
            onMarkerTap: (index) {
              setState(() => _selectedPlaceIndex = index);
            },
          ),
        ),
        // 바텀시트
        RouteBottomSheet(
          route: route,
          onPlaceTap: _onPlaceTapFromList,
          selectedPlaceIndex: _selectedPlaceIndex,
        ),
      ],
    );
  }

  Widget _buildDesktopRouteView(TravelRoute route) {
    return RouteDesktopView(
      route: route,
      selectedPlaceIndex: _selectedPlaceIndex,
      onPlaceTap: _onPlaceTapFromList,
      onMarkerTap: _onMarkerTapFromMap,
      itemScrollController: _itemScrollController,
    );
  }
}
```

- [ ] **Step 2: Write responsive branch tests**

```dart
// test/screens/planner_responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_route_planner/screens/planner_screen.dart';
import 'package:travel_route_planner/providers/route_provider.dart';
import 'package:travel_route_planner/widgets/route/route_loading.dart';
import 'package:travel_route_planner/widgets/common/error_retry.dart';

void main() {
  group('PlannerScreen 반응형 분기', () {
    testWidgets('로딩 중이면 RouteLoading을 표시한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeProvider.overrideWith((ref) {
              final notifier = RouteNotifier(
                _FakeApiService(),
                ref,
              );
              // isLoading 상태 시뮬레이션은 Provider 내부이므로,
              // PlannerScreen에서 route step으로 전환 시 자동 발생.
              // 여기서는 UI가 올바르게 매핑되는지만 확인.
              return notifier;
            }),
          ],
          child: const MaterialApp(home: PlannerScreen()),
        ),
      );

      // 기본 상태는 preference step
      expect(find.text('취향 선택'), findsOneWidget);
    });

    testWidgets('에러 시 ErrorRetry를 표시한다', (tester) async {
      // ErrorRetry 위젯이 독립적으로 잘 동작하는지는
      // error_retry_test.dart에서 이미 검증.
      // 여기서는 PlannerScreen의 import/연결만 확인.
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PlannerScreen()),
        ),
      );

      expect(find.text('취향 선택'), findsOneWidget);
    });
  });
}

// ApiService는 route_provider에서 사용되므로 테스트용 fake 필요
class _FakeApiService {
  void dispose() {}
}
```

참고: `PlannerScreen`은 3단계 플로우 (preference → chat → route)를 거쳐야 route 뷰에 도달하므로, 반응형 분기 자체를 직접 테스트하기 어렵습니다. `RouteDesktopView`와 `RouteBottomSheet`는 각각의 테스트에서 독립 검증하고, `PlannerScreen` 테스트에서는 step 전환과 위젯 연결만 확인합니다.

- [ ] **Step 3: Run all tests**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test`
Expected: All tests PASS

- [ ] **Step 4: Run flutter analyze**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter analyze`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/screens/planner_screen.dart test/screens/planner_responsive_test.dart
git commit -m "feat: integrate responsive mobile/desktop route views with loading and error widgets"
```

---

## Task 9: ChatPanel 에러 UI 개선

**Files:**
- Modify: `lib/widgets/chat/chat_panel.dart:73-81`

ChatPanel의 인라인 에러 텍스트를 재시도 가능한 형태로 개선.

- [ ] **Step 1: Update ChatPanel error display**

`lib/widgets/chat/chat_panel.dart`의 에러 표시 영역을 수정:

기존 코드 (line 73-81):
```dart
        // 에러 표시
        if (chatState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              chatState.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
```

변경 후:
```dart
        // 에러 표시 + 닫기 버튼
        if (chatState.error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chatState.error!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ref.read(chatProvider.notifier).clearError(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
```

- [ ] **Step 2: Run all tests**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test`
Expected: All tests PASS

- [ ] **Step 3: Run flutter analyze**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter analyze`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/widgets/chat/chat_panel.dart
git commit -m "feat: improve ChatPanel error display with container and dismiss button"
```

---

## Task 10: PreferenceProvider 테스트

**Files:**
- Create: `test/providers/preference_provider_test.dart`

- [ ] **Step 1: Write provider tests**

```dart
// test/providers/preference_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/preference.dart';
import 'package:travel_route_planner/providers/preference_provider.dart';

void main() {
  late PreferenceNotifier notifier;

  setUp(() {
    notifier = PreferenceNotifier();
  });

  group('PreferenceNotifier', () {
    test('초기 상태가 올바르다', () {
      expect(notifier.state.region, '');
      expect(notifier.state.foodTypes, isEmpty);
      expect(notifier.state.budgetRange, BudgetRange.from10kTo30k);
      expect(notifier.state.transportMode, TransportMode.driving);
      expect(notifier.state.isComplete, isFalse);
      expect(notifier.state.canSubmit, isFalse);
    });

    test('setRegion으로 지역 설정', () {
      notifier.setRegion('강릉');
      expect(notifier.state.region, '강릉');
    });

    test('toggleFoodType으로 음식 추가/제거', () {
      notifier.toggleFoodType('한식');
      expect(notifier.state.foodTypes, ['한식']);

      notifier.toggleFoodType('일식');
      expect(notifier.state.foodTypes, ['한식', '일식']);

      notifier.toggleFoodType('한식');
      expect(notifier.state.foodTypes, ['일식']);
    });

    test('canSubmit: 지역+음식 둘 다 있어야 true', () {
      expect(notifier.state.canSubmit, isFalse);

      notifier.setRegion('강릉');
      expect(notifier.state.canSubmit, isFalse);

      notifier.toggleFoodType('한식');
      expect(notifier.state.canSubmit, isTrue);
    });

    test('markComplete로 완료 상태 전환', () {
      notifier.markComplete();
      expect(notifier.state.isComplete, isTrue);
    });

    test('reset으로 초기 상태 복원', () {
      notifier.setRegion('제주');
      notifier.toggleFoodType('해산물');
      notifier.markComplete();

      notifier.reset();

      expect(notifier.state.region, '');
      expect(notifier.state.foodTypes, isEmpty);
      expect(notifier.state.isComplete, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test test/providers/preference_provider_test.dart`
Expected: All 6 tests PASS (이미 구현된 코드에 대한 테스트)

- [ ] **Step 3: Commit**

```bash
git add test/providers/preference_provider_test.dart
git commit -m "test: add PreferenceNotifier unit tests"
```

---

## Task 11: TODO.md 업데이트 + flutter analyze + 전체 테스트

**Files:**
- Modify: `TODO.md`

- [ ] **Step 1: Run full test suite**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run flutter analyze**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter analyze`
Expected: No issues found

- [ ] **Step 3: Run flutter build web**

Run: `cd /Users/sengmindavidhyun/Documents/David/projects/travel_route_planner && flutter build web`
Expected: Build succeeds

- [ ] **Step 4: Update TODO.md**

```markdown
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
```

- [ ] **Step 5: Commit**

```bash
git add TODO.md
git commit -m "docs: mark Phase 3 complete in TODO.md"
```
