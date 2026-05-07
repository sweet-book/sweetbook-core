/// SweetBook 포토북 코어 — 도메인 모델 + 미리보기 렌더러.
///
/// 모델은 플랫폼 무관(순수 Dart), 렌더러는 Flutter 위젯.
/// 웹·모바일·데스크톱에서 동일한 API로 사용 가능.
library;

// ── Models ──────────────────────────────────────────
export 'src/photo.dart';
export 'src/photo_book.dart';
export 'src/template.dart';
export 'src/theme_data.dart';

// ── Widgets ─────────────────────────────────────────
export 'src/widgets/photo_book_page_view.dart';
