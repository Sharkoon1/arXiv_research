import 'package:xml/xml.dart';
import '../../models/paper.dart';

class XmlParser {
  XmlParser._();

  static List<Paper> parse(String xmlBody) {
    final document = XmlDocument.parse(xmlBody);
    final entries = document.findAllElements('entry');
    return entries.map(_parseEntry).whereType<Paper>().toList();
  }

  static Paper? _parseEntry(XmlElement entry) {
    try {
      final id = entry.findElements('id').firstOrNull?.innerText.trim() ?? '';
      final title = entry.findElements('title').firstOrNull?.innerText
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ') ??
          '';
      final abstract = entry.findElements('summary').firstOrNull?.innerText
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ') ??
          '';
      final published =
          entry.findElements('published').firstOrNull?.innerText.trim() ?? '';

      final authors = entry
          .findElements('author')
          .map((a) => a.findElements('name').firstOrNull?.innerText.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      String pdfUrl = '';
      String abstractUrl = '';

      for (final link in entry.findElements('link')) {
        final rel = link.getAttribute('rel') ?? '';
        final title = link.getAttribute('title') ?? '';
        final href = link.getAttribute('href') ?? '';

        if (title == 'pdf') {
          pdfUrl = href;
        } else if (rel == 'alternate') {
          abstractUrl = href;
        }
      }

      // Derive PDF url from abstract url if not explicit
      if (pdfUrl.isEmpty && abstractUrl.isNotEmpty) {
        pdfUrl = abstractUrl.replaceFirst('/abs/', '/pdf/');
      }

      // Primary category
      final categoryEl = entry.childElements
          .where((e) => e.localName == 'primary_category')
          .firstOrNull;
      final primaryCategory = categoryEl?.getAttribute('term') ?? 'cs.AI';

      return Paper(
        id: id,
        title: title,
        abstract: abstract,
        authors: authors,
        publishedDate: published,
        pdfUrl: pdfUrl,
        abstractUrl: abstractUrl,
        primaryCategory: primaryCategory,
      );
    } catch (_) {
      return null;
    }
  }
}
