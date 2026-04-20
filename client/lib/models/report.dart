import 'package:freezed_annotation/freezed_annotation.dart';

import 'news_item.dart';
import 'paper.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class ReportSummary with _$ReportSummary {
  const factory ReportSummary({
    required String id,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'paper_count') required int paperCount,
    @JsonKey(name: 'news_count') required int newsCount,
  }) = _ReportSummary;

  factory ReportSummary.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryFromJson(json);
}

@freezed
class ReportDetail with _$ReportDetail {
  const factory ReportDetail({
    required String id,
    required String name,
    String? briefing,
    @Default([]) List<Paper> papers,
    @Default([]) List<NewsItem> news,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ReportDetail;

  factory ReportDetail.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailFromJson(json);
}

@freezed
class CollectResult with _$CollectResult {
  const factory CollectResult({
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'report_name') required String reportName,
    @Default([]) List<Paper> papers,
    @Default([]) List<NewsItem> news,
    String? briefing,
    @Default([]) List<String> errors,
  }) = _CollectResult;

  factory CollectResult.fromJson(Map<String, dynamic> json) =>
      _$CollectResultFromJson(json);
}
