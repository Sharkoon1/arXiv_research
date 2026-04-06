import 'package:flutter_test/flutter_test.dart';
import 'package:arxiv_research/models/paper.dart';

void main() {
  const paper = Paper(
    id: 'abc-uuid-123',
    title: 'Test Paper',
    summary: 'A short summary.',
    keyContribution: 'Novel approach to X.',
    whyItMatters: 'Improves Y by 20%.',
    authors: ['Alice Smith', 'Bob Jones', 'Carol White'],
    source: 'arXiv',
    url: 'https://arxiv.org/abs/2401.00001',
    publishedDate: '2024-01-15',
    category: 'LLM',
    importanceScore: 85,
  );

  group('Paper.formattedDate', () {
    test('formats ISO date string correctly', () {
      expect(paper.formattedDate, 'Jan 15, 2024');
    });

    test('returns raw string for unparseable date', () {
      const p = Paper(
        id: '', title: '', summary: '', keyContribution: '', whyItMatters: '',
        authors: [], source: '', url: '', publishedDate: 'bad-date',
        category: '', importanceScore: 0,
      );
      expect(p.formattedDate, 'bad-date');
    });
  });

  group('Paper.authorsPreview', () {
    test('returns Unknown for empty authors', () {
      const p = Paper(
        id: '', title: '', summary: '', keyContribution: '', whyItMatters: '',
        authors: [], source: '', url: '', publishedDate: '',
        category: '', importanceScore: 0,
      );
      expect(p.authorsPreview, 'Unknown');
    });

    test('returns single author name', () {
      const p = Paper(
        id: '', title: '', summary: '', keyContribution: '', whyItMatters: '',
        authors: ['Alice Smith'], source: '', url: '', publishedDate: '',
        category: '', importanceScore: 0,
      );
      expect(p.authorsPreview, 'Alice Smith');
    });

    test('joins two authors with &', () {
      const p = Paper(
        id: '', title: '', summary: '', keyContribution: '', whyItMatters: '',
        authors: ['Alice', 'Bob'], source: '', url: '', publishedDate: '',
        category: '', importanceScore: 0,
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
