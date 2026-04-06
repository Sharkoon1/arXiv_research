import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

@freezed
class NewsItem with _$NewsItem {
  const NewsItem._();

  const factory NewsItem({
    required String id,
    required String title,
    required String summary,
    required String whyItMatters,
    required String sourceName,
    required String url,
    required String publishedDate,
    required String category,
    required int importanceScore,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) => _$NewsItemFromJson(json);

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
}
