import 'dart:async';
import 'dart:math' show pi;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../photo_book.dart';

/// 앱이 주입하는 이미지 공급자 팩토리.
///
/// path 는 로컬 절대 경로, 서버 URL, 테마 상대 경로(images/bg.png) 등
/// 호출자가 정하는 규약. 이 함수는 해당 path 를 **플랫폼에 맞는
/// [ImageProvider]** 로 변환해 돌려준다.
///
/// 예시:
/// ```dart
/// // 데스크톱/모바일 (dart:io 가능):
/// imageProviderFor: (p) => FileImage(File(p))
///
/// // 웹 (URL 기반):
/// imageProviderFor: (p) => NetworkImage(p)
///
/// // 메모리 바이트 캐시:
/// imageProviderFor: (p) => MemoryImage(cache[p]!)
/// ```
typedef PhotoBookImageProviderFactory = ImageProvider Function(String path);

/// 포토북 한 페이지를 렌더링하는 Flutter 위젯.
///
/// 기존 preview_screen._PageRenderer 의 순수 렌더링 계층을 공개 API로 추출.
/// 플랫폼 의존(dart:io) 을 [imageProviderFor] 콜백으로 격리하여 웹/모바일/
/// 데스크톱 모두에서 동일한 코드로 사용 가능.
class PhotoBookPageView extends StatelessWidget {
  /// 렌더링할 페이지.
  final PhotoBookPage page;

  /// 템플릿이 참조하는 이미지 경로 → [ImageProvider] 변환 팩토리.
  final PhotoBookImageProviderFactory imageProviderFor;

  /// 테마 필드 값 — 템플릿 텍스트의 `$key$` 치환에 사용.
  final Map<String, String> fieldValues;

  /// 모서리 둥글기. 기본 4.
  final double cornerRadius;

  /// 배경 그림자. null 이면 그림자 없음.
  final List<BoxShadow>? boxShadow;

  /// 표지일 때 좌상단에 "표지" 뱃지 표시 여부.
  final bool showCoverBadge;

  /// 디버그: frameGroup 영역을 빨간 외곽선으로 표시할지.
  final bool showFrameGroupDebug;

  const PhotoBookPageView({
    super.key,
    required this.page,
    required this.imageProviderFor,
    this.fieldValues = const {},
    this.cornerRadius = 4,
    this.boxShadow,
    this.showCoverBadge = true,
    this.showFrameGroupDebug = false,
  });

  @override
  Widget build(BuildContext context) {
    final template = page.template;

    return Container(
      decoration: BoxDecoration(
        color: _parseColor(template.backgroundColor),
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaleX = constraints.maxWidth / template.layoutWidth;
            final scaleY = constraints.maxHeight / template.layoutHeight;

            return Stack(
              children: [
                // 배경 이미지
                if (template.backgroundImage != null &&
                    template.resolveImagePath(template.backgroundImage) !=
                        null)
                  Positioned.fill(
                    child: Image(
                      image: imageProviderFor(
                          template.resolveImagePath(template.backgroundImage)!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),

                // frameGroup 디버그 오버레이 (옵션)
                if (showFrameGroupDebug)
                  ...template.frameGroups.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final fg = entry.value;
                    return Positioned(
                      left: fg.x * scaleX,
                      top: fg.y * scaleY,
                      width: fg.width * scaleX,
                      height: fg.height * scaleY,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0x80FF0000),
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              'frame[$idx] (${fg.minFrameCount}~${fg.maxFrameCount})',
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                // 사진 배치
                ...page.placements.map((placement) {
                  // over/opacity 이미지 경로 — 테마 상대경로 → 절대경로 변환.
                  final overPath = placement.overImage != null
                      ? template.resolveImagePath(placement.overImage)
                      : null;
                  final opacityPath = placement.opacityImage != null
                      ? template.resolveImagePath(placement.opacityImage)
                      : null;
                  return Positioned(
                    left: placement.x * scaleX,
                    top: placement.y * scaleY,
                    width: placement.width * scaleX,
                    height: placement.height * scaleY,
                    child: _CroppedPhotoTile(
                      placement: placement,
                      imageProviderFor: imageProviderFor,
                      scale: scaleX,
                      overImagePath: overPath,
                      opacityImagePath: opacityPath,
                    ),
                  );
                }),

                // 꾸밈 이미지 (graphic)
                ...template.graphics.map((graphic) {
                  final resolved =
                      template.resolveImagePath(graphic.imageSource) ??
                          graphic.imageSource;
                  return Positioned(
                    left: graphic.x * scaleX,
                    top: graphic.y * scaleY,
                    width: graphic.width * scaleX,
                    height: graphic.height * scaleY,
                    child: Transform.rotate(
                      angle: (graphic.rotation ?? 0) * pi / 180,
                      child: Image(
                        image: imageProviderFor(resolved),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  );
                }),

                // 텍스트 요소
                ...template.texts.map((textEl) {
                  final displayText = textEl.resolveText(fieldValues);
                  if (displayText.isEmpty) return const SizedBox();

                  final text = Text(
                    displayText,
                    style: TextStyle(
                      fontFamily: textEl.fontFamily,
                      fontSize: textEl.fontSize * scaleX,
                      color: _parseColor(textEl.textColor),
                    ),
                    overflow: TextOverflow.ellipsis,
                  );

                  return Positioned(
                    left: textEl.x * scaleX,
                    top: textEl.y * scaleY,
                    width: textEl.width * scaleX,
                    height: textEl.height * scaleY,
                    child: textEl.isVertical
                        ? RotatedBox(quarterTurns: 1, child: text)
                        : text,
                  );
                }),

                // 표지 뱃지
                if (showCoverBadge && page.isCover)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x8A000000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '표지',
                        style:
                            TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final s = hex.replaceAll('#', '');
      final v = int.parse(s, radix: 16);
      if (s.length == 6) return Color(0xFF000000 | v);
      return Color(v);
    } catch (_) {
      return Colors.white;
    }
  }
}

/// 크롭 정보 + 테두리 + over/opacity 이미지 합성을 반영해 사진을 표시하는 타일.
///
/// 합성 우선순위:
/// 1) opacityImage 가 있으면 → ShaderMask(BlendMode.dstIn) 로 사진을 비정형 마스킹.
///    이 경우 borderRadius / Border 는 무시 (마스크가 모양을 결정).
/// 2) opacityImage 가 없으면 → 기존 ClipRRect(borderRadius) + Border outset.
/// 3) overImage 가 있으면 → 결과 위에 그대로 덮어 그림 (장식 프레임).
class _CroppedPhotoTile extends StatefulWidget {
  final PhotoPlacement placement;
  final PhotoBookImageProviderFactory imageProviderFor;

  /// 논리 좌표 → 픽셀 변환 배율 — borderRadius/Width 가 논리 단위라 곱해서 픽셀로.
  final double scale;

  /// 절대경로 (이미 template.resolveImagePath 적용됨). null 이면 미사용.
  final String? overImagePath;
  final String? opacityImagePath;

  const _CroppedPhotoTile({
    required this.placement,
    required this.imageProviderFor,
    this.scale = 1.0,
    this.overImagePath,
    this.opacityImagePath,
  });

  @override
  State<_CroppedPhotoTile> createState() => _CroppedPhotoTileState();
}

class _CroppedPhotoTileState extends State<_CroppedPhotoTile> {
  ui.Image? _opacityMask;

  @override
  void initState() {
    super.initState();
    _loadOpacityMask();
  }

  @override
  void didUpdateWidget(covariant _CroppedPhotoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opacityImagePath != widget.opacityImagePath) {
      setState(() => _opacityMask = null);
      _loadOpacityMask();
    }
  }

  Future<void> _loadOpacityMask() async {
    final path = widget.opacityImagePath;
    if (path == null) return;
    try {
      final provider = widget.imageProviderFor(path);
      final completer = Completer<ui.Image>();
      final stream = provider.resolve(ImageConfiguration.empty);
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (e, st) {
          if (!completer.isCompleted) completer.completeError(e, st);
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      final image = await completer.future;
      if (mounted) setState(() => _opacityMask = image);
    } catch (_) {
      // 마스크 로드 실패 — 그냥 마스킹 없이 렌더 (디버그 용이성)
    }
  }

  @override
  Widget build(BuildContext context) {
    final placement = widget.placement;
    final crop = placement.crop;
    final radius = placement.borderRadius * widget.scale;
    final borderW = placement.borderWidth * widget.scale;
    final borderRadius =
        radius > 0 ? BorderRadius.circular(radius) : BorderRadius.zero;

    // 사진 본체 (크롭 적용)
    Widget photoLayer;
    if (placement.photoPath.isEmpty) {
      photoLayer = Container(color: const Color(0xFFE5E7EB));
    } else {
      photoLayer = OverflowBox(
        alignment: Alignment(
          crop.offsetX > 0 && crop.cropWidth < 1.0
              ? -(crop.offsetX / (1 - crop.cropWidth)) * 2 + 1
              : 0.0,
          crop.offsetY > 0 && crop.cropHeight < 1.0
              ? -(crop.offsetY / (1 - crop.cropHeight)) * 2 + 1
              : 0.0,
        ),
        maxWidth: crop.cropWidth < 1 ? double.infinity : null,
        maxHeight: crop.cropHeight < 1 ? double.infinity : null,
        child: Image(
          image: widget.imageProviderFor(placement.photoPath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFD1D5DB),
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    // ── 마스킹 (opacityImage 우선) 또는 ClipRRect+Border ──
    Widget shaped;
    final mask = _opacityMask;
    if (widget.opacityImagePath != null && mask != null) {
      // 마스킹 모드 — OverflowBox/crop 사용 안 함.
      // photo + mask + over 셋 다 placement 박스에 정확히 맞추는 게 핵심.
      // (기존 OverflowBox 경로는 cropWidth<1 일 때 photo 가 placement 밖으로
      //  새고, ShaderMask 가 그 영역까지 그려서 over 와 사이즈 불일치 발생.)
      Widget photo;
      if (placement.photoPath.isEmpty) {
        photo = Container(color: const Color(0xFFE5E7EB));
      } else {
        photo = Image(
          image: widget.imageProviderFor(placement.photoPath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFD1D5DB),
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }
      shaped = ShaderMask(
        shaderCallback: (Rect bounds) {
          final sx = bounds.width / mask.width;
          final sy = bounds.height / mask.height;
          return ImageShader(
            mask,
            TileMode.clamp,
            TileMode.clamp,
            (Matrix4.identity()..scale(sx, sy)).storage,
            filterQuality: FilterQuality.high,
          );
        },
        blendMode: BlendMode.dstIn,
        child: photo,
      );
    } else {
      // 기존 동작: OverflowBox + ClipRRect + Border
      shaped = ClipRRect(borderRadius: borderRadius, child: photoLayer);
      if (borderW > 0) {
        shaped = DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
                color: _parseColor(placement.borderColor), width: borderW),
          ),
          child: shaped,
        );
      }
    }

    // ── overImage 덧붙이기 — Positioned.fill 로 명시 사이즈 강제 ──
    if (widget.overImagePath != null) {
      shaped = Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(child: shaped),
          Positioned.fill(
            child: IgnorePointer(
              child: Image(
                image: widget.imageProviderFor(widget.overImagePath!),
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ],
      );
    }

    return shaped;
  }

  static Color _parseColor(String hex) {
    try {
      final s = hex.replaceAll('#', '');
      final v = int.parse(s, radix: 16);
      if (s.length == 6) return Color(0xFF000000 | v);
      return Color(v);
    } catch (_) {
      return const Color(0xFFFFFFFF);
    }
  }
}
