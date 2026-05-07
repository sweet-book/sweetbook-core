# PRD — sweetbook_core

**버전:** 0.1.0
**상태:** 개발 중 (0.x = unstable, breaking 자유)

---

## 1. 패키지 정체

SweetBook 포토북 시스템의 **공통 데이터 모델 + 미리보기 렌더러** 를 제공하는 leaf 패키지.

다른 패키지(`sweetbook_layout`, `sweetbook_pdf`)와 모든 SweetBook 앱이 이 패키지를 의존한다.

---

## 2. 책임 (Responsibility)

### 담당
- 포토북 도메인 타입 정의 (Photo, Template, PhotoBook 등)
- JSON 직렬화/역직렬화
- Flutter 위젯으로 페이지 1장 렌더링 (`PhotoBookPageView`)
- 마스킹/테두리/오버레이 합성 시각 효과

### 비담당
- 자동배치 알고리즘 → `sweetbook_layout`
- PDF 출력 → `sweetbook_pdf`
- 파일 I/O / 이미지 dimension 계산 → 호출자
- 폰트 로딩 → 호출자

---

## 3. 의존 정책

| 카테고리 | 정책 |
|---|---|
| dart:io | ❌ 사용 금지 |
| dart:ui | ✅ 허용 (Flutter 위젯에 필수) |
| dart:html / dart:js | ❌ 금지 (특정 플랫폼 종속) |
| Flutter | ✅ 사용 (Material 위젯 사용) |
| 다른 sweetbook 패키지 | ❌ 의존 금지 (leaf 유지) |

---

## 4. SemVer 가이드

### MAJOR 트리거
- `Photo`, `Template`, `PhotoBook` 등의 필드 제거 / 타입 변경
- `PhotoBookPageView` 의 필수 매개변수 추가 / 시그니처 변경
- JSON 키 이름 변경

### MINOR 트리거
- 새 필드 추가 (default 값 있어야 호환)
- 새 헬퍼 / 새 위젯 옵션 추가
- 새 모델 클래스 추가

### PATCH 트리거
- 내부 구현 개선
- 시각 렌더링 버그 픽스
- 문서 갱신

---

## 5. 1.0.0 진입 조건

- [ ] 다른 SweetBook 패키지 + 1개 이상의 외부 앱이 이 패키지를 안정적으로 사용 중
- [ ] 모든 모델의 JSON 스키마 확정 (필드 추가 외 변경 거의 없음 보장)
- [ ] PhotoBookPageView API 안정 (요구사항 변경 6개월 동안 0건)
- [ ] CHANGELOG.md 정기 작성 시작

---

## 6. 향후 추가 후보

| 기능 | 우선순위 | 비고 |
|---|---|---|
| Dark mode 지원 (배경/텍스트 색 자동 반전) | low | 옵션 매개변수로 |
| 썸네일 생성 헬퍼 (`PhotoBookPageView.toImage()`) | medium | UI에서 미리보기 캡처용 |
| 애니메이션 옵션 (페이지 전환) | low | 디자인 결정 후 |
| `Template` 변경 검증 (`validate()`) | medium | 디자이너 도구용 |
| 상수 themed (색상 팔레트) export | low | 디자인 시스템 통합 시 |

---

## 7. 위험 / 우려사항

- **dart:ui 의존**: 위젯 패키지 특성상 불가피. Flutter Web 에서도 dart:ui 가 동작하므로 OK.
- **JSON 스키마 변경 비용**: 외부 앱이 JSON 파일을 직접 작성하기 때문에 키 이름 변경 = 공급망 충격. MINOR 추가만 권장.
- **Photo 클래스 이름 충돌**: `sweetbook_layout` 내부에도 `Photo` (알고리즘용) 존재 → barrel 비공개 처리로 회피 중.

---

## 8. 변경 로그 위치

`CHANGELOG.md` (패키지 루트). melos 자동 생성.

---

## 9. 외부 분가 후 운영

- 리포: `sweetbook-flutter-packages` 모노레포 내
- 태그: `sweetbook_core-vX.Y.Z`
- 게시 채널: pub.dev (공개 결정 시) 또는 private registry / git URL
