import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../../models/place.dart';
import '../../utils/constants.dart';
import 'map_marker.dart';

/// 카카오 맵에 장소 마커 + 폴리라인을 표시하는 위젯.
///
/// [places]의 유효 좌표 장소를 마커(POI)로 표시하고,
/// 순서대로 폴리라인으로 연결한다.
/// [selectedIndex] 변경 시 해당 장소로 카메라 이동.
class RouteMap extends StatefulWidget {
  final List<Place> places;
  final int? selectedIndex;
  final void Function(int index)? onMarkerTap;

  const RouteMap({
    super.key,
    required this.places,
    this.selectedIndex,
    this.onMarkerTap,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  KakaoMapController? _controller;
  bool _hasError = false;

  /// 유효 좌표 장소의 원본 인덱스 목록
  List<int> _computeValidIndexMap() {
    final map = <int>[];
    for (var i = 0; i < widget.places.length; i++) {
      if (hasValidCoordinates(widget.places[i])) {
        map.add(i);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorFallback();
    }

    final validIndexMap = _computeValidIndexMap();
    if (validIndexMap.isEmpty) {
      return _buildEmptyFallback();
    }

    return KakaoMap(
      onMapReady: _onMapReady,
      onMapError: _onMapError,
      option: KakaoMapOption(
        position: LatLng(defaultMapLat, defaultMapLng),
        zoomLevel: defaultMapZoomLevel,
      ),
    );
  }

  void _onMapReady(KakaoMapController controller) {
    _controller = controller;
    _setupOverlays();
  }

  void _onMapError(Error error) {
    debugPrint('KakaoMap 에러: $error');
    if (mounted) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _setupOverlays() async {
    final controller = _controller;
    if (controller == null) return;

    final indexMap = _computeValidIndexMap();
    if (indexMap.isEmpty) return;

    try {
      await _addMarkers(controller, indexMap);
      await _addPolyline(controller, indexMap);
      await _fitBounds(controller, indexMap);
    } catch (e) {
      debugPrint('RouteMap overlay 설정 실패: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  /// 유효 좌표 장소마다 텍스트 POI 추가.
  Future<void> _addMarkers(
    KakaoMapController controller,
    List<int> indexMap,
  ) async {
    final labelLayer = controller.labelLayer;

    for (var i = 0; i < indexMap.length; i++) {
      final originalIndex = indexMap[i];
      final place = widget.places[originalIndex];
      final color = markerColorFor(place);

      final style = PoiStyle(
        textStyle: [
          PoiTextStyle(
            size: 28,
            color: color,
            stroke: 2,
            strokeColor: Colors.white,
          ),
        ],
        textGravity: const MapGravity(
          HorizontalAlign.center,
          VerticalAlign.center,
        ),
      );

      await labelLayer.addPoi(
        LatLng(place.lat, place.lng),
        style: style,
        text: '${i + 1}. ${place.name}',
        onClick: () {
          widget.onMarkerTap?.call(originalIndex);
        },
      );
    }
  }

  /// 유효 좌표 장소들을 순서대로 폴리라인으로 연결.
  Future<void> _addPolyline(
    KakaoMapController controller,
    List<int> indexMap,
  ) async {
    if (indexMap.length < 2) return;

    final points = indexMap
        .map((i) => widget.places[i])
        .map((p) => LatLng(p.lat, p.lng))
        .toList();

    await controller.shapeLayer.addPolylineShape(
      MapPoint(points),
      PolylineStyle(const Color(polylineColor), 3.0),
      PolylineCap.round,
    );
  }

  /// 모든 유효 좌표가 보이도록 카메라 bounds 맞추기.
  Future<void> _fitBounds(
    KakaoMapController controller,
    List<int> indexMap,
  ) async {
    if (indexMap.isEmpty) return;

    final points = indexMap
        .map((i) => widget.places[i])
        .map((p) => LatLng(p.lat, p.lng))
        .toList();

    if (points.length == 1) {
      await controller.moveCamera(
        CameraUpdate.newCenterPosition(points.first, zoomLevel: 15),
      );
    } else {
      await controller.moveCamera(
        CameraUpdate.fitMapPoints(points, padding: 50),
      );
    }
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != null) {
      _moveCameraToSelected(widget.selectedIndex!);
    }
  }

  Future<void> _moveCameraToSelected(int index) async {
    final controller = _controller;
    if (controller == null) return;
    if (index < 0 || index >= widget.places.length) return;

    final place = widget.places[index];
    if (!hasValidCoordinates(place)) return;

    await controller.moveCamera(
      CameraUpdate.newCenterPosition(
        LatLng(place.lat, place.lng),
        zoomLevel: 15,
      ),
      animation: const CameraAnimation(500),
    );
  }

  Widget _buildErrorFallback() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            '지도를 불러올 수 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFallback() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            '표시할 장소가 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
