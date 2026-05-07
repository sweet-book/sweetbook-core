import 'template.dart';

/// 테마 info.json의 입력 필드 타입
enum ThemeFieldType {
  /// 한 줄 텍스트 (기본)
  text,

  /// 여러 줄 텍스트
  multiline,

  /// 숫자 (정수 또는 실수)
  number,

  /// 날짜 (yyyy-MM-dd 형식)
  date,

  /// 선택지 (options 중 하나)
  enumOption;

  static ThemeFieldType fromString(String? raw) {
    switch (raw) {
      case 'multiline':
        return ThemeFieldType.multiline;
      case 'number':
        return ThemeFieldType.number;
      case 'date':
        return ThemeFieldType.date;
      case 'enum':
        return ThemeFieldType.enumOption;
      case 'text':
      default:
        return ThemeFieldType.text;
    }
  }

  String get label {
    switch (this) {
      case ThemeFieldType.text:
        return 'text';
      case ThemeFieldType.multiline:
        return 'multiline';
      case ThemeFieldType.number:
        return 'number';
      case ThemeFieldType.date:
        return 'date';
      case ThemeFieldType.enumOption:
        return 'enum';
    }
  }
}

/// 테마 info.json의 입력 필드 정의
class ThemeField {
  final String key;
  final String label;
  final ThemeFieldType type;

  /// 기본값 (선택). 유저가 입력 안 하면 사용.
  final String? defaultValue;

  /// enum 타입에서 사용하는 선택지 (key-label 쌍)
  /// 예: [{"value": "wedding", "label": "결혼식"}, ...]
  final List<ThemeFieldOption> options;

  /// 숫자 타입에서 허용 범위 (null이면 제한 없음)
  final num? minValue;
  final num? maxValue;

  const ThemeField({
    required this.key,
    required this.label,
    this.type = ThemeFieldType.text,
    this.defaultValue,
    this.options = const [],
    this.minValue,
    this.maxValue,
  });

  factory ThemeField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return ThemeField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: ThemeFieldType.fromString(json['type'] as String?),
      defaultValue: json['defaultValue'] as String?,
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(ThemeFieldOption.fromJson)
          .toList(),
      minValue: (json['minValue'] as num?),
      maxValue: (json['maxValue'] as num?),
    );
  }

  /// 하위 호환: 기존 코드에서 type을 문자열로 비교하던 곳 (theme_guide 기반)
  /// 이제는 enum으로 가되, typeString 게터로 문자열 접근 가능
  String get typeString => type.label;
}

/// enum 타입 필드의 선택지 하나
class ThemeFieldOption {
  final String value;
  final String label;

  const ThemeFieldOption({required this.value, required this.label});

  factory ThemeFieldOption.fromJson(Map<String, dynamic> json) {
    return ThemeFieldOption(
      value: json['value'] as String,
      label: json['label'] as String? ?? json['value'] as String,
    );
  }
}

/// 포토북 테마 (cover + content + publish 템플릿 세트)
class PhotoBookTheme {
  final String id;
  final String name;
  final String path;
  final String? thumbnailPath;
  final Template? cover;
  final List<Template> contents;

  /// 발행면/발행 페이지 — 맨 마지막에 1번만 삽입. 없으면 null.
  final Template? publish;

  final List<ThemeField> fields;

  const PhotoBookTheme({
    required this.id,
    required this.name,
    required this.path,
    this.thumbnailPath,
    this.cover,
    this.contents = const [],
    this.publish,
    this.fields = const [],
  });

  /// info.json에 입력 필드가 있는지
  bool get hasFields => fields.isNotEmpty;

  /// 페이지 인덱스에 해당하는 내지 템플릿 (순환 사용) — 하위 호환
  Template? getContentTemplate(int pageIndex) {
    if (contents.isEmpty) return null;
    return contents[pageIndex % contents.length];
  }

  int get contentCount => contents.length;
}
