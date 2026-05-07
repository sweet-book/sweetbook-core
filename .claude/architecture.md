# sweetbook_core — 구조

> SweetBook 포토북 도메인 모델 + 미리보기 렌더러.
> 모든 SweetBook 패키지의 **leaf** (가장 안정적, 다른 패키지가 바라봄).

---

## 디렉터리

```
packages/sweetbook_core/
├── lib/
│   ├── sweetbook_core.dart        ← public barrel
│   └── src/
│       ├── photo.dart             ← Photo (사용자가 선택한 사진 메타)
│       ├── template.dart          ← Template + FrameGroup + GraphicElement + TextElement
│       ├── theme_data.dart        ← PhotoBookTheme + ThemeField + ThemeFieldType + ThemeFieldOption
│       ├── photo_book.dart        ← PhotoBook + PhotoBookPage + PhotoPlacement + CropInfo
│       └── widgets/
│           └── photo_book_page_view.dart  ← Flutter 미리보기 위젯
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 두 계층

### 1) 도메인 모델 (순수 Dart)
- `Photo` / `Template` / `PhotoBook` / `PhotoBookPage`
- `PhotoPlacement` / `CropInfo` / `FrameGroup`
- `PhotoBookTheme` / `ThemeField` / `ThemeFieldType` / `ThemeFieldOption`
- `GraphicElement` / `TextElement`

**원칙**:
- 모든 필드 `final` + `const` 생성자 우선
- JSON `toJson` / `fromJson` 만 내장. 파일 I/O 없음
- 파생 getter (`Template.hasFrameGroups`, `PhotoBookPage.isCover`) 는 담되 로직 최소

### 2) 미리보기 위젯 (Flutter)
- `PhotoBookPageView` — 한 페이지를 렌더링
- `PhotoBookImageProviderFactory` 타입 — 이미지 공급 주입

**핵심 설계**:
- `dart:io` 사용 안 함. `ImageProvider` 콜백을 외부에서 주입받아 플랫폼 중립 유지
  - 데스크톱/모바일: `(p) => FileImage(File(p))`
  - 웹: `(p) => NetworkImage(p)` 또는 `MemoryImage`
- 합성 우선순위:
  1. `opacityImage` 있으면 → `ShaderMask(BlendMode.dstIn)` 비정형 마스킹
  2. 없으면 → `ClipRRect(borderRadius)` + `Border` outset
  3. `overImage` 있으면 → 위에 Stack 으로 덮기

---

## 외부 의존

| 의존 | 용도 |
|---|---|
| `flutter` (sdk) | 위젯 |
| `collection` | (현재 미사용, 향후 확장 대비 선언만) |

**dart:io 의존**: 0  
**다른 sweetbook 패키지 의존**: 0 (leaf)

---

## 공개 API (barrel 으로 노출되는 것만)

```dart
// 모델
Photo, Template, PhotoBook, PhotoBookPage, PhotoPlacement, CropInfo,
FrameGroup, GraphicElement, TextElement,
PhotoBookTheme, ThemeField, ThemeFieldType, ThemeFieldOption

// 위젯
PhotoBookPageView, PhotoBookImageProviderFactory
```

---

## 자산

없음. 폰트·이미지 등은 호출자 (앱) 책임.

---

## 호환성

- Flutter 3.24+
- Dart 3.3+
- 모든 플랫폼 (Web 포함) 작동 가능 (단, 호출자가 ImageProvider 를 플랫폼에 맞게 주입해야 함)
