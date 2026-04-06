// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaperImpl _$$PaperImplFromJson(Map<String, dynamic> json) => _$PaperImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      abstract: json['abstract'] as String,
      authors:
          (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      publishedDate: json['publishedDate'] as String,
      pdfUrl: json['pdfUrl'] as String,
      abstractUrl: json['abstractUrl'] as String,
      primaryCategory: json['primaryCategory'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaperImplToJson(_$PaperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'abstract': instance.abstract,
      'authors': instance.authors,
      'publishedDate': instance.publishedDate,
      'pdfUrl': instance.pdfUrl,
      'abstractUrl': instance.abstractUrl,
      'primaryCategory': instance.primaryCategory,
      'isRead': instance.isRead,
    };
