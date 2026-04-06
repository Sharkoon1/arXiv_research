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
      whyItMatters: json['whyItMatters'] as String,
      sourceName: json['sourceName'] as String,
      url: json['url'] as String,
      publishedDate: json['publishedDate'] as String,
      category: json['category'] as String,
      importanceScore: (json['importanceScore'] as num).toInt(),
    );

Map<String, dynamic> _$$NewsItemImplToJson(_$NewsItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'whyItMatters': instance.whyItMatters,
      'sourceName': instance.sourceName,
      'url': instance.url,
      'publishedDate': instance.publishedDate,
      'category': instance.category,
      'importanceScore': instance.importanceScore,
    };
