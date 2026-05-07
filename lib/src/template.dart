/// 프레임 그룹 — 사진이 배치될 영역 (복수 허용)
///
/// 사진 수는 `minFrameCount ~ maxFrameCount` 범위로 표현한다.
/// ⚠️ `frameCount` (디폴트값) 필드는 제거됨 (2026-04-21):
///   디자이너 의도를 min/max 범위만으로 충분히 표현 가능.
///   "기본값"은 오케스트레이터가 필요 시 sum(max) 또는 사용자 입력으로 결정.
class FrameGroup {
  final double x;
  final double y;
  final double width;
  final double height;
  final int minFrameCount;
  final int maxFrameCount;

  /// 사진 모서리 둥글기 (논리 좌표). 0이면 직각.
  final double borderRadius;

  /// 테두리 두께 (논리 좌표). 0이면 테두리 없음.
  final double borderWidth;

  /// 테두리 색 — ARGB 8자리 hex 또는 RGB 6자리. null/빈문자열이면 흰색.
  final String borderColor;

  /// 자동배치 결과 사진 슬롯들 사이의 간격 (논리 좌표).
  /// 0이면 사진끼리 딱 붙음. 양수면 후처리에서 안쪽으로 inset 하여 사진 사이가 떨어짐.
  /// frameGroup 외곽선과 닿는 변은 그대로 (스마트 인셋).
  final double photoGap;

  /// 사진 위에 덧씌우는 장식 이미지의 테마 상대경로 (예: "images/f3.png").
  /// 알파 PNG 권장. null 이면 사용 안 함.
  final String? overImage;

  /// 사진을 비정형 모양으로 마스킹하는 알파 이미지의 테마 상대경로.
  /// 이 이미지의 알파 채널이 사진의 visibility 가 됨 (BlendMode.dstIn).
  /// null 이면 사용 안 함. borderRadius 와 동시 사용 시 opacityImage 우선.
  final String? opacityImage;

  const FrameGroup({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.minFrameCount = 1,
    this.maxFrameCount = 9,
    this.borderRadius = 0,
    this.borderWidth = 0,
    this.borderColor = '#FFFFFFFF',
    this.photoGap = 0,
    this.overImage,
    this.opacityImage,
  });

  factory FrameGroup.fromJson(Map<String, dynamic> json) {
    // 하위 호환: 과거 frameCount 필드만 있던 JSON은 min=max=frameCount로 해석
    final legacyFc = (json['frameCount'] as num?)?.toInt();
    final min = (json['minFrameCount'] as num?)?.toInt() ?? legacyFc ?? 1;
    final max = (json['maxFrameCount'] as num?)?.toInt() ?? legacyFc ?? 1;
    return FrameGroup(
      x: (json['position']['x'] as num).toDouble(),
      y: (json['position']['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      minFrameCount: min,
      maxFrameCount: max,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0,
      borderColor: (json['borderColor'] as String?) ?? '#FFFFFFFF',
      photoGap: (json['photoGap'] as num?)?.toDouble() ?? 0,
      overImage: _normalizeAssetPath(json['overImage'] as String?),
      opacityImage: _normalizeAssetPath(json['opacityImage'] as String?),
    );
  }
}

/// 레거시 WPF `pack://siteoforigin:,,,/ebook/images/themes/<name>/<file>` URI 를
/// 우리 시스템의 테마 상대경로 (`images/<file>`) 로 정규화.
/// 일반 상대경로는 그대로 통과.
String? _normalizeAssetPath(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  // pack://siteoforigin:,,,/ebook/images/themes/<theme>/<rest>
  final match = RegExp(r'^pack://[^/]*/ebook/images/themes/[^/]+/(.*)$')
      .firstMatch(raw);
  if (match != null) {
    return 'images/${match.group(1)!}';
  }
  return raw;
}

/// 템플릿 내 꾸밈 이미지 요소
class GraphicElement {
  final double x;
  final double y;
  final double width;
  final double height;
  final double? rotation;
  final String imageSource;

  const GraphicElement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation,
    required this.imageSource,
  });

  factory GraphicElement.fromJson(Map<String, dynamic> json) {
    return GraphicElement(
      x: (json['position']['x'] as num).toDouble(),
      y: (json['position']['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble(),
      imageSource: json['imageSource'] as String,
    );
  }
}

/// 템플릿 내 텍스트 요소
class TextElement {
  final double x;
  final double y;
  final double width;
  final double height;
  final String text;
  final String fontFamily;
  final double fontSize;
  final bool isVertical;
  final String textColor;

  const TextElement({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.text,
    this.fontFamily = '맑은 고딕',
    this.fontSize = 16,
    this.isVertical = false,
    this.textColor = '#FF000000',
  });

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      x: (json['position']['x'] as num).toDouble(),
      y: (json['position']['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      text: json['text'] as String? ?? '',
      fontFamily: json['fontFamily'] as String? ?? '맑은 고딕',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      isVertical: json['isVertical'] as bool? ?? false,
      textColor: json['textColor'] as String? ?? '#FF000000',
    );
  }

  /// $변수명을 실제 값으로 치환
  String resolveText(Map<String, String> fieldValues) {
    var resolved = text;
    for (final entry in fieldValues.entries) {
      resolved = resolved.replaceAll('\$${entry.key}', entry.value);
    }
    return resolved;
  }
}

/// 페이지 템플릿 (cover, content, publish)
class Template {
  final String name;
  final String templateKind; // "cover" | "content" | "publish"
  final double layoutWidth;
  final double layoutHeight;
  final String backgroundColor;
  final String? backgroundImage;
  final List<FrameGroup> frameGroups;
  final List<GraphicElement> graphics;
  final List<TextElement> texts;
  final String? themeFolderPath;

  const Template({
    required this.name,
    required this.templateKind,
    required this.layoutWidth,
    required this.layoutHeight,
    required this.backgroundColor,
    this.backgroundImage,
    this.frameGroups = const [],
    this.graphics = const [],
    this.texts = const [],
    this.themeFolderPath,
  });

  /// 상대 경로를 테마 폴더 기준 절대 경로로 변환
  String? resolveImagePath(String? relativePath) {
    if (relativePath == null || themeFolderPath == null) return null;
    return '$themeFolderPath/$relativePath';
  }

  /// 하위 호환: 첫 번째 frameGroup 반환 (기존 코드 호환)
  FrameGroup? get firstFrameGroup =>
      frameGroups.isNotEmpty ? frameGroups.first : null;

  /// frameGroup이 있는지
  bool get hasFrameGroups => frameGroups.isNotEmpty;

  /// 템플릿이 수용 가능한 최소 사진 수 (모든 frameGroup의 minFrameCount 합)
  int get minPhotos =>
      frameGroups.fold(0, (sum, fg) => sum + fg.minFrameCount);

  /// 템플릿이 수용 가능한 최대 사진 수 (모든 frameGroup의 maxFrameCount 합)
  int get maxPhotos =>
      frameGroups.fold(0, (sum, fg) => sum + fg.maxFrameCount);

  /// 주어진 사진 수가 이 템플릿의 수용 범위 안에 있는지
  bool acceptsPhotoCount(int photoCount) =>
      photoCount >= minPhotos && photoCount <= maxPhotos;

  factory Template.fromJson(Map<String, dynamic> json) {
    final layout = json['layout'] as Map<String, dynamic>;
    final elements = layout['elements'] as List<dynamic>;

    final frameGroupList = <FrameGroup>[];
    final graphicList = <GraphicElement>[];
    final textList = <TextElement>[];

    for (final el in elements) {
      final type = el['type'] as String;
      if (type == 'frameGroup') {
        frameGroupList.add(FrameGroup.fromJson(el as Map<String, dynamic>));
      } else if (type == 'gallery') {
        // 하위 호환: gallery 타입도 frameGroup으로 취급 (frameCount=1)
        frameGroupList.add(FrameGroup.fromJson(el as Map<String, dynamic>));
      } else if (type == 'graphic') {
        graphicList.add(
          GraphicElement.fromJson(el as Map<String, dynamic>),
        );
      } else if (type == 'text') {
        textList.add(
          TextElement.fromJson(el as Map<String, dynamic>),
        );
      }
    }

    return Template(
      name: json['name'] as String? ?? '',
      templateKind: json['templateKind'] as String,
      layoutWidth: (json['layoutWidth'] as num).toDouble(),
      layoutHeight: (json['layoutHeight'] as num).toDouble(),
      backgroundColor: layout['backgroundColor'] as String? ?? '#FFFFFFFF',
      backgroundImage: layout['backgroundImage'] as String?,
      frameGroups: frameGroupList,
      graphics: graphicList,
      texts: textList,
    );
  }

  bool get isCover => templateKind == 'cover';
  bool get isContent => templateKind == 'content';
  bool get isPublish => templateKind == 'publish';

  /// themeFolderPath를 설정한 복사본 반환
  Template copyWithThemePath(String path) {
    return Template(
      name: name,
      templateKind: templateKind,
      layoutWidth: layoutWidth,
      layoutHeight: layoutHeight,
      backgroundColor: backgroundColor,
      backgroundImage: backgroundImage,
      frameGroups: frameGroups,
      graphics: graphics,
      texts: texts,
      themeFolderPath: path,
    );
  }
}
