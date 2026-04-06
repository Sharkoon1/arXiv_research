import 'package:flutter_test/flutter_test.dart';
import 'package:arxiv_research/models/paper.dart';

void main() {
  const paper = Paper(
    id: 'https://arxiv.org/abs/2401.00001',
    title: 'Test Paper',
    abstract: 'An abstract.',
    authors: ['Alice Smith', 'Bob Jones', 'Carol White'],
    publishedDate: '2024-01-15T00:00:00Z',
    pdfUrl: 'https://arxiv.org/pdf/2401.00001',
    abstractUrl: 'https://arxiv.org/abs/2401.00001',
    primaryCategory: 'cs.AI',
  );

  group('Paper.shortId', () {
    test('extracts last path segment from arXiv URL', () {
      expect(paper.shortId, '2401.00001');
    });

    test('returns raw id when not a valid URL', () {
      const p = Paper(
        id: 'not-a-url',
        title: '', abstract: '', authors: [],
        publishedDate: '', pdfUrl: '', abstractUrl: '', primaryCategory: '',
      );
      expect(p.shortId, 'not-a-url');
    });
  });

  group('Paper.formattedDate', () {
    test('formats ISO date string correctly', () {
      expect(paper.formattedDate, 'Jan 15, 2024');
    });

    test('returns raw string for unparseable date', () {
      const p = Paper(
        id: '', title: '', abstract: '', authors: [],
        publishedDate: 'bad-date', pdfUrl: '', abstractUrl: '', primaryCategory: '',
      );
      expect(p.formattedDate, 'bad-date');
    });
  });

  group('Paper.authorsPreview', () {
    test('returns Unknown for empty authors', () {
      const p = Paper(
        id: '', title: '', abstract: '', authors: [],
        publishedDate: '', pdfUrl: '', abstractUrl: '', primaryCategory: '',
      );
      expect(p.authorsPreview, 'Unknown');
    });

    test('returns single author name', () {
      const p = Paper(
        id: '', title: '', abstract: '', authors: ['Alice Smith'],
        publishedDate: '', pdfUrl: '', abstractUrl: '', primaryCategory: '',
      );
      expect(p.authorsPreview, 'Alice Smith');
    });

    test('joins two authors with &', () {
      const p = Paper(
        id: '', title: '', abstract: '', authors: ['Alice', 'Bob'],
        publishedDate: '', pdfUrl: '', abstractUrl: '', primaryCategory: '',
      );
      expect(p.authorsPreview, 'Alice & Bob');
    });

    test('uses et al. for three or more authors', () {
      expect(paper.authorsPreview, 'Alice Smith et al.');
    });
  });

  group('Paper JSON serialization', () {
    test('round-trips through toJson/fromJson', () {
      final json = paper.toJson();
      final restored = Paper.fromJson(json);
      expect(restored, paper);
    });

    test('isRead defaults to false', () {
      final json = paper.toJson()..remove('isRead');
      final restored = Paper.fromJson(json);
      expect(restored.isRead, false);
    });
  });
}
