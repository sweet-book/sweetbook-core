/// SweetBook 코어 — **순수 Dart 모델만** export.
///
/// Flutter 위젯 (`PhotoBookPageView`) 은 포함하지 않는다.
/// → CLI / 서버 / Isolate 등 Flutter SDK 없는 환경에서 사용.
///
/// Flutter 환경에서 위젯까지 쓰려면 [sweetbook_core.dart] 를 import.
library;

export 'src/photo.dart';
export 'src/photo_book.dart';
export 'src/template.dart';
export 'src/theme_data.dart';
