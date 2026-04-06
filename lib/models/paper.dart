import 'package:freezed_annotation/freezed_annotation.dart';

part 'paper.freezed.dart';
part 'paper.g.dart';

@freezed
class Paper with _$Paper {
  const Paper._();

  const factory Paper({
    required String id,
    required String title,
    required String abstract,
    required List<String> authors,
    required String publishedDate,
    required String pdfUrl,
    required String abstractUrl,
    required String primaryCategory,
    @Default(false) bool isRead,
  }) = _Paper;

  factory Paper.fromJson(Map<String, dynamic> json) => _$PaperFromJson(json);

  String get shortId {
    final uri = Uri.tryParse(id);
    return uri?.pathSegments.last ?? id;
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(publishedDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return publishedDate;
    }
  }

  String get authorsPreview {
    if (authors.isEmpty) return 'Unknown';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return '${authors[0]} & ${authors[1]}';
    return '${authors[0]} et al.';
  }
}
