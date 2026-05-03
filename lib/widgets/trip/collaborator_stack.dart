import 'package:flutter/material.dart';
import '../../data/collaborator.dart';

class CollaboratorStack extends StatelessWidget {
  final List<Collaborator> collaborators;
  final double size;
  final bool showLiveLabel;

  const CollaboratorStack({
    super.key,
    required this.collaborators,
    this.size = 28,
    this.showLiveLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final visible = collaborators.take(3).toList();
    final extra = collaborators.length - visible.length;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size + (visible.length - 1) * (size * 0.7) + (extra > 0 ? size * 0.7 : 0),
          height: size,
          child: Stack(
            children: [
              for (int i = 0; i < visible.length; i++)
                Positioned(
                  left: i * size * 0.7,
                  child: _Avatar(c: visible[i], size: size),
                ),
              if (extra > 0)
                Positioned(
                  left: visible.length * size * 0.7,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+$extra',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (showLiveLabel) ...[
          const SizedBox(width: 8),
          _LivePulse(count: collaborators.where((c) => c.isOnline).length),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final Collaborator c;
  final double size;
  const _Avatar({required this.c, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: cs.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(c.emoji, style: TextStyle(fontSize: size * 0.55)),
    );
  }
}

class _LivePulse extends StatefulWidget {
  final int count;
  const _LivePulse({required this.count});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 16 + 8 * t,
                  height: 16 + 8 * t,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3FA86B).withValues(alpha: (1 - t) * 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF3FA86B), shape: BoxShape.circle),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
        Text('${widget.count}명 편집중', style: tt.labelSmall),
      ],
    );
  }
}
