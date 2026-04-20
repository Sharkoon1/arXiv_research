// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaperImpl _$$PaperImplFromJson(Map<String, dynamic> json) => _$PaperImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      keyContribution: json['key_contribution'] as String,
      whyItMatters: json['why_it_matters'] as String,
      authors:
          (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      source: json['source'] as String,
      url: json['url'] as String,
      publishedDate: json['published_date'] as String,
      category: json['category'] as String,
      importanceScore: (json['importance_score'] as num).toInt(),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaperImplToJson(_$PaperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'key_contribution': instance.keyContribution,
      'why_it_matters': instance.whyItMatters,
      'authors': instance.authors,
      'source': instance.source,
      'url': instance.url,
      'published_date': instance.publishedDate,
      'category': instance.category,
      'importance_score': instance.importanceScore,
      'isRead': instance.isRead,
    };
