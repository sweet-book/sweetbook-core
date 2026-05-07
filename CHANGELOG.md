# Changelog

All notable changes to this package will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/) and this
project adheres to [Semantic Versioning](https://semver.org/) (0.x = unstable).

## [0.1.0] - 2026-05-07

### Added
- 도메인 모델: `Photo`, `Template`, `PhotoBook`, `PhotoBookPage`, `PhotoPlacement`,
  `CropInfo`, `FrameGroup`, `GraphicElement`, `TextElement`,
  `PhotoBookTheme`, `ThemeField`, `ThemeFieldType`, `ThemeFieldOption`
- 위젯: `PhotoBookPageView` — 페이지 1장 렌더러
- 외부 주입: `PhotoBookImageProviderFactory` 타입
- 시각 효과: `opacityImage` (ShaderMask) / `overImage` (Stack overlay) / `borderRadius` /
  `borderWidth` / `borderColor` / `photoGap` / `cornerRadius` / `boxShadow` /
  `showCoverBadge` / `showFrameGroupDebug`
- Legacy WPF pack:// URI 자동 변환 (`_normalizeAssetPath`)
- 표지 페이지 "표지" 뱃지 표시
- frameGroup 디버그 외곽선 옵션
