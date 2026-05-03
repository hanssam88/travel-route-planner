import 'package:flutter/material.dart';

class Collaborator {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final String? cursorSpotId;
  final bool isOnline;

  const Collaborator({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.cursorSpotId,
    this.isOnline = true,
  });

  Collaborator copyWith({String? cursorSpotId, bool? isOnline}) => Collaborator(
        id: id,
        name: name,
        emoji: emoji,
        color: color,
        cursorSpotId: cursorSpotId ?? this.cursorSpotId,
        isOnline: isOnline ?? this.isOnline,
      );
}
