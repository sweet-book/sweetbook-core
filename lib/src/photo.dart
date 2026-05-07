/// 사용자가 선택한 사진 정보
class Photo {
  final String id;
  final String path;
  final String fileName;
  final int fileSize;
  final int width;
  final int height;
  final DateTime? lastModified;
  final DateTime? takenAt;

  const Photo({
    required this.id,
    required this.path,
    required this.fileName,
    this.fileSize = 0,
    this.width = 0,
    this.height = 0,
    this.lastModified,
    this.takenAt,
  });

  /// 알고리즘 연동용 JSON (id, width, height만 전달)
  Map<String, dynamic> toAlgorithmJson() => {
        'id': id,
        'width': width,
        'height': height,
      };

  double get aspectRatio =>
      height > 0 ? width / height : 1.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
