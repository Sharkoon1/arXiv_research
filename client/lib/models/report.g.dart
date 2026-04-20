// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportSummaryImpl _$$ReportSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ReportSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      paperCount: (json['paper_count'] as num).toInt(),
      newsCount: (json['news_count'] as num).toInt(),
    );

Map<String, dynamic> _$$ReportSummaryImplToJson(_$ReportSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
      'paper_count': instance.paperCount,
      'news_count': instance.newsCount,
    };

_$ReportDetailImpl _$$ReportDetailImplFromJson(Map<String, dynamic> json) =>
    _$ReportDetailImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      briefing: json['briefing'] as String?,
      papers: (json['papers'] as List<dynamic>?)
              ?.map((e) => Paper.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      news: (json['news'] as List<dynamic>?)
              ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ReportDetailImplToJson(_$ReportDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'briefing': instance.briefing,
      'papers': instance.papers,
      'news': instance.news,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$CollectResultImpl _$$CollectResultImplFromJson(Map<String, dynamic> json) =>
    _$CollectResultImpl(
      reportId: json['report_id'] as String,
      reportName: json['report_name'] as String,
      papers: (json['papers'] as List<dynamic>?)
              ?.map((e) => Paper.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      news: (json['news'] as List<dynamic>?)
              ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      briefing: json['briefing'] as String?,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CollectResultImplToJson(_$CollectResultImpl instance) =>
    <String, dynamic>{
      'report_id': instance.reportId,
      'report_name': instance.reportName,
      'papers': instance.papers,
      'news': instance.news,
      'briefing': instance.briefing,
      'errors': instance.errors,
    };
