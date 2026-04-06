// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaperImpl _$$PaperImplFromJson(Map<String, dynamic> json) => _$PaperImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      keyContribution: json['keyContribution'] as String,
      whyItMatters: json['whyItMatters'] as String,
      authors:
          (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      source: json['source'] as String,
      url: json['url'] as String,
      publishedDate: json['publishedDate'] as String,
      category: json['category'] as String,
      importanceScore: (json['importanceScore'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaperImplToJson(_$PaperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'keyContribution': instance.keyContribution,
      'whyItMatters': instance.whyItMatters,
      'authors': instance.authors,
      'source': instance.source,
      'url': instance.url,
      'publishedDate': instance.publishedDate,
      'category': instance.category,
      'importanceScore': instance.importanceScore,
      'isRead': instance.isRead,
    };
