import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../../utils/constants.dart';

/// 장소 타입에 따라 마커 색상을 반환
Color markerColorFor(Place place) {
  return place.isCafe
      ? const Color(markerColorCafe)
      : const Color(markerColorMeal);
}

/// 좌표가 유효한지 확인 (0,0 또는 범위 밖이면 무효)
bool hasValidCoordinates(Place place) {
  final lat = place.lat, lng = place.lng;
  return lat.isFinite && lng.isFinite &&
      lat >= -90 && lat <= 90 &&
      lng >= -180 && lng <= 180 &&
      !(lat == 0 && lng == 0);
}
