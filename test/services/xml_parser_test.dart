import 'package:flutter_test/flutter_test.dart';
import 'package:arxiv_research/core/utils/xml_parser.dart';

const _validFeed = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>https://arxiv.org/abs/2401.00001v1</id>
    <title>  Test   Paper Title  </title>
    <summary>  Abstract   text here  </summary>
    <published>2024-01-15T00:00:00Z</published>
    <author><name>Alice Smith</name></author>
    <author><name>Bob Jones</name></author>
    <link rel="alternate" href="https://arxiv.org/abs/2401.00001v1"/>
    <link title="pdf" href="https://arxiv.org/pdf/2401.00001v1"/>
    <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.LG"/>
  </entry>
</feed>''';

const _noExplicitPdfFeed = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <id>https://arxiv.org/abs/2401.00002v1</id>
    <title>No PDF Link</title>
    <summary>Abstract.</summary>
    <published>2024-02-01T00:00:00Z</published>
    <author><name>Carol White</name></author>
    <link rel="alternate" href="https://arxiv.org/abs/2401.00002v1"/>
  </entry>
</feed>''';

const _emptyFeed = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
</feed>''';

void main() {
  group('XmlParser.parse', () {
    test('parses a valid entry correctly', () {
      final papers = XmlParser.parse(_validFeed);
      expect(papers.length, 1);

      final p = papers.first;
      expect(p.id, 'https://arxiv.org/abs/2401.00001v1');
      expect(p.title, 'Test Paper Title');
      expect(p.abstract, 'Abstract text here');
      expect(p.authors, ['Alice Smith', 'Bob Jones']);
      expect(p.publishedDate, '2024-01-15T00:00:00Z');
      expect(p.pdfUrl, 'https://arxiv.org/pdf/2401.00001v1');
      expect(p.abstractUrl, 'https://arxiv.org/abs/2401.00001v1');
      expect(p.primaryCategory, 'cs.LG');
    });

    test('derives pdf URL from abstract URL when no explicit pdf link', () {
      final papers = XmlParser.parse(_noExplicitPdfFeed);
      expect(papers.length, 1);
      expect(papers.first.pdfUrl, 'https://arxiv.org/pdf/2401.00002v1');
    });

    test('returns empty list for feed with no entries', () {
      final papers = XmlParser.parse(_emptyFeed);
      expect(papers, isEmpty);
    });

    test('collapses whitespace in title and abstract', () {
      final papers = XmlParser.parse(_validFeed);
      expect(papers.first.title, isNot(contains('  ')));
      expect(papers.first.abstract, isNot(contains('  ')));
    });
  });
}
