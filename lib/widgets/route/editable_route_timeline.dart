import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/place.dart';
import '../../providers/route_provider.dart';
import 'route_card.dart';

/// 편집 모드 타임라인 — ReorderableListView + Dismissible.
///
/// places만 표시한다 (편집 중에는 segments는 stale이므로 숨김).
/// 드래그 핸들로 순서 변경, 좌→우 swipe로 삭제 → route_provider 액션 호출.
/// 삭제 후 1초 디바운스로 자동 재계산.
class EditableRouteTimeline extends ConsumerWidget {
  final List<Place> places;

  const EditableRouteTimeline({super.key, required this.places});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeState = ref.watch(routeProvider);

    return Column(
      children: [
        if (routeState.isRecalculating)
          const LinearProgressIndicator(minHeight: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '편집 모드 — 길게 눌러 순서 변경, 좌→우 스와이프로 삭제',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: places.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(routeProvider.notifier).reorderPlaces(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final place = places[index];
              return Dismissible(
                // 좌표+slot+name 결합으로 reorder 시 안정적 key.
                // (Phase 4 S3에서 Place에 stable id 도입되면 그것으로 교체)
                key: ValueKey(
                  'place-${place.lat}-${place.lng}-${place.slot}-${place.name}',
                ),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (_) async {
                  if (places.length <= 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('장소가 너무 적어 삭제할 수 없습니다 (최소 2개)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return false;
                  }
                  return true;
                },
                onDismissed: (_) {
                  ref.read(routeProvider.notifier).removePlace(index);
                },
                child: RouteCard(place: place, index: index),
              );
            },
          ),
        ),
      ],
    );
  }
}
