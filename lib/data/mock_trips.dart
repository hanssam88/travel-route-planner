import 'package:flutter/material.dart';
import 'collaborator.dart';
import 'trip.dart';

final List<Trip> mockTrips = [
  Trip(
    id: 't1',
    title: '강릉 1박 2일 카페투어',
    region: '강릉',
    coverEmoji: '🌊',
    days: const [
      TripDay(label: 'Day 1', spotIds: ['s2', 's1', 's3'], optimized: true),
      TripDay(label: 'Day 2', spotIds: ['s4'], optimized: false),
    ],
    collaborators: [
      const Collaborator(id: 'c1', name: '나', emoji: '🙂', color: Color(0xFF5C8A6E)),
      const Collaborator(id: 'c2', name: '지수', emoji: '🌷', color: Color(0xFFC8654A), cursorSpotId: 's2'),
      const Collaborator(id: 'c3', name: '민호', emoji: '🐻', color: Color(0xFF7E6BD9)),
    ],
    updatedAt: DateTime(2026, 5, 1, 14, 22),
  ),
  Trip(
    id: 't2',
    title: '제주 2박 3일 힐링',
    region: '제주',
    coverEmoji: '🍊',
    days: const [
      TripDay(label: 'Day 1', spotIds: ['s5', 's6']),
      TripDay(label: 'Day 2', spotIds: ['s7']),
      TripDay(label: 'Day 3', spotIds: []),
    ],
    collaborators: [
      const Collaborator(id: 'c1', name: '나', emoji: '🙂', color: Color(0xFF5C8A6E)),
    ],
    updatedAt: DateTime(2026, 4, 28, 9, 10),
  ),
  Trip(
    id: 't3',
    title: '부산 야경 당일치기',
    region: '부산',
    coverEmoji: '🐟',
    days: const [
      TripDay(label: 'Day 1', spotIds: ['s11', 's10', 's8', 's9'], optimized: true),
    ],
    collaborators: [
      const Collaborator(id: 'c1', name: '나', emoji: '🙂', color: Color(0xFF5C8A6E)),
      const Collaborator(id: 'c4', name: '서연', emoji: '🐰', color: Color(0xFFE8B84A)),
    ],
    updatedAt: DateTime(2026, 5, 2, 19, 45),
  ),
];
