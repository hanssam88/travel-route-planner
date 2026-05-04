import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/preference.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class ApiService {
  // 빌드 시 --dart-define=API_KEY=... 로 주입
  static const _apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// AI 대화 — 취향 수집 + 후속 질문
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

  /// 루트 생성 — 장소 검색 + AI 선별 + 최적화
  Future<Map<String, dynamic>> generateRoute({
    required UserPreference preference,
    String? additionalContext,
  }) async {
    return _post('/api/generate-route', {
      'preference': preference.toJson(),
      if (additionalContext != null) 'additionalContext': additionalContext,
    });
  }

  /// 경로 계산 — 구간별 이동 시간/거리
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
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw const NetworkException('SocketException');
    } on TimeoutException {
      throw const NetworkException('TimeoutException');
    }

    if (response.statusCode != 200) {
      String message = '오류 (${response.statusCode})';
      try {
        final error = jsonDecode(response.body);
        message = error['error'] as String? ?? message;
      } catch (_) {
        message = 'HTTP ${response.statusCode}';
      }
      throw ApiException(statusCode: response.statusCode, message: message);
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
