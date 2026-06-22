import '../../core/database/database.dart';
import 'face_marker_size.dart';

/// 面部地图上的标记数据（可用于草稿或已持久化记录）。
class FaceMapMarkerData {
  const FaceMapMarkerData({
    required this.id,
    required this.mapX,
    required this.mapY,
    this.size = FaceMarkerSize.large,
  });

  final String id;
  final double mapX;
  final double mapY;
  final FaceMarkerSize size;

  factory FaceMapMarkerData.fromSpot(SpotFaceMarker marker) {
    return FaceMapMarkerData(
      id: marker.id,
      mapX: marker.mapX,
      mapY: marker.mapY,
      size: FaceMarkerSize.fromId(marker.size),
    );
  }

  FaceMapMarkerData copyWith({
    double? mapX,
    double? mapY,
    FaceMarkerSize? size,
  }) {
    return FaceMapMarkerData(
      id: id,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      size: size ?? this.size,
    );
  }
}
