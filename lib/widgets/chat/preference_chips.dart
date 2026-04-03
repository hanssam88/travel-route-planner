import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/preference.dart';
import '../../providers/preference_provider.dart';
import '../../utils/constants.dart';

class PreferenceChips extends ConsumerWidget {
  final VoidCallback onComplete;

  const PreferenceChips({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(preferenceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 선택
          _SectionTitle('어디로 여행 가시나요?'),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return popularRegions;
              return popularRegions.where(
                (r) => r.contains(textEditingValue.text),
              );
            },
            onSelected: (value) =>
                ref.read(preferenceProvider.notifier).setRegion(value),
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              if (pref.region.isNotEmpty && controller.text.isEmpty) {
                controller.text = pref.region;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: '지역명 입력 (예: 강릉, 제주)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (v) =>
                    ref.read(preferenceProvider.notifier).setRegion(v),
                onSubmitted: (_) => onSubmitted(),
              );
            },
          ),

          const SizedBox(height: 24),

          // 음식 취향
          _SectionTitle('어떤 음식을 좋아하시나요? (복수 선택)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: foodCategories.map((type) {
              final selected = pref.foodTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) =>
                    ref.read(preferenceProvider.notifier).toggleFoodType(type),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 예산
          _SectionTitle('1인당 식사 예산은?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BudgetRange.values.map((range) {
              final selected = pref.budgetRange == range;
              return ChoiceChip(
                label: Text(range.label),
                selected: selected,
                onSelected: (_) =>
                    ref.read(preferenceProvider.notifier).setBudgetRange(range),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 이동수단
          _SectionTitle('이동수단은?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransportMode.values.map((mode) {
              final selected = pref.transportMode == mode;
              return ChoiceChip(
                label: Text(mode.label),
                selected: selected,
                onSelected: (_) => ref
                    .read(preferenceProvider.notifier)
                    .setTransportMode(mode),
                avatar: Icon(
                  switch (mode) {
                    TransportMode.driving => Icons.directions_car,
                    TransportMode.transit => Icons.directions_bus,
                    TransportMode.walking => Icons.directions_walk,
                  },
                  size: 18,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 시작 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: pref.canSubmit ? onComplete : null,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('루트 추천 받기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      );
}
