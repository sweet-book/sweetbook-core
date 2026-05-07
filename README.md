# sweetbook_core

SweetBook 포토북 **코어 패키지** — 도메인 모델 + 미리보기 렌더러.

## 구성

### 도메인 모델 (순수 Dart)
- `Photo` / `Template` / `PhotoBook` / `PhotoBookPage`
- `PhotoPlacement` / `CropInfo` / `FrameGroup`
- `PhotoBookTheme` / `ThemeField` / `ThemeFieldOption` / `ThemeFieldType`
- JSON 직렬화·역직렬화

### 미리보기 위젯 (Flutter)
- `PhotoBookPageView` — 한 페이지를 렌더링
- `PhotoBookImageProviderFactory` — 플랫폼별 이미지 공급 주입 타입

## 사용

```dart
import 'package:sweetbook_core/sweetbook_core.dart';

PhotoBookPageView(
  page: photoBook.pages[0],
  fieldValues: {'title': '우리 가족 앨범'},
  imageProviderFor: (path) => FileImage(File(path)),     // 데스크톱/모바일
  // imageProviderFor: (path) => NetworkImage(path),      // 웹
  // imageProviderFor: (path) => MemoryImage(cache[path]!), // 캐시된 바이트
);
```

## 설계 원칙

- **모델**은 Flutter 의존 없음. 서버·CLI·다른 순수 Dart 컨텍스트에서도 사용 가능
- **렌더러**는 Flutter 의존. 단 `dart:io` 는 쓰지 않음 — `ImageProvider` 를 외부에서 주입받아 플랫폼 중립 유지
- 기존 `auto-photo-book-oss` 의 `preview_screen._PageRenderer` 에서 추출됨

## 라이선스

MIT — [LICENSE](./LICENSE) 참조.
