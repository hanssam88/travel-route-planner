import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import 'api_provider.dart';
import 'preference_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _api;
  final PreferenceState Function() _getPreference;

  ChatNotifier(this._api, this._getPreference) : super(const ChatState());

  /// 취향 정보를 바탕으로 AI에게 첫 메시지 전송
  Future<void> startChat() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preference = _getPreference();
      final reply = await _api.chat(
        preference: preference.toPreference(),
        messages: [],
      );

      state = state.copyWith(
        messages: [
          ChatMessage(role: MessageRole.assistant, content: reply),
        ],
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '네트워크 오류가 발생했습니다');
    }
  }

  /// 사용자 메시지 전송 + AI 응답 수신
  Future<void> sendMessage(String content) async {
    final userMsg = ChatMessage(role: MessageRole.user, content: content);
    final updatedMessages = [...state.messages, userMsg];

    state = state.copyWith(messages: updatedMessages, isLoading: true, error: null);

    try {
      final preference = _getPreference();
      final reply = await _api.chat(
        preference: preference.toPreference(),
        messages: updatedMessages,
      );

      final aiMsg = ChatMessage(role: MessageRole.assistant, content: reply);
      state = state.copyWith(
        messages: [...updatedMessages, aiMsg],
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '네트워크 오류가 발생했습니다');
    }
  }

  void clearError() => state = state.copyWith(error: null);

  void reset() => state = const ChatState();
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final getPreference = () => ref.read(preferenceProvider);
  return ChatNotifier(api, getPreference);
});
