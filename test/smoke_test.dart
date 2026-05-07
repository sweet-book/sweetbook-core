import 'package:flutter_test/flutter_test.dart';
import 'package:sweetbook_core/sweetbook_core.dart';

void main() {
  test('Photo can be constructed', () {
    final p = Photo(
      id: 'p1',
      path: '/x.jpg',
      fileName: 'x.jpg',
      width: 100,
      height: 200,
      takenAt: DateTime.parse('2026-01-01T00:00:00Z'),
    );
    expect(p.id, 'p1');
    expect(p.width, 100);
    expect(p.height, 200);
  });

  test('PhotoBookTheme can be constructed', () {
    const theme = PhotoBookTheme(
      id: 'sample_03',
      name: 'Sample 03',
      path: '/themes/sample_03',
      contents: [],
    );
    expect(theme.id, 'sample_03');
  });
}
