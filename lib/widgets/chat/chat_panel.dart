import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import 'chat_message.dart';
import 'chat_input.dart';

class ChatPanel extends ConsumerStatefulWidget {
  final VoidCallback onRouteRequested;

  const ChatPanel({super.key, required this.onRouteRequested});

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        Expanded(
          child: chatState.messages.isEmpty
              ? const Center(
                  child: Text(
                    'AI가 취향을 분석하고 있습니다...',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) =>
                      ChatMessageWidget(message: chatState.messages[index]),
                ),
        ),

        // 로딩 표시
        if (chatState.isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),

        // 에러 표시
        if (chatState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              chatState.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

        // 루트 생성 버튼 (대화 2회 이상 후)
        if (chatState.messages.length >= 2 && !chatState.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: FilledButton.icon(
              onPressed: widget.onRouteRequested,
              icon: const Icon(Icons.map),
              label: const Text('이 취향으로 루트 생성'),
            ),
          ),

        ChatInput(
          enabled: !chatState.isLoading,
          onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
        ),
      ],
    );
  }
}
