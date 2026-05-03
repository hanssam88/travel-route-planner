import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/import_source.dart';
import '../data/saved_spot.dart';

class ImportResult {
  final List<SavedSpot> spots;
  final ImportSource source;
  const ImportResult({required this.spots, required this.source});
}

class ImportNotifier extends StateNotifier<AsyncValue<ImportResult?>> {
  ImportNotifier() : super(const AsyncValue.data(null));

  Future<ImportResult> simulate(ImportSource source, String input) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 1500));
    final spots = _mockResultsFor(source, input);
    final result = ImportResult(spots: spots, source: source);
    state = AsyncValue.data(result);
    return result;
  }

  void clear() => state = const AsyncValue.data(null);

  List<SavedSpot> _mockResultsFor(ImportSource source, String input) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    SavedSpot mk(int i, String name, String region, String emoji, String category, List<String> tags, int? wait, Congestion c, double lat, double lng) =>
        SavedSpot(
          id: 'imp_${ts}_$i',
          name: name,
          region: region,
          category: category,
          source: source,
          lat: lat,
          lng: lng,
          moodTags: tags,
          waitingMinutes: wait,
          congestion: c,
          emoji: emoji,
          note: '$source 임포트',
        );

    return switch (source) {
      ImportSource.instagram => [
          mk(0, '봄날의 책방', '강릉', '📚', '서점·카페', ['숨은맛집', '인스타감성'], 5, Congestion.low, 37.7720, 128.9460),
          mk(1, '몽토랑', '강릉', '🍝', '양식', ['데이트', '뷰맛집'], 20, Congestion.high, 37.7430, 128.8800),
        ],
      ImportSource.tiktok => [
          mk(0, '연화', '제주', '🥢', '한식', ['로컬추천'], 35, Congestion.high, 33.4900, 126.4980),
        ],
      ImportSource.naverBlog => [
          mk(0, '백반집 호남식당', '광주', '🍚', '한식', ['로컬추천', '가성비'], 0, Congestion.low, 35.1497, 126.9168),
          mk(1, '동명동 카페골목', '광주', '☕', '카페', ['데이트', '인스타감성'], 10, Congestion.mid, 35.1480, 126.9220),
        ],
      ImportSource.kakaoMap => [
          mk(0, '광안리 더베이101', '부산', '🍻', '바', ['늦은밤', '뷰맛집'], 25, Congestion.high, 35.1535, 129.1190),
        ],
      ImportSource.gallery => [
          mk(0, '한라산 윗세오름', '제주', '⛰️', '명소', ['가족', '뷰맛집'], null, Congestion.low, 33.3617, 126.5292),
          mk(1, '천제연폭포', '제주', '💦', '명소', ['가족', '인스타감성'], null, Congestion.mid, 33.2502, 126.4193),
          mk(2, '섭지코지', '제주', '🌅', '명소', ['데이트', '뷰맛집'], null, Congestion.mid, 33.4239, 126.9263),
        ],
      ImportSource.manual => [
          mk(0, input.isEmpty ? '새 장소' : input, '서울', '📍', '직접추가', const [], null, Congestion.low, 37.5665, 126.9780),
        ],
    };
  }
}

final importProvider =
    StateNotifierProvider<ImportNotifier, AsyncValue<ImportResult?>>(
  (ref) => ImportNotifier(),
);
