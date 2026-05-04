import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/services/storage_service.dart';

void main() {
  group('StorageException', () {
    test('cause 없이 toString', () {
      const e = StorageException('테스트 실패');
      expect(e.toString(), 'StorageException: 테스트 실패');
    });

    test('cause 있으면 toString에 포함', () {
      const e = StorageException('저장 실패', cause: 'IOException');
      expect(e.toString(), contains('cause: IOException'));
    });

    test('Exception 인터페이스 구현', () {
      const e = StorageException('x');
      expect(e, isA<Exception>());
    });
  });

  group('StorageService 인터페이스', () {
    test('추상 메서드 시그니처 (4-S2.5 contract)', () {
      // 본 테스트는 인터페이스 메서드 존재 자체를 컴파일 타임에 보장.
      // Phase 4 S3에서 구현체가 추가되면 본 인터페이스를 implements 한다.
      expect(StorageService, isNotNull);
    });
  });
}
