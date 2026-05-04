import '../models/travel_route.dart';

/// 로컬 영속 저장 서비스의 추상 인터페이스.
///
/// **결정 (Phase 4 S2.5, 2026-05-05)**:
/// - 백엔드: Hive (hive ^2.2.3, hive_flutter ^1.1.0)
///   - SharedPreferences는 spots 100+에서 전체 JSON read/write 부담 → Hive로 결정.
///   - Box별 분리로 lazy access. supabase_flutter 도입 시(Phase 8)도 client-side 캐시로 재사용.
/// - 직렬화: 모델의 toJson/fromJson만 사용. JSON 외 포맷 금지.
/// - 에러 정책: 모든 메서드는 실패 시 [StorageException] throw. 성공은 void/T 반환.
/// - 인덱스 갱신: saveX/deleteX 내부에서 본체 + 인덱스 동시 처리 (트랜잭션 시맨틱).
///
/// **Box 키 네임스페이스**:
/// - `routes` (key: routeId → TravelRoute JSON) — Phase 4 S3
/// - `trips` (key: tripId → Trip JSON) — Phase 5 S2
/// - `spots` (key: spotId → SavedSpot JSON) — Phase 5 S2
/// - `dayPlans` (key: dayPlanId → DayPlan JSON) — Phase 7
/// - `meta` (마이그레이션 마커 등) — Phase 8
///
/// **Phase 별 메서드 추가 일정** (본 인터페이스 확장 시):
/// - Phase 5 S2: saveTrip / loadTrip / listTrips / deleteTrip(cascade)
/// - Phase 5 S3: saveSpot / listSpotsByTrip / deleteSpot / bulkSaveSpots
/// - Phase 7: saveDayPlan / listDayPlansByTrip / deleteDayPlan / deleteDayPlansByTrip
abstract class StorageService {
  /// 초기화 (Hive.initFlutter + box open). 앱 시작 시 1회.
  Future<void> init();

  // ─── Phase 4 S3: 단일 TravelRoute 저장 ───────────────────────────

  /// 단일 루트를 [id] 키로 저장. 같은 id면 덮어쓴다.
  /// 인덱스(`index:routes`)도 함께 갱신.
  Future<void> saveRoute(TravelRoute route, {required String id});

  /// [id]에 해당하는 루트를 반환. 없으면 null.
  Future<TravelRoute?> loadRoute(String id);

  /// 저장된 루트 ID 전체 목록.
  Future<List<String>> listRouteIds();

  /// [id] 루트를 삭제. 인덱스도 함께 갱신. 없는 id면 무시.
  Future<void> deleteRoute(String id);

  // ─── 폐기 ────────────────────────────────────────────────────

  /// 모든 box close. 앱 종료 시.
  Future<void> dispose();
}

/// StorageService 작업 실패 예외.
class StorageException implements Exception {
  final String message;
  final Object? cause;

  const StorageException(this.message, {this.cause});

  @override
  String toString() {
    if (cause == null) return 'StorageException: $message';
    return 'StorageException: $message (cause: $cause)';
  }
}
