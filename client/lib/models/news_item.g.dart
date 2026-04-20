// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsItemImpl _$$NewsItemImplFromJson(Map<String, dynamic> json) =>
    _$NewsItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      whyItMatters: json['why_it_matters'] as String,
      sourceName: json['source_name'] as String,
      url: json['url'] as String,
      publishedDate: json['published_date'] as String,
      category: json['category'] as String,
      importanceScore: (json['importance_score'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsItemImplToJson(_$NewsItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'why_it_matters': instance.whyItMatters,
      'source_name': instance.sourceName,
      'url': instance.url,
      'published_date': instance.publishedDate,
      'category': instance.category,
      'importance_score': instance.importanceScore,
    };
