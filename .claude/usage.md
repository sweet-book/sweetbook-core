# sweetbook_core — 사용법

## 설치

### path 의존 (모노레포)
```yaml
dependencies:
  sweetbook_core:
    path: ../packages/sweetbook_core
```

### git 의존 (외부 분가 후)
```yaml
dependencies:
  sweetbook_core:
    git:
      url: https://github.com/sweet-book/sweetbook-flutter-packages.git
      ref: sweetbook_core-v0.1.0
      path: packages/sweetbook_core
```

### pub.dev (공개 시)
```yaml
dependencies:
  sweetbook_core: ^0.1.0
```

---

## 가져오기

```dart
import 'package:sweetbook_core/sweetbook_core.dart';
```

---

## 1. 모델 — 직접 인스턴스 만들기

```dart
final theme = PhotoBookTheme(
  id: 'sample_03',
  name: 'Sample 03',
  path: '/themes/sample_03',
  contents: [],
);

final photo = Photo(
  id: 'p001',
  path: '/photos/img001.jpg',
  fileName: 'img001.jpg',
  width: 4000,
  height: 3000,
  takenAt: DateTime.now(),
);
```

## 2. JSON 직렬화

```dart
// 역직렬화
final raw = jsonDecode(file.readAsStringSync());
final template = Template.fromJson(raw);

// 직렬화
final json = template.toJson();   // → Map<String, dynamic>
```

---

## 3. 미리보기 위젯 — 페이지 1장 렌더링

### 데스크톱 / 모바일 (dart:io 가능)

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sweetbook_core/sweetbook_core.dart';

PhotoBookPageView(
  page: photoBook.pages[0],
  fieldValues: {'title': '우리 가족 앨범'},
  imageProviderFor: (path) => FileImage(File(path)),
);
```

### 웹

```dart
PhotoBookPageView(
  page: photoBook.pages[0],
  imageProviderFor: (path) => NetworkImage(path),
);
```

### 메모리 캐시

```dart
final cache = <String, Uint8List>{};
// ... 미리 로드 ...

PhotoBookPageView(
  page: page,
  imageProviderFor: (path) => MemoryImage(cache[path]!),
);
```

---

## 4. 옵션 매개변수

| 매개변수 | 기본 | 용도 |
|---|---|---|
| `cornerRadius` | 4 | 위젯 외곽 둥글기 |
| `boxShadow` | null | 그림자 (null = 없음) |
| `showCoverBadge` | true | 표지 페이지에 "표지" 뱃지 |
| `showFrameGroupDebug` | false | frameGroup 빨간 외곽선 디버그 표시 |

```dart
PhotoBookPageView(
  page: page,
  imageProviderFor: provider,
  cornerRadius: 8,
  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
  showFrameGroupDebug: true,  // 개발 중 frame 위치 확인
);
```

---

## 5. 비정형 마스킹 + 장식 프레임 (frameGroup 어트리뷰트)

JSON 에 `opacityImage` / `overImage` 가 있으면 자동 적용:

```jsonc
{
  "type": "frameGroup",
  "position": {"x": 100, "y": 100},
  "width": 400, "height": 400,
  "minFrameCount": 1,
  "maxFrameCount": 1,
  "opacityImage": "images/mask_blob.png",  // ← 알파 마스크
  "overImage": "images/over_frame.png"     // ← 위에 덮을 프레임
}
```

위젯 사용 코드 변경 없음. 합성은 `_CroppedPhotoTile` 가 자동으로 함.

---

## 6. 주의사항

- 모델은 모두 **불변(immutable)**. 변경하려면 `copyWith` 또는 새 인스턴스
- `Template.resolveImagePath()` 는 테마 폴더 경로가 박혀있어야 작동 (`copyWithThemePath`)
- `imageProviderFor` 는 매 빌드마다 호출되므로 캐싱 고려

---

## 7. 트러블슈팅

| 증상 | 원인 / 해결 |
|---|---|
| 사진이 안 보임 | `imageProviderFor` 콜백이 잘못된 경로/실패. errorBuilder 가 회색 박스로 폴백 |
| 마스킹이 안 됨 | `template.themeFolderPath` 가 안 박혀있거나 PNG 파일 없음 |
| 텍스트 폰트 깨짐 | `fontFamily` 가 앱 측 pubspec 에 등록 안 됨 (또는 PDF 의 경우 별도 fontResolver 필요 — sweetbook_pdf 참고) |
