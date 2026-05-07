import 'photo.dart';
import 'template.dart';
import 'theme_data.dart';

/// 크롭 정보 (0.0~1.0 정규화)
class CropInfo {
  final double offsetX;
  final double offsetY;
  final double cropWidth;
  final double cropHeight;

  const CropInfo({
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.cropWidth = 1.0,
    this.cropHeight = 1.0,
  });

  factory CropInfo.fromJson(Map<String, dynamic> json) {
    return CropInfo(
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
      cropWidth: (json['cropWidth'] as num?)?.toDouble() ?? 1.0,
      cropHeight: (json['cropHeight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  bool get hasCrop => offsetX != 0 || offsetY != 0 || cropWidth != 1 || cropHeight != 1;
}

/// 사진 1장의 배치 정보
class PhotoPlacement {
  final String photoId;
  final String photoPath;
  final double x;
  final double y;
  final double width;
  final double height;
  final CropInfo crop;

  /// 모서리 둥글기 (논리 좌표). 0이면 직각.
  /// 부모 frameGroup 의 borderRadius 가 자동 복사된다.
  final double borderRadius;

  /// 테두리 두께 (논리 좌표). 0이면 테두리 없음.
  final double borderWidth;

  /// 테두리 색 — ARGB 8자리 hex 또는 RGB 6자리.
  final String borderColor;

  /// 부모 frameGroup 에서 복사된 over/opacity 장식 이미지 경로 (테마 상대경로).
  /// 자세한 설명은 [FrameGroup.overImage] / [FrameGroup.opacityImage] 참고.
  final String? overImage;
  final String? opacityImage;

  const PhotoPlacement({
    required this.photoId,
    required this.photoPath,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.crop = const CropInfo(),
    this.borderRadius = 0,
    this.borderWidth = 0,
    this.borderColor = '#FFFFFFFF',
    this.overImage,
    this.opacityImage,
  });

  factory PhotoPlacement.fromJson(
    Map<String, dynamic> json,
    Map<String, Photo> photoLookup,
  ) {
    final photoId = json['photoId'] as String;
    final photo = photoLookup[photoId];

    return PhotoPlacement(
      photoId: photoId,
      photoPath: photo?.path ?? '',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      crop: json['crop'] != null
          ? CropInfo.fromJson(json['crop'] as Map<String, dynamic>)
          : const CropInfo(),
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0,
      borderColor: (json['borderColor'] as String?) ?? '#FFFFFFFF',
      overImage: json['overImage'] as String?,
      opacityImage: json['opacityImage'] as String?,
    );
  }
}

/// 포토북 한 페이지
class PhotoBookPage {
  final int pageIndex;
  final Template template;
  final List<PhotoPlacement> placements;
  final String? expression;
  final double score;
  final bool isCover;

  /// 발행면/발행 페이지 여부 (맨 마지막에 1번만 존재)
  final bool isPublish;

  const PhotoBookPage({
    required this.pageIndex,
    required this.template,
    required this.placements,
    this.expression,
    this.score = 0.0,
    this.isCover = false,
    this.isPublish = false,
  });
}

/// 포토북 전체
class PhotoBook {
  final PhotoBookTheme theme;
  final List<PhotoBookPage> pages;
  final int totalPhotos;
  final DateTime createdAt;

  const PhotoBook({
    required this.theme,
    required this.pages,
    required this.totalPhotos,
    required this.createdAt,
  });

  PhotoBookPage? get cover =>
      pages.where((p) => p.isCover).firstOrNull;

  PhotoBookPage? get publish =>
      pages.where((p) => p.isPublish).firstOrNull;

  List<PhotoBookPage> get contentPages =>
      pages.where((p) => !p.isCover && !p.isPublish).toList();

  int get pageCount => pages.length;
}
