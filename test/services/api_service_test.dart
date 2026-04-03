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
      final client = MockClient(
        (_) async => http.Response(
          '{"error": "서버 오류"}',
          500,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );
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
